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

 */                                                                      
                                                                         
                                                                         
                                                                         

module sirv_qspi_arbiter(
  input   clock,
  input   reset,
  output  io_inner_0_tx_ready,
  input   io_inner_0_tx_valid,
  input  [7:0] io_inner_0_tx_bits,
  output  io_inner_0_rx_valid,
  output [7:0] io_inner_0_rx_bits,
  input  [7:0] io_inner_0_cnt,
  input  [1:0] io_inner_0_fmt_proto,
  input   io_inner_0_fmt_endian,
  input   io_inner_0_fmt_iodir,
  input   io_inner_0_cs_set,
  input   io_inner_0_cs_clear,
  input   io_inner_0_cs_hold,
  output  io_inner_0_active,
  input   io_inner_0_lock,
  output  io_inner_1_tx_ready,
  input   io_inner_1_tx_valid,
  input  [7:0] io_inner_1_tx_bits,
  output  io_inner_1_rx_valid,
  output [7:0] io_inner_1_rx_bits,
  input  [7:0] io_inner_1_cnt,
  input  [1:0] io_inner_1_fmt_proto,
  input   io_inner_1_fmt_endian,
  input   io_inner_1_fmt_iodir,
  input   io_inner_1_cs_set,
  input   io_inner_1_cs_clear,
  input   io_inner_1_cs_hold,
  output  io_inner_1_active,
  input   io_inner_1_lock,
  input   io_outer_tx_ready,
  output  io_outer_tx_valid,
  output [7:0] io_outer_tx_bits,
  input   io_outer_rx_valid,
  input  [7:0] io_outer_rx_bits,
  output [7:0] io_outer_cnt,
  output [1:0] io_outer_fmt_proto,
  output  io_outer_fmt_endian,
  output  io_outer_fmt_iodir,
  output  io_outer_cs_set,
  output  io_outer_cs_clear,
  output  io_outer_cs_hold,
  input   io_outer_active,
  input   io_sel
);
  reg  sel_0;
  reg  sel_1;
//  wire [3:0] T_379;
//  wire [2:0] T_406;
//  wire  T_431;
  wire  sel_set;
  assign io_inner_0_tx_ready = (io_outer_tx_ready & sel_0);
  assign io_inner_0_rx_valid = (io_outer_rx_valid & sel_0);
  assign io_inner_0_rx_bits = io_outer_rx_bits;
  assign io_inner_0_active = (io_outer_active & sel_0);
  assign io_inner_1_tx_ready = (io_outer_tx_ready & sel_1);
  assign io_inner_1_rx_valid = (io_outer_rx_valid & sel_1);
  assign io_inner_1_rx_bits = io_outer_rx_bits;
  assign io_inner_1_active = (io_outer_active & sel_1);
  assign io_outer_tx_valid = (sel_0 & io_inner_0_tx_valid) | (sel_1 & io_inner_1_tx_valid);
  assign io_outer_tx_bits = ({8{sel_0}} & io_inner_0_tx_bits) | ({8{sel_1}} & io_inner_1_tx_bits);
  assign io_outer_cnt = ({8{sel_0}} & io_inner_0_cnt) | ({8{sel_1}} & io_inner_1_cnt);
  assign io_outer_fmt_proto = ({2{sel_0}} & io_inner_0_fmt_proto) | ({2{sel_1}} & io_inner_1_fmt_proto);
  assign io_outer_fmt_endian = (sel_0 & io_inner_0_fmt_endian) | (sel_1 & io_inner_1_fmt_endian);
  assign io_outer_fmt_iodir = (sel_0 & io_inner_0_fmt_iodir) | (sel_1 & io_inner_1_fmt_iodir);
  assign io_outer_cs_set = (sel_0 & io_inner_0_cs_set) | (sel_1 & io_inner_1_cs_set);
//  assign io_outer_cs_clear = (sel_set ? (({sel_1,sel_0} != {io_sel,T_431}) ? 1'h1 : T_406[1]) : T_406[1]);
  assign io_outer_cs_clear = 
      (sel_set & ({sel_1,sel_0} != {io_sel,~io_sel})) |
      (sel_0 & io_inner_0_cs_clear) | (sel_1 & io_inner_1_cs_clear);
  assign io_outer_cs_hold = (sel_0 & io_inner_0_cs_hold) | (sel_1 & io_inner_1_cs_hold);
//  assign T_379 =
//      (sel_0 ? {io_inner_0_fmt_proto,io_inner_0_fmt_endian,io_inner_0_fmt_iodir} : 4'h0) |
//      (sel_1 ? {io_inner_1_fmt_proto,io_inner_1_fmt_endian,io_inner_1_fmt_iodir} : 4'h0);
//  assign T_406 = 
//      (sel_0 ? {io_inner_0_cs_set,io_inner_0_cs_clear,io_inner_0_cs_hold} : 3'h0) |
//      (sel_1 ? {io_inner_1_cs_set,io_inner_1_cs_clear,io_inner_1_cs_hold} : 3'h0);
//  assign T_431 = io_sel == 1'h0;
  assign sel_set = ~((sel_0 & io_inner_0_lock) | (sel_1 & io_inner_1_lock));

//  always @(posedge clock or posedge reset)
//    if (reset) begin
//      sel_0 <= 1'h1;
//    end else begin
//      if (sel_set) begin
////        sel_0 <= T_431;
//        sel_0 <= ~io_sel;
//      end
//    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      sel_0 <= 1'h1;
      sel_1 <= 1'h0;
    end else begin
      if (sel_set) begin
        sel_0 <= ~io_sel;
        sel_1 <= io_sel;
      end
    end
  
endmodule
