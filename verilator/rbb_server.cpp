/*
Copyright 2019 Tomas Brabec

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <algorithm>
#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <sys/epoll.h>

#include "rbb_server.h"


rbb_server::rbb_server(rbb_backend* backend, int pipefd):
  sockfd(0),
  clientfd(0),
  pipefd(pipefd),
  backend(NULL)
{
    if (backend != NULL && backend->setServer(this) == 0) {
        this->backend = backend;
    } else {
        fprintf(stderr,"ERROR: Failed to register backend!\n");
    }
}

int rbb_server::finished() {
    int res = (sockfd == 0 && clientfd == 0);
//    fprintf(stderr,"INFO: Finished = %s\n", res ? "yes" : "no");
    return res;
}

void rbb_server::finish() {
    if (sockfd != 0) {
        if (clientfd != 0) {
            close(clientfd);
            clientfd = 0;
        }

        close(sockfd);
        sockfd = 0;

        fprintf(stderr,"INFO: Closing rbb_server socket (%d, %d).\n", sockfd, clientfd);
    }
}

//TODO: may consider flockfile() for thread safety of stderr output operations
void rbb_server::listen(uint16_t port) {

    // create a new socket
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0) {
        fprintf(stderr, "ERROR opening socket (%d): %s\n", errno, strerror(errno));
        sockfd = 0;
        abort();
    }

//    // make the socket non-blocking
//    fcntl(sockfd, F_SETFL, O_NONBLOCK);

    // make the socket reuse the address (e.g. even if blocked by a crashed process)
    int reuseaddr = 1;
    if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &reuseaddr, sizeof(int)) < 0) {
        fprintf(stderr, "ERROR setsockopt(SO_REUSEADDR) failed (%d): %s\n", errno, strerror(errno));
        close(sockfd);
        sockfd = 0;
        abort();
    }

    // bind the socket to a port
    struct sockaddr_in sockaddr;
    sockaddr.sin_family = AF_INET;
    sockaddr.sin_addr.s_addr = INADDR_ANY;
    sockaddr.sin_port = htons(port);
    if (bind(sockfd, (struct sockaddr*)&sockaddr, sizeof(sockaddr)) < 0) {
        fprintf(stderr, "ERROR binding socket to port %d (%d): %s\n", port, errno, strerror(errno));
        close(sockfd);
        sockfd = 0;
        abort();
    }

    // listen to connections
    if (::listen(sockfd,1) < 0) {
        fprintf(stderr, "ERROR listening on a bound socket (%d): %s\n", errno, strerror(errno));
        close(sockfd);
        sockfd = 0;
        abort();
    }
    
    fprintf(stderr, "RBB server listening on port %d\n", port);
}

void rbb_server::accept() {
    struct sockaddr_in clientaddr;
    if (clientfd == 0 && sockfd != 0) {
        //TODO: 1st attempt to use epoll example from http://man7.org/linux/man-pages/man7/epoll.7.html
        struct epoll_event ev, events[2];
        int nfds, epollfd;

        epollfd = epoll_create1(EPOLL_CLOEXEC);
        if (epollfd == -1) {
            perror("epoll_create1");
            abort();
        }

        ev.events = EPOLLIN;
        ev.data.fd = sockfd;
        if (epoll_ctl(epollfd, EPOLL_CTL_ADD, sockfd, &ev) == -1) {
            perror("epoll_ctl: sockfd");
            abort();
        }

        ev.events = EPOLLIN;
        ev.data.fd = pipefd;
        if (epoll_ctl(epollfd, EPOLL_CTL_ADD, pipefd, &ev) == -1) {
            perror("epoll_ctl: pipefd");
            abort();
        }

        nfds = epoll_wait(epollfd, events, 2, -1);
        if (nfds == -1) {
            perror("epoll_wait");
            abort();
        }
        for (int n = 0; n < nfds; ++n) {
            if (events[n].data.fd == sockfd) {
                socklen_t clilen = sizeof(clientaddr);
                clientfd = ::accept(sockfd, (struct sockaddr*)&clientaddr, &clilen);
                if (clientfd < 0) {
                    fprintf(stderr, "ERROR accepting client connection (%d): %s\n", errno, strerror(errno));
                    close(sockfd);
                    sockfd = 0;
                    clientfd = 0;
                    abort();
                }
            } else {
                finish();
            }
        }
    }
}

void rbb_server::respond() {
    char c;
    char respond;
    if (clientfd != 0) {
        ssize_t n = read(clientfd,&c,sizeof(c));
        if (n < 0) {
            fprintf(stderr, "ERROR receiving command (%d): %s\n", errno, strerror(errno));
            return;
        }

        respond = 0;
        switch (c) {
            case 'Q': if (backend) backend->quit(); else finish(); break;
            case 'r': if (backend) backend->reset(); break;
            case 'B': if (backend) backend->blink(1); break;
            case 'b': if (backend) backend->blink(0); break;
            case '0': if (backend) backend->setInputs(0,0,0); break;
            case '1': if (backend) backend->setInputs(0,0,1); break;
            case '2': if (backend) backend->setInputs(0,1,0); break;
            case '3': if (backend) backend->setInputs(0,1,1); break;
            case '4': if (backend) backend->setInputs(1,0,0); break;
            case '5': if (backend) backend->setInputs(1,0,1); break;
            case '6': if (backend) backend->setInputs(1,1,0); break;
            case '7': if (backend) backend->setInputs(1,1,1); break;
            case 'R': respond= backend ? (backend->getTdo() ? '1':'0') : '1'; break;
            default:
                fprintf(stderr,"WARN unknown command '%c'\n", c);
        }

        if (respond != 0) {
            ssize_t n = write(clientfd, &respond, sizeof(respond));
            if (n < 0) {
                fprintf(stderr, "ERROR sending response '%c' (%d): %s\n", respond, errno, strerror(errno));
            }
        }
    }
}

