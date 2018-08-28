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
                                                                         
                                                                         
                                                                         

module sirv_flash_qspi(
  input   clock,
  input   reset,
  output  io_port_sck,
  input   io_port_dq_0_i,
  output  io_port_dq_0_o,
  output  io_port_dq_0_oe,
  input   io_port_dq_1_i,
  output  io_port_dq_1_o,
  output  io_port_dq_1_oe,
  input   io_port_dq_2_i,
  output  io_port_dq_2_o,
  output  io_port_dq_2_oe,
  input   io_port_dq_3_i,
  output  io_port_dq_3_o,
  output  io_port_dq_3_oe,
  output  io_port_cs_0,
  output  io_tl_i_0_0,
  output  io_tl_r_0_a_ready,
  input   io_tl_r_0_a_valid,
  input  [2:0] io_tl_r_0_a_bits_opcode,
  input  [2:0] io_tl_r_0_a_bits_param,
  input  [2:0] io_tl_r_0_a_bits_size,
  input  [4:0] io_tl_r_0_a_bits_source,
  input  [28:0] io_tl_r_0_a_bits_address,
  input  [3:0] io_tl_r_0_a_bits_mask,
  input  [31:0] io_tl_r_0_a_bits_data,
  input   io_tl_r_0_d_ready,
  output  io_tl_r_0_d_valid,
  output [2:0] io_tl_r_0_d_bits_opcode,
  output [1:0] io_tl_r_0_d_bits_param,
  output [2:0] io_tl_r_0_d_bits_size,
  output [4:0] io_tl_r_0_d_bits_source,
  output  io_tl_r_0_d_bits_sink,
  output [1:0] io_tl_r_0_d_bits_addr_lo,
  output [31:0] io_tl_r_0_d_bits_data,
  output  io_tl_r_0_d_bits_error,
  output  io_tl_f_0_a_ready,
  input   io_tl_f_0_a_valid,
  input  [2:0] io_tl_f_0_a_bits_opcode,
  input  [2:0] io_tl_f_0_a_bits_param,
  input  [2:0] io_tl_f_0_a_bits_size,
  input  [6:0] io_tl_f_0_a_bits_source,
  input  [29:0] io_tl_f_0_a_bits_address,
  input   io_tl_f_0_a_bits_mask,
  input  [7:0] io_tl_f_0_a_bits_data,
  input   io_tl_f_0_d_ready,
  output  io_tl_f_0_d_valid,
  output [2:0] io_tl_f_0_d_bits_opcode,
  output [1:0] io_tl_f_0_d_bits_param,
  output [2:0] io_tl_f_0_d_bits_size,
  output [6:0] io_tl_f_0_d_bits_source,
  output  io_tl_f_0_d_bits_sink,
  output  io_tl_f_0_d_bits_addr_lo,
  output [7:0] io_tl_f_0_d_bits_data,
  output  io_tl_f_0_d_bits_error
);
  reg [1:0] ctrl_fmt_proto;
  reg  ctrl_fmt_endian;
  reg  ctrl_fmt_iodir;
  reg [3:0] ctrl_fmt_len;
  reg [11:0] ctrl_sck_div;
  reg  ctrl_sck_pol;
  reg  ctrl_sck_pha;
  reg  ctrl_cs_id;
  reg  ctrl_cs_dflt_0;
  reg [1:0] ctrl_cs_mode;
  reg [7:0] ctrl_dla_cssck;
  reg [7:0] ctrl_dla_sckcs;
  reg [7:0] ctrl_dla_intercs;
  reg [7:0] ctrl_dla_interxfr;
  reg [3:0] ctrl_wm_tx;
  reg [3:0] ctrl_wm_rx;
  wire  fifo_io_link_tx_valid;
  wire [7:0] fifo_io_link_tx_bits;
  wire [7:0] fifo_io_link_cnt;
  wire [1:0] fifo_io_link_fmt_proto;
  wire  fifo_io_link_fmt_endian;
  wire  fifo_io_link_fmt_iodir;
  wire  fifo_io_link_cs_set;
  wire  fifo_io_link_cs_clear;
  wire  fifo_io_link_cs_hold;
  wire  fifo_io_link_lock;
  wire  fifo_io_tx_ready;
  wire  fifo_io_rx_valid;
  wire [7:0] fifo_io_rx_bits;
  wire  fifo_io_ip_txwm;
  wire  fifo_io_ip_rxwm;
  wire  mac_io_port_sck;
  wire  mac_io_port_dq_0_o;
  wire  mac_io_port_dq_0_oe;
  wire  mac_io_port_dq_1_o;
  wire  mac_io_port_dq_1_oe;
  wire  mac_io_port_dq_2_o;
  wire  mac_io_port_dq_2_oe;
  wire  mac_io_port_dq_3_o;
  wire  mac_io_port_dq_3_oe;
  wire  mac_io_port_cs_0;
  wire  mac_io_link_tx_ready;
  wire  mac_io_link_rx_valid;
  wire [7:0] mac_io_link_rx_bits;
  wire  mac_io_link_active;
  reg  ie_txwm;
  reg  ie_rxwm;
  wire  flash_io_addr_ready;
  wire  flash_io_data_valid;
  wire [7:0] flash_io_data_bits;
  wire  flash_io_link_tx_valid;
  wire [7:0] flash_io_link_tx_bits;
  wire [7:0] flash_io_link_cnt;
  wire [1:0] flash_io_link_fmt_proto;
  wire  flash_io_link_fmt_endian;
  wire  flash_io_link_fmt_iodir;
  wire  flash_io_link_cs_set;
  wire  flash_io_link_cs_clear;
  wire  flash_io_link_cs_hold;
  wire  flash_io_link_lock;
  wire  arb_io_inner_0_tx_ready;
  wire  arb_io_inner_0_rx_valid;
  wire [7:0] arb_io_inner_0_rx_bits;
  wire  arb_io_inner_0_active;
  wire  arb_io_inner_1_tx_ready;
  wire  arb_io_inner_1_rx_valid;
  wire [7:0] arb_io_inner_1_rx_bits;
  wire  arb_io_inner_1_active;
  wire  arb_io_outer_tx_valid;
  wire [7:0] arb_io_outer_tx_bits;
  wire [7:0] arb_io_outer_cnt;
  wire [1:0] arb_io_outer_fmt_proto;
  wire  arb_io_outer_fmt_endian;
  wire  arb_io_outer_fmt_iodir;
  wire  arb_io_outer_cs_set;
  wire  arb_io_outer_cs_clear;
  wire  arb_io_outer_cs_hold;
  reg [2:0] a_size;
  reg [6:0] a_source;
  reg [29:0] a_address;
  reg [1:0] insn_cmd_proto;
  reg [7:0] insn_cmd_code;
  reg  insn_cmd_en;
  reg [1:0] insn_addr_proto;
  reg [2:0] insn_addr_len;
  reg [7:0] insn_pad_code;
  reg [3:0] insn_pad_cnt;
  reg [1:0] insn_data_proto;
  reg  flash_en;
  wire  T_2046;
  wire [9:0] T_2050;
  wire  T_2191;
//  wire  T_2200;
//  wire  T_2209;
//  wire  T_2218;
//  wire  T_2227;
//  wire  T_2236;
//  wire  T_2245;
//  wire  T_2254;
//  wire  T_2263;
//  wire  T_2272;
//  wire  T_2281;
//  wire  T_2290;
//  wire  T_2299;
//  wire  T_2308;
//  wire  T_2317;
//  wire  T_2326;
  wire [31:0] T_2553;
  wire  T_2623;
  wire  T_2663;
  wire  T_2703;
  wire  T_3103;
  wire  T_3183;
  wire  T_3303;
//  wire  T_3978;
//  wire  T_3982;
//  wire  T_3993;
//  wire  T_3997;
//  wire  T_4001;
//  wire  T_4014;
//  wire  T_4019;
//  wire  T_4036;
//  wire  T_4046;
//  wire  T_4052;
//  wire  T_4058;
//  wire  T_4062;
//  wire  T_4072;
//  wire  T_4076;
//  wire  T_4093;
//  wire  T_4098;
  wire [4:0] T_4794;
  wire  T_4811;
  wire  T_4814;
  wire  T_4816;
  wire [31:0] T_4852;
  wire  T_4897;
  wire  T_4904;
  wire  T_4926;
  wire  T_5106;
  wire  T_5126;
  wire  T_5226;
  wire  T_5406;
  wire  T_5466;
  sirv_qspi_fifo fifo (
    .clock(clock),
    .reset(reset),
    .io_ctrl_fmt_proto(ctrl_fmt_proto),
    .io_ctrl_fmt_endian(ctrl_fmt_endian),
    .io_ctrl_fmt_iodir(ctrl_fmt_iodir),
    .io_ctrl_fmt_len(ctrl_fmt_len),
    .io_ctrl_cs_mode(ctrl_cs_mode),
    .io_ctrl_wm_tx(ctrl_wm_tx),
    .io_ctrl_wm_rx(ctrl_wm_rx),
    .io_link_tx_ready(arb_io_inner_1_tx_ready),
    .io_link_tx_valid(fifo_io_link_tx_valid),
    .io_link_tx_bits(fifo_io_link_tx_bits),
    .io_link_rx_valid(arb_io_inner_1_rx_valid),
    .io_link_rx_bits(arb_io_inner_1_rx_bits),
    .io_link_cnt(fifo_io_link_cnt),
    .io_link_fmt_proto(fifo_io_link_fmt_proto),
    .io_link_fmt_endian(fifo_io_link_fmt_endian),
    .io_link_fmt_iodir(fifo_io_link_fmt_iodir),
    .io_link_cs_set(fifo_io_link_cs_set),
    .io_link_cs_clear(fifo_io_link_cs_clear),
    .io_link_cs_hold(fifo_io_link_cs_hold),
    .io_link_active(arb_io_inner_1_active),
    .io_link_lock(fifo_io_link_lock),
    .io_tx_ready(fifo_io_tx_ready),
    .io_tx_valid(((((T_4904 & T_4852[18]) & 1'h1) & 1'h1) & T_2663)),
    .io_tx_bits(io_tl_r_0_a_bits_data[7:0]),
    .io_rx_ready((((((T_4897 & T_2046) & T_4852[19]) & 1'h1) & 1'h1) & (T_2553[7:0] != 8'h0))),
    .io_rx_valid(fifo_io_rx_valid),
    .io_rx_bits(fifo_io_rx_bits),
    .io_ip_txwm(fifo_io_ip_txwm),
    .io_ip_rxwm(fifo_io_ip_rxwm)
  );
  sirv_qspi_media mac (
    .clock(clock),
    .reset(reset),
    .io_port_sck(mac_io_port_sck),
    .io_port_dq_0_i(io_port_dq_0_i),
    .io_port_dq_0_o(mac_io_port_dq_0_o),
    .io_port_dq_0_oe(mac_io_port_dq_0_oe),
    .io_port_dq_1_i(io_port_dq_1_i),
    .io_port_dq_1_o(mac_io_port_dq_1_o),
    .io_port_dq_1_oe(mac_io_port_dq_1_oe),
    .io_port_dq_2_i(io_port_dq_2_i),
    .io_port_dq_2_o(mac_io_port_dq_2_o),
    .io_port_dq_2_oe(mac_io_port_dq_2_oe),
    .io_port_dq_3_i(io_port_dq_3_i),
    .io_port_dq_3_o(mac_io_port_dq_3_o),
    .io_port_dq_3_oe(mac_io_port_dq_3_oe),
    .io_port_cs_0(mac_io_port_cs_0),
    .io_ctrl_sck_div(ctrl_sck_div),
    .io_ctrl_sck_pol(ctrl_sck_pol),
    .io_ctrl_sck_pha(ctrl_sck_pha),
    .io_ctrl_dla_cssck(ctrl_dla_cssck),
    .io_ctrl_dla_sckcs(ctrl_dla_sckcs),
    .io_ctrl_dla_intercs(ctrl_dla_intercs),
    .io_ctrl_dla_interxfr(ctrl_dla_interxfr),
    .io_ctrl_cs_id(ctrl_cs_id),
    .io_ctrl_cs_dflt_0(ctrl_cs_dflt_0),
    .io_link_tx_ready(mac_io_link_tx_ready),
    .io_link_tx_valid(arb_io_outer_tx_valid),
    .io_link_tx_bits(arb_io_outer_tx_bits),
    .io_link_rx_valid(mac_io_link_rx_valid),
    .io_link_rx_bits(mac_io_link_rx_bits),
    .io_link_cnt(arb_io_outer_cnt),
    .io_link_fmt_proto(arb_io_outer_fmt_proto),
    .io_link_fmt_endian(arb_io_outer_fmt_endian),
    .io_link_fmt_iodir(arb_io_outer_fmt_iodir),
    .io_link_cs_set(arb_io_outer_cs_set),
    .io_link_cs_clear(arb_io_outer_cs_clear),
    .io_link_cs_hold(arb_io_outer_cs_hold),
    .io_link_active(mac_io_link_active)
  );
  sirv_qspi_flashmap flash (
    .clock(clock),
    .reset(reset),
    .io_en(flash_en),
    .io_ctrl_insn_cmd_proto(insn_cmd_proto),
    .io_ctrl_insn_cmd_code(insn_cmd_code),
    .io_ctrl_insn_cmd_en(insn_cmd_en),
    .io_ctrl_insn_addr_proto(insn_addr_proto),
    .io_ctrl_insn_addr_len(insn_addr_len),
    .io_ctrl_insn_pad_code(insn_pad_code),
    .io_ctrl_insn_pad_cnt(insn_pad_cnt),
    .io_ctrl_insn_data_proto(insn_data_proto),
    .io_ctrl_fmt_endian(ctrl_fmt_endian),
    .io_addr_ready(flash_io_addr_ready),
    .io_addr_valid(io_tl_f_0_a_valid),
    .io_addr_bits_next({3'd0, io_tl_f_0_a_bits_address[28:0]}),
    .io_addr_bits_hold({3'd0, a_address[28:0]}),
    .io_data_ready(io_tl_f_0_d_ready),
    .io_data_valid(flash_io_data_valid),
    .io_data_bits(flash_io_data_bits),
    .io_link_tx_ready(arb_io_inner_0_tx_ready),
    .io_link_tx_valid(flash_io_link_tx_valid),
    .io_link_tx_bits(flash_io_link_tx_bits),
    .io_link_rx_valid(arb_io_inner_0_rx_valid),
    .io_link_rx_bits(arb_io_inner_0_rx_bits),
    .io_link_cnt(flash_io_link_cnt),
    .io_link_fmt_proto(flash_io_link_fmt_proto),
    .io_link_fmt_endian(flash_io_link_fmt_endian),
    .io_link_fmt_iodir(flash_io_link_fmt_iodir),
    .io_link_cs_set(flash_io_link_cs_set),
    .io_link_cs_clear(flash_io_link_cs_clear),
    .io_link_cs_hold(flash_io_link_cs_hold),
    .io_link_active(arb_io_inner_0_active),
    .io_link_lock(flash_io_link_lock)
  );
  sirv_qspi_arbiter arb (
    .clock(clock),
    .reset(reset),
    .io_inner_0_tx_ready(arb_io_inner_0_tx_ready),
    .io_inner_0_tx_valid(flash_io_link_tx_valid),
    .io_inner_0_tx_bits(flash_io_link_tx_bits),
    .io_inner_0_rx_valid(arb_io_inner_0_rx_valid),
    .io_inner_0_rx_bits(arb_io_inner_0_rx_bits),
    .io_inner_0_cnt(flash_io_link_cnt),
    .io_inner_0_fmt_proto(flash_io_link_fmt_proto),
    .io_inner_0_fmt_endian(flash_io_link_fmt_endian),
    .io_inner_0_fmt_iodir(flash_io_link_fmt_iodir),
    .io_inner_0_cs_set(flash_io_link_cs_set),
    .io_inner_0_cs_clear(flash_io_link_cs_clear),
    .io_inner_0_cs_hold(flash_io_link_cs_hold),
    .io_inner_0_active(arb_io_inner_0_active),
    .io_inner_0_lock(flash_io_link_lock),
    .io_inner_1_tx_ready(arb_io_inner_1_tx_ready),
    .io_inner_1_tx_valid(fifo_io_link_tx_valid),
    .io_inner_1_tx_bits(fifo_io_link_tx_bits),
    .io_inner_1_rx_valid(arb_io_inner_1_rx_valid),
    .io_inner_1_rx_bits(arb_io_inner_1_rx_bits),
    .io_inner_1_cnt(fifo_io_link_cnt),
    .io_inner_1_fmt_proto(fifo_io_link_fmt_proto),
    .io_inner_1_fmt_endian(fifo_io_link_fmt_endian),
    .io_inner_1_fmt_iodir(fifo_io_link_fmt_iodir),
    .io_inner_1_cs_set(fifo_io_link_cs_set),
    .io_inner_1_cs_clear(fifo_io_link_cs_clear),
    .io_inner_1_cs_hold(fifo_io_link_cs_hold),
    .io_inner_1_active(arb_io_inner_1_active),
    .io_inner_1_lock(fifo_io_link_lock),
    .io_outer_tx_ready(mac_io_link_tx_ready),
    .io_outer_tx_valid(arb_io_outer_tx_valid),
    .io_outer_tx_bits(arb_io_outer_tx_bits),
    .io_outer_rx_valid(mac_io_link_rx_valid),
    .io_outer_rx_bits(mac_io_link_rx_bits),
    .io_outer_cnt(arb_io_outer_cnt),
    .io_outer_fmt_proto(arb_io_outer_fmt_proto),
    .io_outer_fmt_endian(arb_io_outer_fmt_endian),
    .io_outer_fmt_iodir(arb_io_outer_fmt_iodir),
    .io_outer_cs_set(arb_io_outer_cs_set),
    .io_outer_cs_clear(arb_io_outer_cs_clear),
    .io_outer_cs_hold(arb_io_outer_cs_hold),
    .io_outer_active(mac_io_link_active),
    .io_sel((flash_en == 1'h0))
  );
  assign io_port_sck = mac_io_port_sck;
  assign io_port_dq_0_o = mac_io_port_dq_0_o;
  assign io_port_dq_0_oe = mac_io_port_dq_0_oe;
  assign io_port_dq_1_o = mac_io_port_dq_1_o;
  assign io_port_dq_1_oe = mac_io_port_dq_1_oe;
  assign io_port_dq_2_o = mac_io_port_dq_2_o;
  assign io_port_dq_2_oe = mac_io_port_dq_2_oe;
  assign io_port_dq_3_o = mac_io_port_dq_3_o;
  assign io_port_dq_3_oe = mac_io_port_dq_3_oe;
  assign io_port_cs_0 = mac_io_port_cs_0;
  assign io_tl_i_0_0 = ((fifo_io_ip_txwm & ie_txwm) | (fifo_io_ip_rxwm & ie_rxwm));
  assign io_tl_r_0_a_ready = ((io_tl_r_0_d_ready & T_4814) & T_4811);
  assign io_tl_r_0_d_valid = (T_4816 & T_4814);
  assign io_tl_r_0_d_bits_opcode = {{2'd0}, T_2046};
  assign io_tl_r_0_d_bits_param = 2'h0;
  assign io_tl_r_0_d_bits_size = T_2050[2:0];
  assign io_tl_r_0_d_bits_source = T_2050[7:3];
  assign io_tl_r_0_d_bits_sink = 1'h0;
  assign io_tl_r_0_d_bits_addr_lo = T_2050[9:8];
//  assign io_tl_r_0_d_bits_data = ((5'h1f == T_4794 ? 1'h1 : (5'h1e == T_4794 ? 1'h1 : (5'h1d == T_4794 ? T_2245 : (5'h1c == T_4794 ? T_2272 : (5'h1b == T_4794 ? 1'h1 : (5'h1a == T_4794 ? 1'h1 : (5'h19 == T_4794 ? T_2227 : (5'h18 == T_4794 ? T_2218 : (5'h17 == T_4794 ? 1'h1 : (5'h16 == T_4794 ? 1'h1 : (5'h15 == T_4794 ? T_2281 : (5'h14 == T_4794 ? T_2236 : (5'h13 == T_4794 ? T_2317 : (5'h12 == T_4794 ? T_2290 : (5'h11 == T_4794 ? 1'h1 : (5'h10 == T_4794 ? T_2299 : (5'hf == T_4794 ? 1'h1 : (5'he == T_4794 ? 1'h1 : (5'hd == T_4794 ? 1'h1 : (5'hc == T_4794 ? 1'h1 : (5'hb == T_4794 ? T_2308 : (5'ha == T_4794 ? T_2209 : (5'h9 == T_4794 ? 1'h1 : (5'h8 == T_4794 ? 1'h1 : (5'h7 == T_4794 ? 1'h1 : (5'h6 == T_4794 ? T_2263 : (5'h5 == T_4794 ? T_2200 : (5'h4 == T_4794 ? T_2326 : (5'h3 == T_4794 ? 1'h1 : (5'h2 == T_4794 ? 1'h1 : (5'h1 == T_4794 ? T_2254 : T_2191))))))))))))))))))))))))))))))) ? (5'h1f == T_4794 ? 32'h0 : (5'h1e == T_4794 ? 32'h0 : (5'h1d == T_4794 ? ({{30'd0}, (({{1'd0}, fifo_io_ip_txwm}) | (({{1'd0}, fifo_io_ip_rxwm}) << 1))}) : (5'h1c == T_4794 ? ({{30'd0}, (({{1'd0}, ie_txwm}) | (({{1'd0}, ie_rxwm}) << 1))}) : (5'h1b == T_4794 ? 32'h0 : (5'h1a == T_4794 ? 32'h0 : (5'h19 == T_4794 ? (({{8'd0}, (({{10'd0}, (({{2'd0}, (({{2'd0}, (({{2'd0}, (({{4'd0}, (({{3'd0}, insn_cmd_en}) | (({{1'd0}, insn_addr_len}) << 1))}) | (({{4'd0}, insn_pad_cnt}) << 4))}) | (({{8'd0}, insn_cmd_proto}) << 8))}) | (({{10'd0}, insn_addr_proto}) << 10))}) | (({{12'd0}, insn_data_proto}) << 12))}) | (({{16'd0}, insn_cmd_code}) << 16))}) | (({{24'd0}, insn_pad_code}) << 24)) : (5'h18 == T_4794 ? ({{31'd0}, flash_en}) : (5'h17 == T_4794 ? 32'h0 : (5'h16 == T_4794 ? 32'h0 : (5'h15 == T_4794 ? ({{28'd0}, ctrl_wm_rx}) : (5'h14 == T_4794 ? ({{28'd0}, ctrl_wm_tx}) : (5'h13 == T_4794 ? (({{1'd0}, ({{23'd0}, fifo_io_rx_bits})}) | (({{31'd0}, (fifo_io_rx_valid == 1'h0)}) << 31)) : (5'h12 == T_4794 ? (({{31'd0}, (fifo_io_tx_ready == 1'h0)}) << 31) : (5'h11 == T_4794 ? 32'h0 : (5'h10 == T_4794 ? ({{12'd0}, (({{16'd0}, (({{1'd0}, (({{1'd0}, ctrl_fmt_proto}) | (({{2'd0}, ctrl_fmt_endian}) << 2))}) | (({{3'd0}, ctrl_fmt_iodir}) << 3))}) | (({{16'd0}, ctrl_fmt_len}) << 16))}) : (5'hf == T_4794 ? 32'h0 : (5'he == T_4794 ? 32'h0 : (5'hd == T_4794 ? 32'h0 : (5'hc == T_4794 ? 32'h0 : (5'hb == T_4794 ? ({{8'd0}, (({{16'd0}, ctrl_dla_intercs}) | (({{16'd0}, ctrl_dla_interxfr}) << 16))}) : (5'ha == T_4794 ? ({{8'd0}, (({{16'd0}, ctrl_dla_cssck}) | (({{16'd0}, ctrl_dla_sckcs}) << 16))}) : (5'h9 == T_4794 ? 32'h0 : (5'h8 == T_4794 ? 32'h0 : (5'h7 == T_4794 ? 32'h0 : (5'h6 == T_4794 ? ({{30'd0}, ctrl_cs_mode}) : (5'h5 == T_4794 ? ({{31'd0}, ctrl_cs_dflt_0}) : (5'h4 == T_4794 ? ({{31'd0}, ctrl_cs_id}) : (5'h3 == T_4794 ? 32'h0 : (5'h2 == T_4794 ? 32'h0 : (5'h1 == T_4794 ? ({{30'd0}, (({{1'd0}, ctrl_sck_pha}) | (({{1'd0}, ctrl_sck_pol}) << 1))}) : ({{20'd0}, ctrl_sck_div})))))))))))))))))))))))))))))))) : 32'h0);
  assign io_tl_r_0_d_bits_data = T_2191 ? (5'h1f == T_4794 ? 32'h0 : (5'h1e == T_4794 ? 32'h0 : (5'h1d == T_4794 ? ({{30'd0}, (({{1'd0}, fifo_io_ip_txwm}) | (({{1'd0}, fifo_io_ip_rxwm}) << 1))}) : (5'h1c == T_4794 ? ({{30'd0}, (({{1'd0}, ie_txwm}) | (({{1'd0}, ie_rxwm}) << 1))}) : (5'h1b == T_4794 ? 32'h0 : (5'h1a == T_4794 ? 32'h0 : (5'h19 == T_4794 ? (({{8'd0}, (({{10'd0}, (({{2'd0}, (({{2'd0}, (({{2'd0}, (({{4'd0}, (({{3'd0}, insn_cmd_en}) | (({{1'd0}, insn_addr_len}) << 1))}) | (({{4'd0}, insn_pad_cnt}) << 4))}) | (({{8'd0}, insn_cmd_proto}) << 8))}) | (({{10'd0}, insn_addr_proto}) << 10))}) | (({{12'd0}, insn_data_proto}) << 12))}) | (({{16'd0}, insn_cmd_code}) << 16))}) | (({{24'd0}, insn_pad_code}) << 24)) : (5'h18 == T_4794 ? ({{31'd0}, flash_en}) : (5'h17 == T_4794 ? 32'h0 : (5'h16 == T_4794 ? 32'h0 : (5'h15 == T_4794 ? ({{28'd0}, ctrl_wm_rx}) : (5'h14 == T_4794 ? ({{28'd0}, ctrl_wm_tx}) : (5'h13 == T_4794 ? (({{1'd0}, ({{23'd0}, fifo_io_rx_bits})}) | (({{31'd0}, (fifo_io_rx_valid == 1'h0)}) << 31)) : (5'h12 == T_4794 ? (({{31'd0}, (fifo_io_tx_ready == 1'h0)}) << 31) : (5'h11 == T_4794 ? 32'h0 : (5'h10 == T_4794 ? ({{12'd0}, (({{16'd0}, (({{1'd0}, (({{1'd0}, ctrl_fmt_proto}) | (({{2'd0}, ctrl_fmt_endian}) << 2))}) | (({{3'd0}, ctrl_fmt_iodir}) << 3))}) | (({{16'd0}, ctrl_fmt_len}) << 16))}) : (5'hf == T_4794 ? 32'h0 : (5'he == T_4794 ? 32'h0 : (5'hd == T_4794 ? 32'h0 : (5'hc == T_4794 ? 32'h0 : (5'hb == T_4794 ? ({{8'd0}, (({{16'd0}, ctrl_dla_intercs}) | (({{16'd0}, ctrl_dla_interxfr}) << 16))}) : (5'ha == T_4794 ? ({{8'd0}, (({{16'd0}, ctrl_dla_cssck}) | (({{16'd0}, ctrl_dla_sckcs}) << 16))}) : (5'h9 == T_4794 ? 32'h0 : (5'h8 == T_4794 ? 32'h0 : (5'h7 == T_4794 ? 32'h0 : (5'h6 == T_4794 ? ({{30'd0}, ctrl_cs_mode}) : (5'h5 == T_4794 ? ({{31'd0}, ctrl_cs_dflt_0}) : (5'h4 == T_4794 ? ({{31'd0}, ctrl_cs_id}) : (5'h3 == T_4794 ? 32'h0 : (5'h2 == T_4794 ? 32'h0 : (5'h1 == T_4794 ? ({{30'd0}, (({{1'd0}, ctrl_sck_pha}) | (({{1'd0}, ctrl_sck_pol}) << 1))}) : ({{20'd0}, ctrl_sck_div})))))))))))))))))))))))))))))))) : 32'h0;
  assign io_tl_r_0_d_bits_error = 1'h0;
  assign io_tl_f_0_a_ready = flash_io_addr_ready;
  assign io_tl_f_0_d_valid = flash_io_data_valid;
  assign io_tl_f_0_d_bits_opcode = 3'h1;
  assign io_tl_f_0_d_bits_param = 2'h0;
  assign io_tl_f_0_d_bits_size = a_size;
  assign io_tl_f_0_d_bits_source = a_source;
  assign io_tl_f_0_d_bits_sink = 1'h0;
  assign io_tl_f_0_d_bits_addr_lo = 1'h0;
  assign io_tl_f_0_d_bits_data = flash_io_data_bits;
  assign io_tl_f_0_d_bits_error = 1'h0;
  assign T_2046 = io_tl_r_0_a_bits_opcode == 3'h4;
  assign T_2050 = {({io_tl_r_0_a_bits_address[1:0],io_tl_r_0_a_bits_source}),io_tl_r_0_a_bits_size};
//  assign T_2191 = (io_tl_r_0_a_bits_address[11:2] & 10'h3e0) == 10'h0;
  assign T_2191 = io_tl_r_0_a_bits_address[11:7] == 5'h0;
//  assign T_2200 = ((io_tl_r_0_a_bits_address[11:2] ^ 10'h5) & 10'h3e0) == 10'h0;
//  assign T_2209 = ((io_tl_r_0_a_bits_address[11:2] ^ 10'ha) & 10'h3e0) == 10'h0;
//  assign T_2218 = ((io_tl_r_0_a_bits_address[11:2] ^ 10'h18) & 10'h3e0) == 10'h0;
//  assign T_2227 = ((io_tl_r_0_a_bits_address[11:2] ^ 10'h19) & 10'h3e0) == 10'h0;
//  assign T_2236 = ((io_tl_r_0_a_bits_address[11:2] ^ 10'h14) & 10'h3e0) == 10'h0;
//  assign T_2245 = ((io_tl_r_0_a_bits_address[11:2] ^ 10'h1d) & 10'h3e0) == 10'h0;
//  assign T_2254 = ((io_tl_r_0_a_bits_address[11:2] ^ 10'h1) & 10'h3e0) == 10'h0;
//  assign T_2263 = ((io_tl_r_0_a_bits_address[11:2] ^ 10'h6) & 10'h3e0) == 10'h0;
//  assign T_2272 = ((io_tl_r_0_a_bits_address[11:2] ^ 10'h1c) & 10'h3e0) == 10'h0;
//  assign T_2281 = ((io_tl_r_0_a_bits_address[11:2] ^ 10'h15) & 10'h3e0) == 10'h0;
//  assign T_2290 = ((io_tl_r_0_a_bits_address[11:2] ^ 10'h12) & 10'h3e0) == 10'h0;
//  assign T_2299 = ((io_tl_r_0_a_bits_address[11:2] ^ 10'h10) & 10'h3e0) == 10'h0;
//  assign T_2308 = ((io_tl_r_0_a_bits_address[11:2] ^ 10'hb) & 10'h3e0) == 10'h0;
//  assign T_2317 = ((io_tl_r_0_a_bits_address[11:2] ^ 10'h13) & 10'h3e0) == 10'h0;
//  assign T_2326 = ((io_tl_r_0_a_bits_address[11:2] ^ 10'h4) & 10'h3e0) == 10'h0;
  assign T_2553 = { {8{io_tl_r_0_a_bits_mask[3]}}, {8{io_tl_r_0_a_bits_mask[2]}}, {8{io_tl_r_0_a_bits_mask[1]}}, {8{io_tl_r_0_a_bits_mask[0]}} };
  assign T_2623 = T_2553[0];
  assign T_2663 = (~ T_2553[7:0]) == 8'h0;
  assign T_2703 = (~ T_2553[23:16]) == 8'h0;
  assign T_3103 = (~ T_2553[3:0]) == 4'h0;
  assign T_3183 = T_2553[1];
  assign T_3303 = (~ T_2553[1:0]) == 2'h0;
//  assign T_3978 = ~T_2191;
//  assign T_3982 = ~T_2254;
//  assign T_3993 = ~T_2326;
//  assign T_3997 = ~T_2200;
//  assign T_4001 = ~T_2263;
//  assign T_4014 = ~T_2209;
//  assign T_4019 = ~T_2308;
//  assign T_4036 = ~T_2299;
//  assign T_4046 = ~T_2290;
//  assign T_4052 = ~T_2317;
//  assign T_4058 = ~T_2236;
//  assign T_4062 = ~T_2281;
//  assign T_4072 = ~T_2218;
//  assign T_4076 = ~T_2227;
//  assign T_4093 = ~T_2272;
//  assign T_4098 = ~T_2245;
  assign T_4794 = io_tl_r_0_a_bits_address[6:2];
//  assign T_4811 = T_2046 ? (5'h1f == T_4794 ? 1'h1 : (5'h1e == T_4794 ? 1'h1 : (5'h1d == T_4794 ? (T_4098 | (1'h1 & 1'h1)) : (5'h1c == T_4794 ? (T_4093 | (1'h1 & 1'h1)) : (5'h1b == T_4794 ? 1'h1 : (5'h1a == T_4794 ? 1'h1 : (5'h19 == T_4794 ? (T_4076 | (((((((1'h1 & 1'h1) & 1'h1) & 1'h1) & 1'h1) & 1'h1) & 1'h1) & 1'h1)) : (5'h18 == T_4794 ? (T_4072 | 1'h1) : (5'h17 == T_4794 ? 1'h1 : (5'h16 == T_4794 ? 1'h1 : (5'h15 == T_4794 ? (T_4062 | 1'h1) : (5'h14 == T_4794 ? (T_4058 | 1'h1) : (5'h13 == T_4794 ? (T_4052 | ((1'h1 & 1'h1) & 1'h1)) : (5'h12 == T_4794 ? (T_4046 | ((1'h1 & 1'h1) & 1'h1)) : (5'h11 == T_4794 ? 1'h1 : (5'h10 == T_4794 ? (T_4036 | (((1'h1 & 1'h1) & 1'h1) & 1'h1)) : (5'hf == T_4794 ? 1'h1 : (5'he == T_4794 ? 1'h1 : (5'hd == T_4794 ? 1'h1 : (5'hc == T_4794 ? 1'h1 : (5'hb == T_4794 ? (T_4019 | (1'h1 & 1'h1)) : (5'ha == T_4794 ? (T_4014 | (1'h1 & 1'h1)) : (5'h9 == T_4794 ? 1'h1 : (5'h8 == T_4794 ? 1'h1 : (5'h7 == T_4794 ? 1'h1 : (5'h6 == T_4794 ? (T_4001 | 1'h1) : (5'h5 == T_4794 ? (T_3997 | 1'h1) : (5'h4 == T_4794 ? (T_3993 | 1'h1) : (5'h3 == T_4794 ? 1'h1 : (5'h2 == T_4794 ? 1'h1 : (5'h1 == T_4794 ? (T_3982 | (1'h1 & 1'h1)) : (T_3978 | 1'h1)))))))))))))))))))))))))))))))) : (5'h1f == T_4794 ? 1'h1 : (5'h1e == T_4794 ? 1'h1 : (5'h1d == T_4794 ? (T_4098 | (1'h1 & 1'h1)) : (5'h1c == T_4794 ? (T_4093 | (1'h1 & 1'h1)) : (5'h1b == T_4794 ? 1'h1 : (5'h1a == T_4794 ? 1'h1 : (5'h19 == T_4794 ? (T_4076 | (((((((1'h1 & 1'h1) & 1'h1) & 1'h1) & 1'h1) & 1'h1) & 1'h1) & 1'h1)) : (5'h18 == T_4794 ? (T_4072 | 1'h1) : (5'h17 == T_4794 ? 1'h1 : (5'h16 == T_4794 ? 1'h1 : (5'h15 == T_4794 ? (T_4062 | 1'h1) : (5'h14 == T_4794 ? (T_4058 | 1'h1) : (5'h13 == T_4794 ? (T_4052 | ((1'h1 & 1'h1) & 1'h1)) : (5'h12 == T_4794 ? (T_4046 | ((1'h1 & 1'h1) & 1'h1)) : (5'h11 == T_4794 ? 1'h1 : (5'h10 == T_4794 ? (T_4036 | (((1'h1 & 1'h1) & 1'h1) & 1'h1)) : (5'hf == T_4794 ? 1'h1 : (5'he == T_4794 ? 1'h1 : (5'hd == T_4794 ? 1'h1 : (5'hc == T_4794 ? 1'h1 : (5'hb == T_4794 ? (T_4019 | (1'h1 & 1'h1)) : (5'ha == T_4794 ? (T_4014 | (1'h1 & 1'h1)) : (5'h9 == T_4794 ? 1'h1 : (5'h8 == T_4794 ? 1'h1 : (5'h7 == T_4794 ? 1'h1 : (5'h6 == T_4794 ? (T_4001 | 1'h1) : (5'h5 == T_4794 ? (T_3997 | 1'h1) : (5'h4 == T_4794 ? (T_3993 | 1'h1) : (5'h3 == T_4794 ? 1'h1 : (5'h2 == T_4794 ? 1'h1 : (5'h1 == T_4794 ? (T_3982 | (1'h1 & 1'h1)) : (T_3978 | 1'h1))))))))))))))))))))))))))))))));
  assign T_4811 = 1'b1;
//  assign T_4814 = T_2046 ? (5'h1f == T_4794 ? 1'h1 : (5'h1e == T_4794 ? 1'h1 : (5'h1d == T_4794 ? (T_4098 | (1'h1 & 1'h1)) : (5'h1c == T_4794 ? (T_4093 | (1'h1 & 1'h1)) : (5'h1b == T_4794 ? 1'h1 : (5'h1a == T_4794 ? 1'h1 : (5'h19 == T_4794 ? (T_4076 | (((((((1'h1 & 1'h1) & 1'h1) & 1'h1) & 1'h1) & 1'h1) & 1'h1) & 1'h1)) : (5'h18 == T_4794 ? (T_4072 | 1'h1) : (5'h17 == T_4794 ? 1'h1 : (5'h16 == T_4794 ? 1'h1 : (5'h15 == T_4794 ? (T_4062 | 1'h1) : (5'h14 == T_4794 ? (T_4058 | 1'h1) : (5'h13 == T_4794 ? (T_4052 | ((1'h1 & 1'h1) & 1'h1)) : (5'h12 == T_4794 ? (T_4046 | ((1'h1 & 1'h1) & 1'h1)) : (5'h11 == T_4794 ? 1'h1 : (5'h10 == T_4794 ? (T_4036 | (((1'h1 & 1'h1) & 1'h1) & 1'h1)) : (5'hf == T_4794 ? 1'h1 : (5'he == T_4794 ? 1'h1 : (5'hd == T_4794 ? 1'h1 : (5'hc == T_4794 ? 1'h1 : (5'hb == T_4794 ? (T_4019 | (1'h1 & 1'h1)) : (5'ha == T_4794 ? (T_4014 | (1'h1 & 1'h1)) : (5'h9 == T_4794 ? 1'h1 : (5'h8 == T_4794 ? 1'h1 : (5'h7 == T_4794 ? 1'h1 : (5'h6 == T_4794 ? (T_4001 | 1'h1) : (5'h5 == T_4794 ? (T_3997 | 1'h1) : (5'h4 == T_4794 ? (T_3993 | 1'h1) : (5'h3 == T_4794 ? 1'h1 : (5'h2 == T_4794 ? 1'h1 : (5'h1 == T_4794 ? (T_3982 | (1'h1 & 1'h1)) : (T_3978 | 1'h1)))))))))))))))))))))))))))))))) : (5'h1f == T_4794 ? 1'h1 : (5'h1e == T_4794 ? 1'h1 : (5'h1d == T_4794 ? (T_4098 | (1'h1 & 1'h1)) : (5'h1c == T_4794 ? (T_4093 | (1'h1 & 1'h1)) : (5'h1b == T_4794 ? 1'h1 : (5'h1a == T_4794 ? 1'h1 : (5'h19 == T_4794 ? (T_4076 | (((((((1'h1 & 1'h1) & 1'h1) & 1'h1) & 1'h1) & 1'h1) & 1'h1) & 1'h1)) : (5'h18 == T_4794 ? (T_4072 | 1'h1) : (5'h17 == T_4794 ? 1'h1 : (5'h16 == T_4794 ? 1'h1 : (5'h15 == T_4794 ? (T_4062 | 1'h1) : (5'h14 == T_4794 ? (T_4058 | 1'h1) : (5'h13 == T_4794 ? (T_4052 | ((1'h1 & 1'h1) & 1'h1)) : (5'h12 == T_4794 ? (T_4046 | ((1'h1 & 1'h1) & 1'h1)) : (5'h11 == T_4794 ? 1'h1 : (5'h10 == T_4794 ? (T_4036 | (((1'h1 & 1'h1) & 1'h1) & 1'h1)) : (5'hf == T_4794 ? 1'h1 : (5'he == T_4794 ? 1'h1 : (5'hd == T_4794 ? 1'h1 : (5'hc == T_4794 ? 1'h1 : (5'hb == T_4794 ? (T_4019 | (1'h1 & 1'h1)) : (5'ha == T_4794 ? (T_4014 | (1'h1 & 1'h1)) : (5'h9 == T_4794 ? 1'h1 : (5'h8 == T_4794 ? 1'h1 : (5'h7 == T_4794 ? 1'h1 : (5'h6 == T_4794 ? (T_4001 | 1'h1) : (5'h5 == T_4794 ? (T_3997 | 1'h1) : (5'h4 == T_4794 ? (T_3993 | 1'h1) : (5'h3 == T_4794 ? 1'h1 : (5'h2 == T_4794 ? 1'h1 : (5'h1 == T_4794 ? (T_3982 | (1'h1 & 1'h1)) : (T_3978 | 1'h1))))))))))))))))))))))))))))))));
  assign T_4814 = 1'b1;
  assign T_4816 = io_tl_r_0_a_valid & T_4811;
//  assign T_4852 = (32'h1 << T_4794) & {2'h3,T_2245,T_2272,2'h3,T_2227,T_2218,2'h3,T_2281,T_2236,T_2317,T_2290,1'h1,T_2299,4'hf,T_2308,T_2209,2'h3,1'h1,T_2263,T_2200,T_2326,2'h3,T_2254,T_2191};
  assign T_4852 = (32'h1 << T_4794);
  assign T_4897 = T_4816 & io_tl_r_0_d_ready;
  assign T_4904 = T_4897 & ~T_2046;
  assign T_4926 = T_4904 & T_4852[1];
  assign T_5106 = T_4904 & T_4852[10];
  assign T_5126 = T_4904 & T_4852[11];
  assign T_5226 = T_4904 & T_4852[16];
  assign T_5406 = T_4904 & T_4852[25];
  assign T_5466 = T_4904 & T_4852[28];

  always @(posedge clock or posedge reset)
    if (reset) begin
      ctrl_fmt_proto <= 2'h0;
    end else begin
      if (T_5226 & T_3303) begin
        ctrl_fmt_proto <= io_tl_r_0_a_bits_data[1:0];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ctrl_fmt_endian <= 1'h0;
    end else begin
      if (T_5226 & ((~ T_2553[2]) == 1'h0)) begin
        ctrl_fmt_endian <= io_tl_r_0_a_bits_data[2];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ctrl_fmt_iodir <= 1'h0;
    end else begin
      if (T_5226 & ((~ T_2553[3]) == 1'h0)) begin
        ctrl_fmt_iodir <= io_tl_r_0_a_bits_data[3];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ctrl_fmt_len <= 4'h8;
    end else begin
      if (T_5226 & ((~ T_2553[19:16]) == 4'h0)) begin
        ctrl_fmt_len <= io_tl_r_0_a_bits_data[19:16];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ctrl_sck_div <= 12'h3;
    end else begin
      if (T_4904 & T_4852[0] & ((~ T_2553[11:0]) == 12'h0)) begin
        ctrl_sck_div <= io_tl_r_0_a_bits_data[11:0];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ctrl_sck_pol <= 1'h0;
    end else begin
      if (T_4926 & T_3183) begin
        ctrl_sck_pol <= io_tl_r_0_a_bits_data[1];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ctrl_sck_pha <= 1'h0;
    end else begin
      if (T_4926 & T_2623) begin
        ctrl_sck_pha <= io_tl_r_0_a_bits_data[0];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ctrl_cs_id <= 1'h0;
    end else begin
      if (T_4904 & T_4852[4] & T_2623) begin
        ctrl_cs_id <= io_tl_r_0_a_bits_data[0];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ctrl_cs_dflt_0 <= 1'h1;
    end else begin
      if (T_4904 & T_4852[5] & T_2623) begin
        ctrl_cs_dflt_0 <= io_tl_r_0_a_bits_data[0];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ctrl_cs_mode <= 2'h0;
    end else begin
      if (T_4904 & T_4852[6] & T_3303) begin
        ctrl_cs_mode <= io_tl_r_0_a_bits_data[1:0];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ctrl_dla_cssck <= 8'h1;
    end else begin
      if (T_5106 & T_2663) begin
        ctrl_dla_cssck <= io_tl_r_0_a_bits_data[7:0];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ctrl_dla_sckcs <= 8'h1;
    end else begin
      if (T_5106 & T_2703) begin
        ctrl_dla_sckcs <= io_tl_r_0_a_bits_data[23:16];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ctrl_dla_intercs <= 8'h1;
    end else begin
      if (T_5126 & T_2663) begin
        ctrl_dla_intercs <= io_tl_r_0_a_bits_data[7:0];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ctrl_dla_interxfr <= 8'h0;
    end else begin
      if (T_5126 & T_2703) begin
        ctrl_dla_interxfr <= io_tl_r_0_a_bits_data[23:16];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ctrl_wm_tx <= 4'h0;
    end else begin
      if (T_4904 & T_4852[20] & T_3103) begin
        ctrl_wm_tx <= io_tl_r_0_a_bits_data[3:0];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ctrl_wm_rx <= 4'h0;
    end else begin
      if (T_4904 & T_4852[21] & T_3103) begin
        ctrl_wm_rx <= io_tl_r_0_a_bits_data[3:0];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ie_txwm <= 1'h0;
    end else begin
      if (T_5466 & T_2623) begin
        ie_txwm <= io_tl_r_0_a_bits_data[0];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ie_rxwm <= 1'h0;
    end else begin
      if (T_5466 & T_3183) begin
        ie_rxwm <= io_tl_r_0_a_bits_data[1];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      insn_cmd_proto <= 2'h0;
    end else begin
      if (T_5406 & ((~ T_2553[9:8]) == 2'h0)) begin
        insn_cmd_proto <= io_tl_r_0_a_bits_data[9:8];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      insn_cmd_code <= 8'h3;
    end else begin
      if (T_5406 & T_2703) begin
        insn_cmd_code <= io_tl_r_0_a_bits_data[23:16];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      insn_cmd_en <= 1'h1;
    end else begin
      if (((T_5406 & 1'h1) & T_2623)) begin
        insn_cmd_en <= io_tl_r_0_a_bits_data[0];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      insn_addr_proto <= 2'h0;
    end else begin
      if (T_5406 & ((~ T_2553[11:10]) == 2'h0)) begin
        insn_addr_proto <= io_tl_r_0_a_bits_data[11:10];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      insn_addr_len <= 3'h3;
    end else begin
      if (T_5406 & ((~ T_2553[3:1]) == 3'h0)) begin
        insn_addr_len <= io_tl_r_0_a_bits_data[3:1];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      insn_pad_code <= 8'h0;
    end else begin
      if (T_5406 & ((~ T_2553[31:24]) == 8'h0)) begin
        insn_pad_code <= io_tl_r_0_a_bits_data[31:24];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      insn_pad_cnt <= 4'h0;
    end else begin
      if (T_5406 & ((~ T_2553[7:4]) == 4'h0)) begin
        insn_pad_cnt <= io_tl_r_0_a_bits_data[7:4];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      insn_data_proto <= 2'h0;
    end else begin
      if (T_5406 & ((~T_2553[13:12]) == 2'h0)) begin
        insn_data_proto <= io_tl_r_0_a_bits_data[13:12];
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      flash_en <= 1'h1;
    end else begin
      if (T_4904 & T_4852[24] & T_2623) begin
        flash_en <= io_tl_r_0_a_bits_data[0];
      end
    end

  always @(posedge clock or posedge reset) begin
  if(reset) begin
    a_size <= 3'b0;
    a_source <= 7'b0;
    a_address <= 30'b0;
  end
  else if (io_tl_f_0_a_ready & io_tl_f_0_a_valid) begin
    a_size <= io_tl_f_0_a_bits_size;
    a_source <= io_tl_f_0_a_bits_source;
    a_address <= io_tl_f_0_a_bits_address;
  end

  end

endmodule
