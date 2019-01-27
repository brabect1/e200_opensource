/*
Copyright 2018 Tomas Brabec

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

#include "rbb_server.h"
#include <iostream>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <getopt.h>
#include <pthread.h>

// Verilator related includes
#include "Vtb_verilator.h"
#include <verilated.h>
#if VM_TRACE
#include <verilated_vcd_c.h>
#endif


// This value controls how many `clk` cycles will the C++ wrapper generate
// before giving up the simulation. It is defined as a macro to let users
// change the default for some longer simulations wihtout a need to edit
// the wrapper.
#ifndef RUN_2POW_CYCS
#define RUN_2POW_CYCS 17
#endif


using namespace std;

static pthread_mutex_t mutex;

static uint64_t simtime = 0;

double sc_time_stamp () { // Called by $time in Verilog
	return simtime;  // converts to double, to match what SystemC does
}

struct th_arg {
    int id;
    pthread_mutex_t* mutex;
    Vtb_verilator* top;
    VerilatedVcdC* tfp;
    uint64_t* simtime;
};


/**
* Implements an RBB backend that stimulates JTAG interface of the Verilator
* DUT class.
*/
class verilator_backend: public rbb_backend {

    private:
        rbb_server* srv;
        struct th_arg* arg;

    public:

        verilator_backend(struct th_arg* a) :
            srv(NULL),
            arg(NULL)
        {
            arg = a;
        }

        virtual rbb_server* getServer() {
            return srv;
        }

        virtual int setServer( rbb_server* server ) {
            if (srv == NULL) {
                srv = server;
                return 0;
            } else {
                return 1;
            }
        }

        virtual void init() {
            if (arg != NULL && arg->mutex != NULL) {
                pthread_mutex_lock(arg->mutex);
                if (arg->top != NULL && !Verilated::gotFinish()) {
                    uint64_t* simtime = arg->simtime;
                    arg->top->tck = 1;
                    arg->top->tms = 1;
                    arg->top->tdi = 1;
                    arg->top->trstn = 1;
                    arg->top->quit = 0;
                    arg->top->eval();
#if VM_TRACE && VCDTRACE
	                if (arg->tfp != NULL) arg->tfp->dump(*simtime);
#endif
                    (*simtime)++;
                    pthread_mutex_unlock(arg->mutex);
                } else {
                    pthread_mutex_unlock(arg->mutex);
                    quit();
                }
            } else {
                quit();
            }
        }

        virtual void reset() {
            if (arg != NULL && arg->mutex != NULL) {
                uint64_t* simtime = arg->simtime;
                pthread_mutex_lock(arg->mutex);
                fprintf(stderr, "Resetting.\n");
                if (arg->top != NULL && !Verilated::gotFinish()) {
                    arg->top->trstn = 0;
                    arg->top->eval();
                    arg->top->trstn = 1;
                    arg->top->eval();
#if VM_TRACE && VCDTRACE
	                if (arg->tfp != NULL) arg->tfp->dump(*simtime);
#endif
                    (*simtime)++;
                }
                pthread_mutex_unlock(arg->mutex);
            }
        }

        virtual void quit() {
            if (arg != NULL && arg->mutex != NULL) {
                uint64_t* simtime = arg->simtime;
                pthread_mutex_lock(arg->mutex);
                fprintf(stderr, "Quitting JTAG thread.\n");
                if (arg->top != NULL && !Verilated::gotFinish()) {
                    arg->top->quit = 1;
                    arg->top->eval();
#if VM_TRACE && VCDTRACE
	                if (arg->tfp != NULL) arg->tfp->dump(*simtime);
#endif
                    (*simtime)++;
                }
                pthread_mutex_unlock(arg->mutex);
            }

            // indicate the RBB server to finish
            if (srv) srv->finish();
        }

        virtual void blink(int on) {
            // ... presently empty
        }

        virtual void setInputs(int tck, int tms, int tdi) {
            if (arg != NULL && arg->mutex != NULL) {
                uint64_t* simtime = arg->simtime;
                pthread_mutex_lock(arg->mutex);
//                fprintf(stderr, "Setting: tck=%0d, tms=%0d, tdi=%0d\n", tck, tms, tdi);
                if (arg->top != NULL && !Verilated::gotFinish()) {
                    arg->top->tck = tck;
                    arg->top->tms = tms;
                    arg->top->tdi = tdi;
                    arg->top->eval();
#if VM_TRACE && VCDTRACE
	                if (arg->tfp != NULL) arg->tfp->dump(*simtime);
#endif
                    (*simtime)++;
                }
                pthread_mutex_unlock(arg->mutex);

                // The sleep here functions as a flow speed control to "yield"
                // and let the other thread proceed. Without the sleep, it may
                // happen that during the other thread sleeping, this thread
                // manages to process a great deal of JTAG communication. It
                // then happens that the OpenOCD communication indicates the
                // target CPU is busy because its system clock is not running
                // and the JTAG DTM module waits for a response.
                usleep(1);
            }
        }

        virtual int getTdo() {
            int ret;
            ret = 1;
            if (arg != NULL && arg->mutex != NULL && arg->top != NULL) {
                pthread_mutex_lock(arg->mutex);
                ret = Verilated::gotFinish() ? 1 : arg->top->tdo;
//                fprintf(stderr,"tdo=%d/%d\n", ret, arg->top->tdo);
                pthread_mutex_unlock(arg->mutex);
            }
            return ret;
        }
};


void* jtag_thrd(void* arg) {
    struct th_arg* a = (th_arg*)arg;

    // Port numbers are 16 bit unsigned integers. 
    uint16_t rbb_port = 9823;
    rbb_server* rbb;
    verilator_backend* backend;

    pthread_mutex_lock(a->mutex);
    cout << "server: Starting ..." << endl;
    pthread_mutex_unlock(a->mutex);

    backend = new verilator_backend(a);
    rbb = new rbb_server(backend);

    rbb->listen( rbb_port );
    rbb->accept();
    while (!rbb->finished()) {
        rbb->respond();
    }

    pthread_mutex_lock(a->mutex);
    cout << "server: Finished." << endl;
    pthread_mutex_unlock(a->mutex);

    if (rbb) delete rbb;
    if (backend) delete backend;

    pthread_exit(NULL);
}


void* sys_thrd(void* arg) {
    struct th_arg* a = (th_arg*)arg;
    int done = 0;
    uint64_t* simtime = a->simtime;
    uint64_t cnt = 0;

    pthread_mutex_lock(a->mutex);
    cerr << "id " << a->id << ": System clock started (" << (RUN_2POW_CYCS > 0 ? "timeout ":"no timeout");
    if (RUN_2POW_CYCS > 0) cerr << (1<<RUN_2POW_CYCS) << " clocks";
    cerr << ") ..." << endl;
    if (!Verilated::gotFinish()) {
        a->top->rst_n = 0;
        for (int i=0; i < 10; i++) {
            a->top->clk = 1;
            a->top->eval();
#if VM_TRACE && VCDTRACE
	        if (a->tfp != NULL) a->tfp->dump(*simtime);
#endif
            (*simtime)++;
            a->top->clk = 0;
            a->top->eval();
#if VM_TRACE && VCDTRACE
	        if (a->tfp != NULL) a->tfp->dump(*simtime);
#endif
            (*simtime)++;
        }
        a->top->rst_n = 1;
    }
    pthread_mutex_unlock(a->mutex);

    while (!done) {
        cnt++;
        pthread_mutex_lock(a->mutex);
        if (!Verilated::gotFinish()) {
            a->top->clk = 1;
            a->top->eval();
#if VM_TRACE && VCDTRACE
	        if (a->tfp != NULL) a->tfp->dump(*simtime);
#endif
            (*simtime)++;
            a->top->clk = 0;
            a->top->eval();
#if VM_TRACE && VCDTRACE
	        if (a->tfp != NULL) a->tfp->dump(*simtime);
#endif
            (*simtime)++;

            if (RUN_2POW_CYCS > 0 && (cnt > (1 << RUN_2POW_CYCS))) {
                a->top->quit = 1;
                a->top->eval();
                done = 1;
            }
        } else {
            done = 1;
        }
        pthread_mutex_unlock(a->mutex);

        // This sleep is here to slow down the simulation for one not to fully
        // load computer's CPU and for other to decrease the size of VCD dump.
        // By changing the sleep value, one may somewhat control the size of
        // VCD; in that case it may be necessary to adjust the sleep time of
        // the other thread.
        usleep(10);
    }

    pthread_mutex_lock(a->mutex);
    cerr << "id " << a->id << ": Finished ..." << endl;
    pthread_mutex_unlock(a->mutex);

    pthread_exit(NULL);
}


void handle_sigterm(int sig) {
}


int main(int argc, char** argv) {
	Verilated::commandArgs(argc, argv);
	Vtb_verilator* top = new Vtb_verilator;

    pthread_t threads[2];
    struct th_arg targs[2];


    signal(SIGTERM, handle_sigterm);

#if VM_TRACE
	Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
#if VCDTRACE
	top->trace (tfp, 99);
    tfp->open ("dump.vcd");
#endif
#endif

    pthread_mutex_lock(&mutex);
    cout << "Simulation started ..." << endl;
    simtime = 0;
    pthread_mutex_unlock(&mutex);

    for (long int i = 0 ; i < 2 ; ++i) {
        targs[i].id = i;
        targs[i].mutex = &mutex;
        targs[i].top = top;
#if VM_TRACE
        targs[i].tfp = tfp;
#else
        targs[i].tfp = NULL;
#endif
        targs[i].simtime = &simtime;
        int t;
       
        if (i == 0) {
           t = pthread_create(&threads[i], NULL, sys_thrd, (void*)&targs[i]);
        } else {
           t = pthread_create(&threads[i], NULL, jtag_thrd, (void*)&targs[i]);
        }
 
        if (t != 0) {
            pthread_mutex_lock(&mutex);
            cout << "Error in thread creation: " << t << endl;
            pthread_mutex_unlock(&mutex);
        }
    }
 
    for(int i = 0 ; i < 2; ++i) {
        void* status;
        int t = pthread_join(threads[i], &status);
        if (t != 0) {
            pthread_mutex_lock(&mutex);
            cout << "Error in thread join: " << t << endl;
            pthread_mutex_unlock(&mutex);
        }
    }
 
    pthread_mutex_lock(&mutex);
    cout << "simtime=" << simtime << endl;
    pthread_mutex_unlock(&mutex);

	delete top;
#if VM_TRACE
#if VCDTRACE
	tfp->close();
#endif
	delete tfp;
#endif
    return 0;
}
