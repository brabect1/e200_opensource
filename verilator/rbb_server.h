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

#ifndef RBB_SERVER_H
#define RBB_SERVER_H

#include <stdint.h>
#include <sys/types.h>
#include <pthread.h>


class rbb_server;


/**
* Implements the backend that takes care of driving a JTAG interface.
*
* This implements another level of indirection so that the RBB server
* can be reused as is, while the backend needs to implement the adapter
* for a particular JTAG interface implementation.
*/
class rbb_backend {

    public:

        /**
        * Gets the frontend server to which the backend instance has been assigned.
        */
        virtual rbb_server* getServer() = 0;

        /**
        * Assigns the backend instance to a frontend server. When successful, the
        * server will be returned by ::getServer().
        *
        * @return Zero on success, non-zero on error.
        */
        virtual int setServer( rbb_server* server ) = 0;

        /**
        * Initializes the JTAG interface.
        */
        virtual void init() = 0;

        /**
        * Resets the JTAG interface.
        */
        virtual void reset() = 0;

        /**
        * Requests backend to quit.
        */
        virtual void quit() = 0;

        /**
        * Sets blink status to on/off (=1/0).
        */
        virtual void blink(int on) = 0;

        /**
        * Drives JTAG inputs to the given state. Allowed values are 0 and 1.
        */
        virtual void setInputs(int tck, int tms, int tdi) = 0;

        /**
        * Gets the state of JTAG TDO.
        */
        virtual int getTdo() = 0;
};

/**
* Implements an abstract OpenOCD `remote_bitbang` (RBB) server that delegates command
* processing to a backend. This class implements the frontend part, which takes care
* of socket connections and processing of the remote bitbang protocol. The actual
* execution of bitbang commands is performed by the backend part.
*/
class rbb_server {

    public:

        /**
        * Creates a new server with a given back-end.
        */
        rbb_server(rbb_backend* backend, int pipefd);

        /**
        * Opens a socket for connections on the given port of localhost.
        */
        void listen(uint16_t port);

        /**
        * Waits for a client connecting to the socket openned by ::listen().
        * This method will block until the client connects.
        */
        void accept();

        /**
        * Gets the status if the server connection has been closed by the
        * client.
        *
        * @return Non-zero value if finished.
        */
        int finished();

        /**
        * Responds to incoming commands from the client. This method shall be called
        * in a loop after the client connection was accepted and has not been closed
        * yet.
        *
        * The execution of incoming commands is delegated to the backend.
        */
        void respond();

        /**
        * Instructs the RBB server to close the socket and any connections.
        */
        void finish();

    private:

        rbb_backend* backend;

        /**
        * Socket file descriptor where the server listens for new connections.
        */
        int sockfd;

        /**
        * Socket file descriptor of an accepted client connection. This server
        * supports a single client on the "first come first serve" basis.
        */
        int clientfd;

        /**
        * Pipe read file descriptor that is used to signal the server to quit.
        */
        int pipefd;

};

#endif
