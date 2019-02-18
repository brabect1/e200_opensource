ISA Tests under Verilator
=========================

This folder contains a Verilator testbench to exercise RTL against ISA
[riscv-tests](https://github.com/riscv/riscv-tests).

The testbench was tested with Verilator 3.924 and should work out of the box
with 3.922 (as the 1st version supporting SV `assert property`). For earlier
versions one needs to verilate with `+define+DISABLE_SV_ASSERTIONS=1`.

The testbench consists of a Verilog testbench and a C++ Verilator wrapper.
The wrapper generates the reset and system clock and also provides an OpenOCD
remote bitbang server. The latter may be used to connect from OpenOCD to the
simulation target and debug it interactively.

If the user decides not to use the remote bitbang server (which is most of
the time), there is no performance penalty. In the opposite direction, using
the OpenOCD interface provides best value with VCD dump tracing; beware that
dumps of even a relative short session would take lots, lots of disk space.

Limitations
-----------

- Regressions support pre-compiled versions of [riscv-tests](https://github.com/riscv/riscv-tests)
  available in `riscv-tools/riscv-tests/isa/generated` folder.

- Default number of clock cycles set to `2**17`. The C++ testbench forces the simulation
  to stop after 131,072 cycles. This may be changed from command line by `sim.cpp -c <num>`,
  where `<num>` translates into `2**<num>` cycles. `<num>` of zero disables any timeout.

- The RTL code needs to be verilated with `--trace` option and a VCD trace
  instance created in the C++ testbench. Otherwise the simulation does not
  work/converge.

Installing Verilator
--------------------

### Installing Packaged Version ###

Instructions from https://github.com/ucb-bar/riscv-sodor

- Ubuntu 17.04 and on

      sudo apt install pkg-config verilator
      
- Ubuntu 16.04 and earlier

      sudo apt install pkg-config
      wget http://mirrors.kernel.org/ubuntu/pool/universe/v/verilator/verilator_3.900-1_amd64.deb
      sudo dpkg -i verilator_3.900-1_amd64.deb

### Building from Source ###

Instructions adapted from https://github.com/ucb-bar/riscv-sodor

    # install packages needed for compilation
    sudo apt-get install make autoconf g++ flex bison libfl-dev
    
    # optionally install GtkWave
    sudo apt-get install gtkwave
    
    # obtain a released version
    # (alternatively clone a git repo: http://git.veripool.org/git/verilator)
    wget https://www.veripool.org/ftp/verilator-3.924.tgz
    tar -xzf verilator-3.924.tgz
    
    # compile
    # (when intending to install, consider using ./configure --prefix=<path>)
    cd verilator*
    unset VERILATOR_ROOT
    ./configure && make
    
    # set environment
    export VERILATOR_ROOT=$PWD
    export PATH=$PATH:$VERILATOR_ROOT/bin

Building Testbench
------------------

To build with default settings:

    make build

To build with Verilator prior to 3.922:

    make build vflags_extra='--trace +define+DISABLE_SV_ASSERTION=1'

Running
-------

To run the supported regression test suite:

    make regression

To run a full regression test suite (including e.g. floating-point ISA tests):

    make regression isa_test_patts='*'

To run a single test:

    # either run as a regression suite of one test
    make regression isa_tests=rv32ui-p-xori
    
    # or run as a single test
    make test-rv32ui-p-xori

Changing to a different test set:

    # use `isa_test_dir` to point the Makefile where to look for *.verilog
    # code dumps
    make isa_test_dir=../riscv-tools/riscv-tests/isa/rebuild test-soc-p-uart-regs

To enable VCD dump into `<file>`, use the `-d <file>` option to the compiled
simulation executable. This can be passed through the `sflags` option to the
Makefile. Note that VCD dump is disabled by default.

    make sflags='-d dump.vcd' ...

To change or disable the max number of clock cycles being simulated, use the
`-c <num>` option to the simulation executable. `<num>` value of zero or below
disables the time, a positive value sets the timeout to `2**<num>` clock cycles.
Again, use the `sflags` option to the Makefile (can be combined with other
simulation executable options).

    make sflags='-c 30'

Troubleshoot
------------

- Core dump due to insufficient memory size: Internal memory arrays have limited size
  (e.g. 64 KB) and when `$readmemh` gets over the limit, Verilator just aborts.

- Core dump due to non-existing memory file: When a memory file (passed through
  `TESTCASE` plus argument) does not exist, Verilator just silently aborts.

OpenOCD Interface
-----------------

The C++ Verilator wrapper uses threaded architecture, where one *system* thread
generates the system clock and reset, and another *JTAG* thread runs the OpenOCD
remote bitbang server and uses it to drive the JTAG interface.

Presently the remote bitbang server runs at a hardcoded port 9823.

To connect to the remote bitbang server, the OpenOCD has to be configured and
built with remote bitbang support (requires `libtool` and `automake`).

    git clone https://github.com/riscv/riscv-openocd
    cd riscv-openocd && ./bootstrap && ./configure --enable-remote_bitbang && make

Then use the following sample command file with OpenOCD (assuming the Verilator
simulation is already running):

    # Create an OpenOCD command file
    cat <<\<EOF\> > openocd.cfg
    interface remote_bitbang
    remote_bitbang_host localhost
    remote_bitbang_port 9823
    set _CHIPNAME riscv
    jtag newtap $_CHIPNAME cpu -irlen 5 -expected-id 0x10e31913
    set _TARGETNAME $_CHIPNAME.cpu
    target create $_TARGETNAME riscv -chain-position $_TARGETNAME
    init
    halt
    <EOF>
    
    # Connect OpenOCD to simulation
    openocd -f openocd.cfg

The simulation remote bitbang server gets closed when the simulation finishes
(either on timeout, or by Verilog's `$finish`), or by closing the connection
from the OpenOCD session (which will in turn quit the simulation).

Once the simulation is running and OpenOCD is connected, you may use GDB to
connect to and debug the simulated target:

    # Here `gdb` comes from a RISC-V toolchain
    gdb <elf-running-on-the-target>
    
    (gdb) target remote localhost:3333
    (gdb) ...

