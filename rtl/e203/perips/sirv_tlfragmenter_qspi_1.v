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

 Change log:

   2018, Aug, Tomas Brabec
   - Code cleanup (unused nets, transitive assignments, constant assignments).
   - Removed unused TileLink channels (B,C,E).

 */                                                                      
                                                                         
                                                                         
                                                                         

module sirv_tlfragmenter_qspi_1(
  input   clock,
  input   reset,
  output  io_in_0_a_ready,
  input   io_in_0_a_valid,
  input  [2:0] io_in_0_a_bits_opcode,
  input  [2:0] io_in_0_a_bits_param,
  input  [2:0] io_in_0_a_bits_size,
  input  [1:0] io_in_0_a_bits_source,
  input  [29:0] io_in_0_a_bits_address,
  input   io_in_0_a_bits_mask,
  input  [7:0] io_in_0_a_bits_data,
  input   io_in_0_d_ready,
  output  io_in_0_d_valid,
  output [2:0] io_in_0_d_bits_opcode,
  output [1:0] io_in_0_d_bits_param,
  output [2:0] io_in_0_d_bits_size,
  output [1:0] io_in_0_d_bits_source,
  output  io_in_0_d_bits_sink,
  output  io_in_0_d_bits_addr_lo,
  output [7:0] io_in_0_d_bits_data,
  output  io_in_0_d_bits_error,
  input   io_out_0_a_ready,
  output  io_out_0_a_valid,
  output [2:0] io_out_0_a_bits_opcode,
  output [2:0] io_out_0_a_bits_param,
  output [2:0] io_out_0_a_bits_size,
  output [6:0] io_out_0_a_bits_source,
  output [29:0] io_out_0_a_bits_address,
  output  io_out_0_a_bits_mask,
  output [7:0] io_out_0_a_bits_data,
  output  io_out_0_d_ready,
  input   io_out_0_d_valid,
  input  [2:0] io_out_0_d_bits_opcode,
  input  [1:0] io_out_0_d_bits_param,
  input  [2:0] io_out_0_d_bits_size,
  input  [6:0] io_out_0_d_bits_source,
  input   io_out_0_d_bits_sink,
  input   io_out_0_d_bits_addr_lo,
  input  [7:0] io_out_0_d_bits_data,
  input   io_out_0_d_bits_error
);
  reg [4:0] acknum;
  reg [2:0] dOrig;
  wire  dFirst;
  wire [7:0] T_1410;
  wire  dsizeOH1;
  wire [4:0] GEN_5;
  wire [4:0] dFirst_acknum;
  wire [5:0] T_1430;
  wire [5:0] T_1432;
  wire [5:0] T_1433;
  wire [5:0] T_1434;
  wire  T_1438;
  wire [3:0] GEN_9;
  wire [3:0] T_1439;
  wire  T_1443;
  wire [1:0] T_1444;
  wire [1:0] T_1446;
  wire [2:0] dFirst_size;
  wire  T_1447;
  wire  repeater_io_full;
  wire  repeater_io_enq_ready;
  wire  repeater_io_deq_valid;
  wire [2:0] repeater_io_deq_bits_opcode;
  wire [2:0] repeater_io_deq_bits_param;
  wire [2:0] repeater_io_deq_bits_size;
  wire [1:0] repeater_io_deq_bits_source;
  wire [29:0] repeater_io_deq_bits_address;
  wire  repeater_io_deq_bits_mask;
  wire [7:0] repeater_io_deq_bits_data;
  wire  T_1494;
  wire [2:0] aFrag;
  wire [11:0] T_1497;
  wire [4:0] aOrigOH1;
  wire T_1501;
  wire  aFragOH1;
  reg [4:0] gennum;
  wire  aFirst;
  wire [4:0] old_gennum1;
  wire [4:0] new_gennum;
  wire  io_repeat;
  wire [4:0] T_1528;
  sirv_repeater_6 u_repeater (
    .clock(clock),
    .reset(reset),
    .io_repeat(io_repeat),
    .io_full(repeater_io_full),
    .io_enq_ready(repeater_io_enq_ready),
    .io_enq_valid(io_in_0_a_valid),
    .io_enq_bits_opcode(io_in_0_a_bits_opcode),
    .io_enq_bits_param(io_in_0_a_bits_param),
    .io_enq_bits_size(io_in_0_a_bits_size),
    .io_enq_bits_source(io_in_0_a_bits_source),
    .io_enq_bits_address(io_in_0_a_bits_address),
    .io_enq_bits_mask(io_in_0_a_bits_mask),
    .io_enq_bits_data(io_in_0_a_bits_data),
    .io_deq_ready(io_out_0_a_ready),
    .io_deq_valid(repeater_io_deq_valid),
    .io_deq_bits_opcode(repeater_io_deq_bits_opcode),
    .io_deq_bits_param(repeater_io_deq_bits_param),
    .io_deq_bits_size(repeater_io_deq_bits_size),
    .io_deq_bits_source(repeater_io_deq_bits_source),
    .io_deq_bits_address(repeater_io_deq_bits_address),
    .io_deq_bits_mask(repeater_io_deq_bits_mask),
    .io_deq_bits_data(repeater_io_deq_bits_data)
  );
  assign io_in_0_a_ready = repeater_io_enq_ready;
  assign io_in_0_d_valid = io_out_0_d_valid;
  assign io_in_0_d_bits_opcode = io_out_0_d_bits_opcode;
  assign io_in_0_d_bits_param = io_out_0_d_bits_param;
  assign io_in_0_d_bits_size = (dFirst ? dFirst_size : dOrig);
  assign io_in_0_d_bits_source = io_out_0_d_bits_source[6:5];
  assign io_in_0_d_bits_sink = io_out_0_d_bits_sink;
  assign io_in_0_d_bits_addr_lo = (io_out_0_d_bits_addr_lo & (~ dsizeOH1));
  assign io_in_0_d_bits_data = io_out_0_d_bits_data;
  assign io_in_0_d_bits_error = io_out_0_d_bits_error;
  assign io_out_0_a_valid = repeater_io_deq_valid;
  assign io_out_0_a_bits_opcode = repeater_io_deq_bits_opcode;
  assign io_out_0_a_bits_param = repeater_io_deq_bits_param;
  assign io_out_0_a_bits_size = aFrag;
  assign io_out_0_a_bits_source = ({repeater_io_deq_bits_source,new_gennum});
  assign io_out_0_a_bits_address = repeater_io_deq_bits_address | {25'd0, T_1528};
  assign io_out_0_a_bits_mask = (repeater_io_full ? 1'h1 : io_in_0_a_bits_mask);
  assign io_out_0_a_bits_data = io_in_0_a_bits_data;
  assign io_out_0_d_ready = io_in_0_d_ready;
  assign dFirst = acknum == 5'h0;
  assign dsizeOH1 = ~(8'h1 << io_out_0_d_bits_size);
  assign GEN_5 = {4'd0, dsizeOH1};
  assign dFirst_acknum = io_out_0_d_bits_source[4:0] | GEN_5;
  assign T_1430 = {dFirst_acknum,1'b1};
  assign T_1432 = {1'h0,dFirst_acknum};
  assign T_1433 = ~ T_1432;
  assign T_1434 = T_1430 & T_1433;
  assign T_1438 = T_1434[5:4] != 2'h0;
  assign GEN_9 = {2'd0, T_1434[5:4]};
  assign T_1439 = GEN_9 | T_1434[3:0];
  assign T_1443 = T_1439[3:2] != 2'h0;
  assign T_1444 = T_1439[3:2] | T_1439[1:0];
  assign T_1446 = {T_1443,T_1444[1]};
  assign dFirst_size = {T_1438,T_1446};
  assign T_1447 = io_out_0_d_ready & io_out_0_d_valid;
  assign T_1494 = repeater_io_deq_bits_size > 3'h0;
  assign aFrag = T_1494 ? 3'h0 : repeater_io_deq_bits_size;
  assign T_1497 = 12'h1f << repeater_io_deq_bits_size;
  assign aOrigOH1 = ~ T_1497[4:0];
  assign T_1501 = 8'h1 << aFrag;
  assign aFragOH1 = ~T_1501;
  assign aFirst = gennum == 5'h0;
  assign old_gennum1 = aFirst ? aOrigOH1 : (gennum - 1'h1);
  assign new_gennum = old_gennum1 & ~{4'd0, aFragOH1};
  assign io_repeat = new_gennum != 5'h0;
  assign T_1528 = ~new_gennum & aOrigOH1;

  always @(posedge clock or posedge reset) 
    if (reset) begin
      acknum <= 5'h0;
      dOrig <= 3'b0;
    end else if (T_1447) begin
        if (dFirst) begin
          acknum <= dFirst_acknum;
          dOrig <= dFirst_size;
        end else begin
          acknum <= acknum - 5'h1;
        end
    end

  always @(posedge clock or posedge reset) 
    if (reset) begin
      gennum <= 5'h0;
    end else if ((io_out_0_a_ready & io_out_0_a_valid)) begin
      gennum <= new_gennum;
    end

   // `ifndef SYNTHESIS
   // `ifdef PRINTF_COND
   //   if (`PRINTF_COND) begin
   // `endif
   //     if (~T_1419) begin
   //       $fwrite(32'h80000002,"Assertion failed\n    at Fragmenter.scala:149 assert (!out.d.valid || (acknum_fragment & acknum_size) === UInt(0))\n");
   //     end
   // `ifdef PRINTF_COND
   //   end
   // `endif
   // `endif
   // `ifndef SYNTHESIS
   // `ifdef STOP_COND
   //   if (`STOP_COND) begin
   // `endif
   //     if (~T_1419) begin
   //       $fatal;
   //     end
   // `ifdef STOP_COND
   //   end
   // `endif
   // `endif
   // `ifndef SYNTHESIS
   // `ifdef PRINTF_COND
   //   if (`PRINTF_COND) begin
   // `endif
   //     if (1'h0) begin
   //       $fwrite(32'h80000002,"Assertion failed\n    at Fragmenter.scala:237 assert (!repeater.io.full || !aHasData)\n");
   //     end
   // `ifdef PRINTF_COND
   //   end
   // `endif
   // `endif
   // `ifndef SYNTHESIS
   // `ifdef STOP_COND
   //   if (`STOP_COND) begin
   // `endif
   //     if (1'h0) begin
   //       $fatal;
   //     end
   // `ifdef STOP_COND
   //   end
   // `endif
   // `endif
   // `ifndef SYNTHESIS
   // `ifdef PRINTF_COND
   //   if (`PRINTF_COND) begin
   // `endif
   //     if (~T_1543) begin
   //       $fwrite(32'h80000002,"Assertion failed\n    at Fragmenter.scala:240 assert (!repeater.io.full || in_a.bits.mask === fullMask)\n");
   //     end
   // `ifdef PRINTF_COND
   //   end
   // `endif
   // `endif
   // `ifndef SYNTHESIS
   // `ifdef STOP_COND
   //   if (`STOP_COND) begin
   // `endif
   //     if (~T_1543) begin
   //       $fatal;
   //     end
   // `ifdef STOP_COND
   //   end
   // `endif
   // `endif
    //synopsys translate_off
  wire  T_1543;
  wire  T_1542;
  wire  T_1419;
  wire  T_1418;
  wire  T_1417;
  wire [4:0] T_1415;
  assign T_1415 = io_out_0_d_bits_source[4:0] & GEN_5;
  assign T_1417 = T_1415 == 5'h0;
  assign T_1418 = ~io_out_0_d_valid | T_1417;
  assign T_1419 = T_1418 | reset;
  assign T_1542 = ~repeater_io_full | repeater_io_deq_bits_mask;
  assign T_1543 = T_1542 | reset;
  always @(posedge clock or posedge reset) begin
        if (~T_1419) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Fragmenter.scala:149 assert (!out.d.valid || (acknum_fragment & acknum_size) === UInt(0))\n");
        end
        if (~T_1543) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Fragmenter.scala:240 assert (!repeater.io.full || in_a.bits.mask === fullMask)\n");
        end
        if (1'h0) begin
          $fwrite(32'h80000002,"Assertion failed\n    at Fragmenter.scala:237 assert (!repeater.io.full || !aHasData)\n");
        end
  end
    //synopsys translate_on
endmodule
