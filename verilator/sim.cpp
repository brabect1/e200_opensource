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
#include <vector>
#include <algorithm>
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




using namespace std;

static pthread_mutex_t mutex;

static uint64_t simtime = 0;

static int pipefd[2];

double sc_time_stamp () { // Called by $time in Verilog
	return simtime;  // converts to double, to match what SystemC does
}

/**
* Aggregates information passed from the main application thread to the
* system and JTAG threads.
*/
struct th_arg {
    // Thread ID.
    int id;

    // Reference to a mutex shared by the threads.
    pthread_mutex_t* mutex;

    // Reference to a Verilator testbench class. Needs to be guarded by the mutex.
    Vtb_verilator* top;

    // Reference to a Verilator tracer class. Needs to be guarded by the mutex.
    VerilatedVcdC* tfp;

    // Simulation time. Needs to be guarded by the mutex.
    uint64_t* simtime;

    // This value controls how many `clk` cycles will the C++ wrapper generate
    // before giving up the simulation. It is defined as a macro to let users
    // change the default for some longer simulations wihtout a need to edit
    // the wrapper.
    int max_cycs_pow;
};


/**
* Implements a command line options parser.
* Code origin: https://stackoverflow.com/questions/865668/how-to-parse-command-line-arguments-in-c
*/
class OptionsParser{
    public:
        OptionsParser (int &argc, char **argv){
            for (int i=1; i < argc; ++i)
                this->tokens.push_back(std::string(argv[i]));
        }
        /// @author iain
        std::string getCmdOption(const std::string &option) const{
            std::vector<std::string>::const_iterator itr;
            itr =  std::find(this->tokens.begin(), this->tokens.end(), option);
            if (itr != this->tokens.end() && ++itr != this->tokens.end()){
                return std::string(*itr);
            }
            return std::string("");
        }
        /// @author iain
        bool cmdOptionExists(const std::string &option) const{
            return std::find(this->tokens.begin(), this->tokens.end(), option)
                != this->tokens.end();
        }
    private:
        std::vector <std::string> tokens;
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
#if VM_TRACE
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
#if VM_TRACE
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
#if VM_TRACE
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
#if VM_TRACE
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
    rbb = new rbb_server(backend, pipefd[0]);

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
    cerr << "id " << a->id << ": System clock started (" << (a->max_cycs_pow > 0 ? "timeout ":"no timeout");
    if (a->max_cycs_pow > 0) cerr << (1 << a->max_cycs_pow) << " clocks";
    cerr << ") ..." << endl;
    if (!Verilated::gotFinish()) {
        a->top->rst_n = 0;
        for (int i=0; i < 10; i++) {
            a->top->clk = 1;
            a->top->eval();
#if VM_TRACE
	        if (a->tfp != NULL) a->tfp->dump(*simtime);
#endif
            (*simtime)++;
            a->top->clk = 0;
            a->top->eval();
#if VM_TRACE
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
#if VM_TRACE
	        if (a->tfp != NULL) a->tfp->dump(*simtime);
#endif
            (*simtime)++;
            a->top->clk = 0;
            a->top->eval();
#if VM_TRACE
	        if (a->tfp != NULL) a->tfp->dump(*simtime);
#endif
            (*simtime)++;

            if (a->max_cycs_pow > 0 && (cnt > (1 << a->max_cycs_pow))) {
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


/**
* Implements the simulation wrapper. Its purpose is to parse input arguments,
* instantiate the Verilator testbench, and start the threads. The system thread
* will take care of system clocking and reset, the JTAG thread runs the RBB
* server that stimulates the testbench's JTAG interface and provides an interface
* to OpenOCD.
*/
int main(int argc, char** argv) {
    OptionsParser* arg_parser = new OptionsParser(argc, argv);
    int cycs_pow = 17;
    int dump_on = 0;
    std::string dump_path;

    // help option
    if (arg_parser->cmdOptionExists("-h") || arg_parser->cmdOptionExists("--help")) {
        cerr << "Options:" << endl;
        cerr << "\t-h, --help    Prints this help message." << endl;
        cerr << "\t-d <path>     Generate VCD dump file. Default is no dump." << endl;
        cerr << "\t-c <num>      Stop simulation after 2**<num> cycles. Non-positive numbers" << endl;
        cerr << "\t              run until Verilog $finish. Default is 17." << endl;
        delete arg_parser;
        return 0;
    }

    // dump option
    if (arg_parser->cmdOptionExists("-d")) {
        dump_path = arg_parser->getCmdOption("-d");
        if (!dump_path.empty()) {
            dump_on=1;
            cerr << "**Info: VCD dump turned on (file: " << dump_path << ")." << endl;
        }
    }

    // cycles/timeout option
    if (arg_parser->cmdOptionExists("-c")) {
        std::string s = arg_parser->getCmdOption("-c");
        if (!s.empty()) {
            try {
                cycs_pow = std::stoi(s);
                if (cycs_pow > 0) cerr << "**Info: Timeout set to " << (1<<cycs_pow) << "." << endl;
                else cerr << "**Info: Set no timeout!" << endl;
            } catch (std::invalid_argument e) {
                cerr << "**WARNING: Invalid argument to -c option!" << endl;
            } catch (std::out_of_range e) {
                cerr << "**WARNING: Out of range argument to -c option!" << endl;
            }
        } else {
            cerr << "**WARNING: No argument passed to -c option! Using default ..." << endl;
        }
    }

    delete arg_parser;

    // create a new pipe to signal towards the JTAG/RBB thread
    if (pipe(pipefd) == -1) {
        fprintf(stderr, "ERROR creating pipe (%d): %s\n", errno, strerror(errno));
        abort();
    }

    signal(SIGTERM, handle_sigterm);

    Verilated::commandArgs(argc, argv);
    Vtb_verilator* top = new Vtb_verilator;
    VerilatedVcdC* tfp = NULL;

    pthread_t threads[2];
    struct th_arg targs[2];

#if VM_TRACE
    if (dump_on) {
	    Verilated::traceEverOn(true);
        tfp = new VerilatedVcdC;
	    top->trace (tfp, 99);
        tfp->open (dump_path.c_str());
    }
#endif

    pthread_mutex_lock(&mutex);
    cout << "Simulation started ..." << endl;
    simtime = 0;
    pthread_mutex_unlock(&mutex);

    for (long int i = 0 ; i < 2 ; ++i) {
        targs[i].id = i;
        targs[i].mutex = &mutex;
        targs[i].top = top;
        targs[i].max_cycs_pow = cycs_pow;
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

    // Now here's the funny part: Ending the simulation. The following use
    // cases shall be considered, ordered in the decreasing likelihood:
    //
    // 1. No use of the OpenOCD interface and hence the JTAG/RBB thread. The
    //    system thread will end either by timing out or on terminating the
    //    simulation (by detecting pass/fail condition or for any other reason
    //    in the SystemVerilog testbench). This the use case for all the ISA
    //    and other tests.
    //
    // 2. Use of the OpenOCD interface and no timeout. This is the case where
    //    want to debug the RISC-V DM/DTM mechanism (and the primary reason why
    //    the JTAG/RBB thread has been introduced).
    //
    //    Here we assume the simulation will end after closing the OpenOCD
    //    connection.
    //
    // 3. Use of the OpenOCD interface and terminating the simulation (from the
    //    SystemVerilog testbench).
    //
    // 4. Use of the OpenOCD interface and time out after a certain number of
    //    simulation clock cycles. This is somewhat unlikely, but still a valid
    //    use case.
    //
    // Few other considerations:
    //
    // - The *system thread* (i.e. the one generating system clocks) will
    //   terminate either on timeout (if not disabled) or by terminating
    //   the simulation (i.e. calling `$finish` from the SystemVerilog
    //   testbench).
    //
    //   When the system thread terminates, the JTAG/RBB thread shall terminate
    //   (and so does the whole program). The reason is that without clock
    //   the simulated system is unlikely to respond.
    //
    // - When we intend to use OpenOCD, we assume the system thread runs
    //   without a timeout (and also that the usual mechanism of terminating
    //   the SystemVerilog testbench for ISA tests would not trigger). Hence
    //   the event to terminate the simulation/program will come from the
    //   JTAG/RBB thread.
    //
    // Synchronization mechanism: One can think of many ways, but since both
    // threads are supposed to check (at some point) if the SystemVerilog
    // testbench had finished. Since we built in the `quit` signal into the
    // testbench and a process that will call `$finish` after seeing it in 1,
    // we get a synchronization means for free.
    //
    // The problem that remains is that the JTAG/RBB server may block either
    // on `accept()` or `read()`. The assumption is that this happens either
    // in case 1 (no use of OpenOCD interface), or in cases 3 and 4 (the
    // system thread ends before the JTAG/RBB one).
    //
    // It then seems correct to wait/join the system thread and the "trip"
    // the JTAG/RBB thread if not already ended.
    for(int i = 0 ; i < 2; ++i) {
        void* status;
        int t;

        // make sure to signal the end to the JTAG/RBB thread
        if (i == 1) {
            write(pipefd[1], "q", 1);
        }

        t = pthread_join(threads[i], &status);
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
    if (tfp != NULL) {
	    tfp->close();
	    delete tfp;
    }
#endif    
    return 0;
}
