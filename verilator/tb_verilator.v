/*
Copyright 2018 Tomas Brabec
Copyright 2017 Silicon Integrated Microelectronics, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Changelog:

  2018, Aug, Tomas Brabec
  - Modified the testbench to work with Verilator (i.e. used only synthesis
    like syntax). This also included using the same clock for `hfextclk` and
    `lfextclk`.
  - Commented out error injection.
  - Simple SPI flash model along with option (`BOOTROM=1`) to execute code from
    there. As RAM and Flash have base addresses different in the most significant
    byte, that byte is ignored in PC (program counter) for detecting an ISA test
    binary reaching certain point in the test program.

*/

`include "e203_defines.v"

module tb_verilator(

  input wire  clk,
  input wire  rst_n,

  input  logic tdi,
  output logic tdo,
  output logic tdo_oe,
  input  logic tck,
  input  logic tms,
  input  logic trstn,

  input  logic quit
  );

  // finish simulation on `quit` going high
  always @(posedge quit) begin
      $display("Simulation indicated to quit ...");
      $finish();
  end

  `define CPU_TOP u_e203_soc_top.u_e203_subsys_top.u_e203_subsys_main.u_e203_cpu_top
  `define EXU `CPU_TOP.u_e203_cpu.u_e203_core.u_e203_exu
  `define ITCM `CPU_TOP.u_e203_srams.u_e203_itcm_ram.u_e203_itcm_gnrl_ram.u_sirv_sim_ram

  `define PC_WRITE_TOHOST       `E203_PC_SIZE'h00000086
  `define PC_EXT_IRQ_BEFOR_MRET `E203_PC_SIZE'h000000a6
  `define PC_SFT_IRQ_BEFOR_MRET `E203_PC_SIZE'h000000be
  `define PC_TMR_IRQ_BEFOR_MRET `E203_PC_SIZE'h000000d6
  `define PC_AFTER_SETMTVEC     `E203_PC_SIZE'h0000015C

  wire [`E203_XLEN-1:0] x3 = `EXU.u_e203_exu_regfile.rf_r[3];
  wire [`E203_PC_SIZE-1:0] pc = `EXU.u_e203_exu_commit.alu_cmt_i_pc;
  wire [`E203_PC_SIZE-1:0] pc_vld = `EXU.u_e203_exu_commit.alu_cmt_i_valid;

  reg [31:0] pc_write_to_host_cnt;
  reg [31:0] pc_write_to_host_cycle;
  reg [31:0] valid_ir_cycle;
  reg [31:0] cycle_count;
  reg pc_write_to_host_flag;

  always @(posedge clk or negedge rst_n)
  begin 
    if(rst_n == 1'b0) begin
        pc_write_to_host_cnt <= 32'b0;
        pc_write_to_host_flag <= 1'b0;
        pc_write_to_host_cycle <= 32'b0;
    end
    else if (pc_vld & (pc[27:0] == `PC_WRITE_TOHOST)) begin
        pc_write_to_host_cnt <= pc_write_to_host_cnt + 1'b1;
        pc_write_to_host_flag <= 1'b1;
        if (pc_write_to_host_flag == 1'b0) begin
            pc_write_to_host_cycle <= cycle_count;
        end
    end
  end

  always @(posedge clk or negedge rst_n)
  begin 
    if(rst_n == 1'b0) begin
        cycle_count <= 32'b0;
    end
    else begin
        cycle_count <= cycle_count + 1'b1;
    end
  end

  wire i_valid = `EXU.i_valid;
  wire i_ready = `EXU.i_ready;

  always @(posedge clk or negedge rst_n)
  begin 
    if(rst_n == 1'b0) begin
        valid_ir_cycle <= 32'b0;
    end
    else if(i_valid & i_ready & (pc_write_to_host_flag == 1'b0)) begin
        valid_ir_cycle <= valid_ir_cycle + 1'b1;
    end
  end

//`ifdef ENABLE_TB_FORCE
//
//  // Randomly force the external interrupt
//  `define EXT_IRQ u_e203_soc_top.u_e203_subsys_top.u_e203_subsys_main.plic_ext_irq
//  `define SFT_IRQ u_e203_soc_top.u_e203_subsys_top.u_e203_subsys_main.clint_sft_irq
//  `define TMR_IRQ u_e203_soc_top.u_e203_subsys_top.u_e203_subsys_main.clint_tmr_irq
//
//  `define U_CPU u_e203_soc_top.u_e203_subsys_top.u_e203_subsys_main.u_e203_cpu_top.u_e203_cpu
//  `define ITCM_BUS_ERR `U_CPU.u_e203_itcm_ctrl.sram_icb_rsp_err
//  `define ITCM_BUS_READ `U_CPU.u_e203_itcm_ctrl.sram_icb_rsp_read
//  `define STATUS_MIE   `U_CPU.u_e203_core.u_e203_exu.u_e203_exu_commit.u_e203_exu_excp.status_mie_r
//
//
//  wire stop_assert_irq = (pc_write_to_host_cnt > 32);
//
//  reg tb_itcm_bus_err;
//
//  reg tb_ext_irq;
//  reg tb_tmr_irq;
//  reg tb_sft_irq;
//  initial begin
//    tb_ext_irq = 1'b0;
//    tb_tmr_irq = 1'b0;
//    tb_sft_irq = 1'b0;
//  end
//  initial begin
//    tb_itcm_bus_err = 1'b0;
//    #100
//    @(pc[27:0] == `PC_AFTER_SETMTVEC ) // Wait the program goes out the reset_vector program
//    forever begin
//      repeat ($urandom_range(1, 20)) @(posedge clk) tb_itcm_bus_err = 1'b0; // Wait random times
//      repeat ($urandom_range(1, 200)) @(posedge clk) tb_itcm_bus_err = 1'b1; // Wait random times
//      if(stop_assert_irq) begin
//          break;
//      end
//    end
//  end
//
//
//  initial begin
//    force `EXT_IRQ = tb_ext_irq;
//    force `SFT_IRQ = tb_sft_irq;
//    force `TMR_IRQ = tb_tmr_irq;
//       // We force the bus-error only when:
//       //   It is in common code, not in exception code, by checking MIE bit
//       //   It is in read operation, not write, otherwise the test cannot recover
//    force `ITCM_BUS_ERR = tb_itcm_bus_err
//                        & `STATUS_MIE 
//                        & `ITCM_BUS_READ
//                        ;
//  end
//
//
//  initial begin
//    #100
//    @(pc[27:0] == `PC_AFTER_SETMTVEC ) // Wait the program goes out the reset_vector program
//    forever begin
//      repeat ($urandom_range(1, 1000)) @(posedge clk) tb_ext_irq = 1'b0; // Wait random times
//      tb_ext_irq = 1'b1; // assert the irq
//      @((pc[27:0] == `PC_EXT_IRQ_BEFOR_MRET)) // Wait the program run into the IRQ handler by check PC values
//      tb_ext_irq = 1'b0;
//      if(stop_assert_irq) begin
//          break;
//      end
//    end
//  end
//
//  initial begin
//    #100
//    @(pc[27:0] == `PC_AFTER_SETMTVEC ) // Wait the program goes out the reset_vector program
//    forever begin
//      repeat ($urandom_range(1, 1000)) @(posedge clk) tb_sft_irq = 1'b0; // Wait random times
//      tb_sft_irq = 1'b1; // assert the irq
//      @((pc[27:0] == `PC_SFT_IRQ_BEFOR_MRET)) // Wait the program run into the IRQ handler by check PC values
//      tb_sft_irq = 1'b0;
//      if(stop_assert_irq) begin
//          break;
//      end
//    end
//  end
//
////---->>>>
//  initial begin
//    #100
//    @(pc[27:0] == `PC_AFTER_SETMTVEC ) // Wait the program goes out the reset_vector program
//    forever begin
//      repeat ($urandom_range(1, 1000)) @(posedge clk) tb_tmr_irq = 1'b0; // Wait random times
//      tb_tmr_irq = 1'b1; // assert the irq
//      @((pc[27:0] == `PC_TMR_IRQ_BEFOR_MRET)) // Wait the program run into the IRQ handler by check PC values
//      tb_tmr_irq = 1'b0;
//      if(stop_assert_irq) begin
//          break;
//      end
//    end
//  end
//
////  reg cpu_out_of_rst = 1'b0;
////
////  always @(posedge clk or negedge rst_n) begin
////	  if (!rst_n)
////		  cpu_out_of_rst <= 1'b0;
////	  else if (pc == `PC_AFTER_SERMTVEC)
////		  cpu_out_of_rst <= 1'b1;
////  end
////<<<<----
//`endif

  reg[8*64:1] testcase;
//  integer dumpwave;

  integer bootrom_n;

  always  @(pc_write_to_host_cnt) begin
	  if (pc_write_to_host_cnt == 32'd8) begin
//`ifdef ENABLE_TB_FORCE
//    @((~tb_tmr_irq) & (~tb_sft_irq) & (~tb_ext_irq)) #10 rst_n <=1;// Wait the interrupt to complete
//`endif

        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~ Test Result Summary ~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~TESTCASE: %s ~~~~~~~~~~~~~", testcase);
        $display("~BOOT: %0s ~~~~~~~~~~~~~", bootrom_n ? "Flash" : "RAM" );
        $display("~~~~~~~~~~~~~~Total cycle_count value: %d ~~~~~~~~~~~~~", cycle_count);
        $display("~~~~~~~~~~The valid Instruction Count: %d ~~~~~~~~~~~~~", valid_ir_cycle);
        $display("~~~~~The test ending reached at cycle: %d ~~~~~~~~~~~~~", pc_write_to_host_cycle);
        $display("~~~~~~~~~~~~~~~The final x3 Reg value: %d ~~~~~~~~~~~~~", x3);
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    if (x3 == 1) begin
        $display("~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    end
    else begin
        $display("~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~~~~~~~");
        $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    end
    $finish;
    end
  end

  // watchdog
  always @(posedge clk) begin
    if (cycle_count[20] == 1'b1) begin
      $error("Time Out !!!");
      $finish;
    end
  end



  
  
//  initial begin
//    $value$plusargs("DUMPWAVE=%d",dumpwave);
//    if(dumpwave != 0)begin
//         // To add your waveform generation function
//    end
//  end





  integer i;

    reg [7:0] itcm_mem [0:(`E203_ITCM_RAM_DP*8)-1];

    initial begin
      $display("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");  
      if($value$plusargs("TESTCASE=%s",testcase))begin
        $display("TESTCASE=%s",testcase);
      end
      else begin
	      $fatal(1,"No TESTCASE defined!");
	      $finish;
      end

      if(!$value$plusargs("BOOTROM=%d",bootrom_n))
        bootrom_n = 0;
      $display("BOOTROM=%b", bootrom_n != 0);

      if (bootrom_n != 0) begin
        u_spi_dev.load_file({testcase,".verilog"});
      end
      else begin
        u_spi_dev.mem_set(0,8'haa);
        u_spi_dev.mem_set(1,8'h55);
        u_spi_dev.mem_set(2,8'h81);
        u_spi_dev.mem_set(3,8'h0f);

          $readmemh({testcase, ".verilog"}, itcm_mem);

          for (i=0;i<(`E203_ITCM_RAM_DP);i=i+1) begin
              `ITCM.mem_r[i][00+7:00] = itcm_mem[i*8+0];
              `ITCM.mem_r[i][08+7:08] = itcm_mem[i*8+1];
              `ITCM.mem_r[i][16+7:16] = itcm_mem[i*8+2];
              `ITCM.mem_r[i][24+7:24] = itcm_mem[i*8+3];
              `ITCM.mem_r[i][32+7:32] = itcm_mem[i*8+4];
              `ITCM.mem_r[i][40+7:40] = itcm_mem[i*8+5];
              `ITCM.mem_r[i][48+7:48] = itcm_mem[i*8+6];
              `ITCM.mem_r[i][56+7:56] = itcm_mem[i*8+7];
          end

            $display("ITCM 0x00: %h", `ITCM.mem_r[8'h00]);
            $display("ITCM 0x01: %h", `ITCM.mem_r[8'h01]);
            $display("ITCM 0x02: %h", `ITCM.mem_r[8'h02]);
            $display("ITCM 0x03: %h", `ITCM.mem_r[8'h03]);
            $display("ITCM 0x04: %h", `ITCM.mem_r[8'h04]);
            $display("ITCM 0x05: %h", `ITCM.mem_r[8'h05]);
            $display("ITCM 0x06: %h", `ITCM.mem_r[8'h06]);
            $display("ITCM 0x07: %h", `ITCM.mem_r[8'h07]);
            $display("ITCM 0x16: %h", `ITCM.mem_r[8'h16]);
            $display("ITCM 0x20: %h", `ITCM.mem_r[8'h20]);
      end
    end 


wire sck;
wire spi_cs_n;
wire [3:0] spi_dq;
wire [3:0] spi_dut_dq_o;
wire [3:0] spi_dut_dq_oe;
wire [3:0] spi_dev_dq_o;
wire [3:0] spi_dev_dq_t;

wire uart_txd;

wire [31:0] gpio_ival;
wire [31:0] gpio_oval;
wire [31:0] gpio_oe;
wire [31:0] gpio_ie;
wire [31:0] gpio_pue;
wire [31:0] gpio_ds;
wire [31:0] gpio_ival_default;

assign uart_txd = gpio_oval[17];
assign gpio_ival_default = { {15{1'b1}}, uart_txd, {16{1'b1}} };

for (genvar i=0; i < 32; i++) begin
    assign gpio_ival[i] = (gpio_ds[i] & ~gpio_pue[i]) ? gpio_oval[i] : gpio_ival_default[i];
end

e203_soc_top u_e203_soc_top(
   
   .hfextclk(clk),
   .hfxoscen(),

   .lfextclk(clk),
   .lfxoscen(),

   .io_pads_jtag_TCK_i_ival (tck),
   .io_pads_jtag_TMS_i_ival (tms),
   .io_pads_jtag_TDI_i_ival (tdi),
   .io_pads_jtag_TDO_o_oval (tdo),
   .io_pads_jtag_TDO_o_oe (tdo_oe),
   .io_pads_gpio_0_i_ival   (gpio_ival[0]),
   .io_pads_gpio_0_o_oval   (gpio_oval[0]),
   .io_pads_gpio_0_o_oe     (gpio_oe  [0]),
   .io_pads_gpio_0_o_ie     (gpio_ie  [0]),
   .io_pads_gpio_0_o_pue    (gpio_pue [0]),
   .io_pads_gpio_0_o_ds     (gpio_ds  [0]),
   .io_pads_gpio_1_i_ival   (gpio_ival[1]),
   .io_pads_gpio_1_o_oval   (gpio_oval[1]),
   .io_pads_gpio_1_o_oe     (gpio_oe  [1]),
   .io_pads_gpio_1_o_ie     (gpio_ie  [1]),
   .io_pads_gpio_1_o_pue    (gpio_pue [1]),
   .io_pads_gpio_1_o_ds     (gpio_ds  [1]),
   .io_pads_gpio_2_i_ival   (gpio_ival[2]),
   .io_pads_gpio_2_o_oval   (gpio_oval[2]),
   .io_pads_gpio_2_o_oe     (gpio_oe  [2]),
   .io_pads_gpio_2_o_ie     (gpio_ie  [2]),
   .io_pads_gpio_2_o_pue    (gpio_pue [2]),
   .io_pads_gpio_2_o_ds     (gpio_ds  [2]),
   .io_pads_gpio_3_i_ival   (gpio_ival[3]),
   .io_pads_gpio_3_o_oval   (gpio_oval[3]),
   .io_pads_gpio_3_o_oe     (gpio_oe  [3]),
   .io_pads_gpio_3_o_ie     (gpio_ie  [3]),
   .io_pads_gpio_3_o_pue    (gpio_pue [3]),
   .io_pads_gpio_3_o_ds     (gpio_ds  [3]),
   .io_pads_gpio_4_i_ival   (gpio_ival[4]),
   .io_pads_gpio_4_o_oval   (gpio_oval[4]),
   .io_pads_gpio_4_o_oe     (gpio_oe  [4]),
   .io_pads_gpio_4_o_ie     (gpio_ie  [4]),
   .io_pads_gpio_4_o_pue    (gpio_pue [4]),
   .io_pads_gpio_4_o_ds     (gpio_ds  [4]),
   .io_pads_gpio_5_i_ival   (gpio_ival[5]),
   .io_pads_gpio_5_o_oval   (gpio_oval[5]),
   .io_pads_gpio_5_o_oe     (gpio_oe  [5]),
   .io_pads_gpio_5_o_ie     (gpio_ie  [5]),
   .io_pads_gpio_5_o_pue    (gpio_pue [5]),
   .io_pads_gpio_5_o_ds     (gpio_ds  [5]),
   .io_pads_gpio_6_i_ival   (gpio_ival[6]),
   .io_pads_gpio_6_o_oval   (gpio_oval[6]),
   .io_pads_gpio_6_o_oe     (gpio_oe  [6]),
   .io_pads_gpio_6_o_ie     (gpio_ie  [6]),
   .io_pads_gpio_6_o_pue    (gpio_pue [6]),
   .io_pads_gpio_6_o_ds     (gpio_ds  [6]),
   .io_pads_gpio_7_i_ival   (gpio_ival[7]),
   .io_pads_gpio_7_o_oval   (gpio_oval[7]),
   .io_pads_gpio_7_o_oe     (gpio_oe  [7]),
   .io_pads_gpio_7_o_ie     (gpio_ie  [7]),
   .io_pads_gpio_7_o_pue    (gpio_pue [7]),
   .io_pads_gpio_7_o_ds     (gpio_ds  [7]),
   .io_pads_gpio_8_i_ival   (gpio_ival[8]),
   .io_pads_gpio_8_o_oval   (gpio_oval[8]),
   .io_pads_gpio_8_o_oe     (gpio_oe  [8]),
   .io_pads_gpio_8_o_ie     (gpio_ie  [8]),
   .io_pads_gpio_8_o_pue    (gpio_pue [8]),
   .io_pads_gpio_8_o_ds     (gpio_ds  [8]),
   .io_pads_gpio_9_i_ival   (gpio_ival[9]),
   .io_pads_gpio_9_o_oval   (gpio_oval[9]),
   .io_pads_gpio_9_o_oe     (gpio_oe  [9]),
   .io_pads_gpio_9_o_ie     (gpio_ie  [9]),
   .io_pads_gpio_9_o_pue    (gpio_pue [9]),
   .io_pads_gpio_9_o_ds     (gpio_ds  [9]),
   .io_pads_gpio_10_i_ival  (gpio_ival[10]),
   .io_pads_gpio_10_o_oval  (gpio_oval[10]),
   .io_pads_gpio_10_o_oe    (gpio_oe  [10]),
   .io_pads_gpio_10_o_ie    (gpio_ie  [10]),
   .io_pads_gpio_10_o_pue   (gpio_pue [10]),
   .io_pads_gpio_10_o_ds    (gpio_ds  [10]),
   .io_pads_gpio_11_i_ival  (gpio_ival[11]),
   .io_pads_gpio_11_o_oval  (gpio_oval[11]),
   .io_pads_gpio_11_o_oe    (gpio_oe  [11]),
   .io_pads_gpio_11_o_ie    (gpio_ie  [11]),
   .io_pads_gpio_11_o_pue   (gpio_pue [11]),
   .io_pads_gpio_11_o_ds    (gpio_ds  [11]),
   .io_pads_gpio_12_i_ival  (gpio_ival[12]),
   .io_pads_gpio_12_o_oval  (gpio_oval[12]),
   .io_pads_gpio_12_o_oe    (gpio_oe  [12]),
   .io_pads_gpio_12_o_ie    (gpio_ie  [12]),
   .io_pads_gpio_12_o_pue   (gpio_pue [12]),
   .io_pads_gpio_12_o_ds    (gpio_ds  [12]),
   .io_pads_gpio_13_i_ival  (gpio_ival[13]),
   .io_pads_gpio_13_o_oval  (gpio_oval[13]),
   .io_pads_gpio_13_o_oe    (gpio_oe  [13]),
   .io_pads_gpio_13_o_ie    (gpio_ie  [13]),
   .io_pads_gpio_13_o_pue   (gpio_pue [13]),
   .io_pads_gpio_13_o_ds    (gpio_ds  [13]),
   .io_pads_gpio_14_i_ival  (gpio_ival[14]),
   .io_pads_gpio_14_o_oval  (gpio_oval[14]),
   .io_pads_gpio_14_o_oe    (gpio_oe  [14]),
   .io_pads_gpio_14_o_ie    (gpio_ie  [14]),
   .io_pads_gpio_14_o_pue   (gpio_pue [14]),
   .io_pads_gpio_14_o_ds    (gpio_ds  [14]),
   .io_pads_gpio_15_i_ival  (gpio_ival[15]),
   .io_pads_gpio_15_o_oval  (gpio_oval[15]),
   .io_pads_gpio_15_o_oe    (gpio_oe  [15]),
   .io_pads_gpio_15_o_ie    (gpio_ie  [15]),
   .io_pads_gpio_15_o_pue   (gpio_pue [15]),
   .io_pads_gpio_15_o_ds    (gpio_ds  [15]),
   .io_pads_gpio_16_i_ival  (gpio_ival[16]),
   .io_pads_gpio_16_o_oval  (gpio_oval[16]),
   .io_pads_gpio_16_o_oe    (gpio_oe  [16]),
   .io_pads_gpio_16_o_ie    (gpio_ie  [16]),
   .io_pads_gpio_16_o_pue   (gpio_pue [16]),
   .io_pads_gpio_16_o_ds    (gpio_ds  [16]),
   .io_pads_gpio_17_i_ival  (gpio_ival[17]),
   .io_pads_gpio_17_o_oval  (gpio_oval[17]),
   .io_pads_gpio_17_o_oe    (gpio_oe  [17]),
   .io_pads_gpio_17_o_ie    (gpio_ie  [17]),
   .io_pads_gpio_17_o_pue   (gpio_pue [17]),
   .io_pads_gpio_17_o_ds    (gpio_ds  [17]),
   .io_pads_gpio_18_i_ival  (gpio_ival[18]),
   .io_pads_gpio_18_o_oval  (gpio_oval[18]),
   .io_pads_gpio_18_o_oe    (gpio_oe  [18]),
   .io_pads_gpio_18_o_ie    (gpio_ie  [18]),
   .io_pads_gpio_18_o_pue   (gpio_pue [18]),
   .io_pads_gpio_18_o_ds    (gpio_ds  [18]),
   .io_pads_gpio_19_i_ival  (gpio_ival[19]),
   .io_pads_gpio_19_o_oval  (gpio_oval[19]),
   .io_pads_gpio_19_o_oe    (gpio_oe  [19]),
   .io_pads_gpio_19_o_ie    (gpio_ie  [19]),
   .io_pads_gpio_19_o_pue   (gpio_pue [19]),
   .io_pads_gpio_19_o_ds    (gpio_ds  [19]),
   .io_pads_gpio_20_i_ival  (gpio_ival[20]),
   .io_pads_gpio_20_o_oval  (gpio_oval[20]),
   .io_pads_gpio_20_o_oe    (gpio_oe  [20]),
   .io_pads_gpio_20_o_ie    (gpio_ie  [20]),
   .io_pads_gpio_20_o_pue   (gpio_pue [20]),
   .io_pads_gpio_20_o_ds    (gpio_ds  [20]),
   .io_pads_gpio_21_i_ival  (gpio_ival[21]),
   .io_pads_gpio_21_o_oval  (gpio_oval[21]),
   .io_pads_gpio_21_o_oe    (gpio_oe  [21]),
   .io_pads_gpio_21_o_ie    (gpio_ie  [21]),
   .io_pads_gpio_21_o_pue   (gpio_pue [21]),
   .io_pads_gpio_21_o_ds    (gpio_ds  [21]),
   .io_pads_gpio_22_i_ival  (gpio_ival[22]),
   .io_pads_gpio_22_o_oval  (gpio_oval[22]),
   .io_pads_gpio_22_o_oe    (gpio_oe  [22]),
   .io_pads_gpio_22_o_ie    (gpio_ie  [22]),
   .io_pads_gpio_22_o_pue   (gpio_pue [22]),
   .io_pads_gpio_22_o_ds    (gpio_ds  [22]),
   .io_pads_gpio_23_i_ival  (gpio_ival[23]),
   .io_pads_gpio_23_o_oval  (gpio_oval[23]),
   .io_pads_gpio_23_o_oe    (gpio_oe  [23]),
   .io_pads_gpio_23_o_ie    (gpio_ie  [23]),
   .io_pads_gpio_23_o_pue   (gpio_pue [23]),
   .io_pads_gpio_23_o_ds    (gpio_ds  [23]),
   .io_pads_gpio_24_i_ival  (gpio_ival[24]),
   .io_pads_gpio_24_o_oval  (gpio_oval[24]),
   .io_pads_gpio_24_o_oe    (gpio_oe  [24]),
   .io_pads_gpio_24_o_ie    (gpio_ie  [24]),
   .io_pads_gpio_24_o_pue   (gpio_pue [24]),
   .io_pads_gpio_24_o_ds    (gpio_ds  [24]),
   .io_pads_gpio_25_i_ival  (gpio_ival[25]),
   .io_pads_gpio_25_o_oval  (gpio_oval[25]),
   .io_pads_gpio_25_o_oe    (gpio_oe  [25]),
   .io_pads_gpio_25_o_ie    (gpio_ie  [25]),
   .io_pads_gpio_25_o_pue   (gpio_pue [25]),
   .io_pads_gpio_25_o_ds    (gpio_ds  [25]),
   .io_pads_gpio_26_i_ival  (gpio_ival[26]),
   .io_pads_gpio_26_o_oval  (gpio_oval[26]),
   .io_pads_gpio_26_o_oe    (gpio_oe  [26]),
   .io_pads_gpio_26_o_ie    (gpio_ie  [26]),
   .io_pads_gpio_26_o_pue   (gpio_pue [26]),
   .io_pads_gpio_26_o_ds    (gpio_ds  [26]),
   .io_pads_gpio_27_i_ival  (gpio_ival[27]),
   .io_pads_gpio_27_o_oval  (gpio_oval[27]),
   .io_pads_gpio_27_o_oe    (gpio_oe  [27]),
   .io_pads_gpio_27_o_ie    (gpio_ie  [27]),
   .io_pads_gpio_27_o_pue   (gpio_pue [27]),
   .io_pads_gpio_27_o_ds    (gpio_ds  [27]),
   .io_pads_gpio_28_i_ival  (gpio_ival[28]),
   .io_pads_gpio_28_o_oval  (gpio_oval[28]),
   .io_pads_gpio_28_o_oe    (gpio_oe  [28]),
   .io_pads_gpio_28_o_ie    (gpio_ie  [28]),
   .io_pads_gpio_28_o_pue   (gpio_pue [28]),
   .io_pads_gpio_28_o_ds    (gpio_ds  [28]),
   .io_pads_gpio_29_i_ival  (gpio_ival[29]),
   .io_pads_gpio_29_o_oval  (gpio_oval[29]),
   .io_pads_gpio_29_o_oe    (gpio_oe  [29]),
   .io_pads_gpio_29_o_ie    (gpio_ie  [29]),
   .io_pads_gpio_29_o_pue   (gpio_pue [29]),
   .io_pads_gpio_29_o_ds    (gpio_ds  [29]),
   .io_pads_gpio_30_i_ival  (gpio_ival[30]),
   .io_pads_gpio_30_o_oval  (gpio_oval[30]),
   .io_pads_gpio_30_o_oe    (gpio_oe  [30]),
   .io_pads_gpio_30_o_ie    (gpio_ie  [30]),
   .io_pads_gpio_30_o_pue   (gpio_pue [30]),
   .io_pads_gpio_30_o_ds    (gpio_ds  [30]),
   .io_pads_gpio_31_i_ival  (gpio_ival[31]),
   .io_pads_gpio_31_o_oval  (gpio_oval[31]),
   .io_pads_gpio_31_o_oe    (gpio_oe  [31]),
   .io_pads_gpio_31_o_ie    (gpio_ie  [31]),
   .io_pads_gpio_31_o_pue   (gpio_pue [31]),
   .io_pads_gpio_31_o_ds    (gpio_ds  [31]),

   .io_pads_qspi_sck_o_oval (sck),
   .io_pads_qspi_dq_0_i_ival (spi_dq[0]),
   .io_pads_qspi_dq_0_o_oval (spi_dut_dq_o[0]),
   .io_pads_qspi_dq_0_o_oe (spi_dut_dq_oe[0]),
   .io_pads_qspi_dq_0_o_ie (),
   .io_pads_qspi_dq_0_o_pue (),
   .io_pads_qspi_dq_0_o_ds (),
   .io_pads_qspi_dq_1_i_ival (spi_dq[1]),
   .io_pads_qspi_dq_1_o_oval (spi_dut_dq_o[1]),
   .io_pads_qspi_dq_1_o_oe (spi_dut_dq_oe[1]),
   .io_pads_qspi_dq_1_o_ie (),
   .io_pads_qspi_dq_1_o_pue (),
   .io_pads_qspi_dq_1_o_ds (),
   .io_pads_qspi_dq_2_i_ival (spi_dq[2]),
   .io_pads_qspi_dq_2_o_oval (spi_dut_dq_o[2]),
   .io_pads_qspi_dq_2_o_oe (spi_dut_dq_oe[2]),
   .io_pads_qspi_dq_2_o_ie (),
   .io_pads_qspi_dq_2_o_pue (),
   .io_pads_qspi_dq_2_o_ds (),
   .io_pads_qspi_dq_3_i_ival (spi_dq[3]),
   .io_pads_qspi_dq_3_o_oval (spi_dut_dq_o[3]),
   .io_pads_qspi_dq_3_o_oe (spi_dut_dq_oe[3]),
   .io_pads_qspi_dq_3_o_ie (),
   .io_pads_qspi_dq_3_o_pue (),
   .io_pads_qspi_dq_3_o_ds (),
   .io_pads_qspi_cs_0_o_oval (spi_cs_n),
   .io_pads_aon_erst_n_i_ival (rst_n),//This is the real reset, active low
   .io_pads_aon_pmu_dwakeup_n_i_ival (1'b1),

   .io_pads_aon_pmu_vddpaden_o_oval (),
    .io_pads_aon_pmu_padrst_o_oval    (),

    .io_pads_bootrom_n_i_ival       (bootrom_n != 0),// 0=boot from ROM, 1=boot from SPI Flash
    .io_pads_dbgmode0_n_i_ival       (1'b1),
    .io_pads_dbgmode1_n_i_ival       (1'b1),
    .io_pads_dbgmode2_n_i_ival       (1'b1) 
);

for (genvar i=0; i<4; i++) begin
    assign spi_dq[i] = spi_dut_dq_oe[i] ? spi_dut_dq_o[i] : 1'bz;
    assign spi_dq[i] = spi_dev_dq_t[i] ? 1'bz : spi_dev_dq_o[i];
end

spi_model#(.SIZE(2**16)) u_spi_dev(
    .sck(sck),
    .rst_n(rst_n),
    .cs_n(spi_cs_n),
    .dq_i(spi_dq),
    .dq_o(spi_dev_dq_o),
    .dq_t(spi_dev_dq_t)
);

endmodule
