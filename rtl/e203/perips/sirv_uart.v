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
   - Replaced receiver module as the original one did not work with loopback
     to the transmitter module.

 */                                                                      
                                                                         
                                                                         
                                                                         

module sirv_uart(
  input   clock,
  input   reset,
  output  io_interrupts_0_0,
  output  io_in_0_a_ready,
  input   io_in_0_a_valid,
  input  [2:0] io_in_0_a_bits_opcode,
  input  [2:0] io_in_0_a_bits_param,
  input  [2:0] io_in_0_a_bits_size,
  input  [4:0] io_in_0_a_bits_source,
  input  [28:0] io_in_0_a_bits_address,
  input  [3:0] io_in_0_a_bits_mask,
  input  [31:0] io_in_0_a_bits_data,
  input   io_in_0_b_ready,
  output  io_in_0_b_valid,
  output [2:0] io_in_0_b_bits_opcode,
  output [1:0] io_in_0_b_bits_param,
  output [2:0] io_in_0_b_bits_size,
  output [4:0] io_in_0_b_bits_source,
  output [28:0] io_in_0_b_bits_address,
  output [3:0] io_in_0_b_bits_mask,
  output [31:0] io_in_0_b_bits_data,
  output  io_in_0_c_ready,
  input   io_in_0_c_valid,
  input  [2:0] io_in_0_c_bits_opcode,
  input  [2:0] io_in_0_c_bits_param,
  input  [2:0] io_in_0_c_bits_size,
  input  [4:0] io_in_0_c_bits_source,
  input  [28:0] io_in_0_c_bits_address,
  input  [31:0] io_in_0_c_bits_data,
  input   io_in_0_c_bits_error,
  input   io_in_0_d_ready,
  output  io_in_0_d_valid,
  output [2:0] io_in_0_d_bits_opcode,
  output [1:0] io_in_0_d_bits_param,
  output [2:0] io_in_0_d_bits_size,
  output [4:0] io_in_0_d_bits_source,
  output  io_in_0_d_bits_sink,
  output [1:0] io_in_0_d_bits_addr_lo,
  output [31:0] io_in_0_d_bits_data,
  output  io_in_0_d_bits_error,
  output  io_in_0_e_ready,
  input   io_in_0_e_valid,
  input   io_in_0_e_bits_sink,
  output  io_port_txd,
  input   io_port_rxd
);
  wire  txm_io_in_ready;
  wire  txm_io_out;
  wire  txq_io_enq_ready;
  wire  txq_io_deq_valid;
  wire [7:0] txq_io_deq_bits;
  wire [3:0] txq_io_count;
  wire  rxm_io_out_valid;
  wire [7:0] rxm_io_out_bits;
  wire  rxq_io_enq_ready;
  wire  rxq_io_deq_valid;
  wire [7:0] rxq_io_deq_bits;
  wire [3:0] rxq_io_count;
  reg [15:0] div;
  reg  txen;
  reg  rxen;
  reg [3:0] txwm;
  reg [3:0] rxwm;
  reg  nstop;
  reg  ie_rxwm;
  reg  ie_txwm;
  wire  T_916;
  wire  T_917;
  wire  T_968;
  wire [9:0] T_972;
  wire  T_1065;
//  wire  T_1074;
//  wire  T_1083;
//  wire  T_1092;
//  wire  T_1101;
//  wire  T_1110;
//  wire  T_1119;
  wire [31:0] T_1226;
  wire  T_1376;
  wire  T_1416;
  wire  T_1696;
//  wire  T_1891;
//  wire  T_1897;
//  wire  T_1903;
//  wire  T_1909;
//  wire  T_1914;
//  wire  T_1919;
//  wire  T_1924;
  wire [2:0] T_2149;
  wire  T_2164;
  wire  T_2167;
  wire  T_2169;
  wire [7:0] T_2181;
  wire  T_2202;
  wire  T_2209;
  wire  T_2251;
  wire  T_2271;
  wire  T_2291;
  sirv_uarttx u_txm (
    .clock(clock),
    .reset(reset),
    .io_en(txen),
    .io_in_ready(txm_io_in_ready),
    .io_in_valid(txq_io_deq_valid),
    .io_in_bits(txq_io_deq_bits),
    .io_out(txm_io_out),
    .io_div(div),
    .io_nstop(nstop)
  );
  sirv_queue_1 u_txq (
    .clock(clock),
    .reset(reset),
    .io_enq_ready(txq_io_enq_ready),
    .io_enq_valid(((((T_2209 & T_2181[0]) & 1'h1) & 1'h1) & ((~ T_1226[7:0]) == 8'h0))),
    .io_enq_bits(io_in_0_a_bits_data[7:0]),
    .io_deq_ready(txm_io_in_ready),
    .io_deq_valid(txq_io_deq_valid),
    .io_deq_bits(txq_io_deq_bits),
    .io_count(txq_io_count)
  );
//  sirv_uartrx u_rxm (
//    .clock(clock),
//    .reset(reset),
//    .io_en(rxen),
//    .io_in(io_port_rxd),
//    .io_out_valid(rxm_io_out_valid),
//    .io_out_bits(rxm_io_out_bits),
//    .io_div(div)
//  );
  uart_rx u_rxm(
    .clock(clock),
    .reset(reset),
    .io_en(rxen),
    .io_in(io_port_rxd),
    .io_out_valid(rxm_io_out_valid),
    .io_out_bits(rxm_io_out_bits),
    .io_div(div),
    .LCR({5'd0,nstop,2'b11}),
    .rx_idle(),
    .parity_error(),
    .framing_error(),
    .break_error()
  );
  sirv_queue_1 u_rxq (
    .clock(clock),
    .reset(reset),
    .io_enq_ready(rxq_io_enq_ready),
    .io_enq_valid(rxm_io_out_valid),
    .io_enq_bits(rxm_io_out_bits),
    .io_deq_ready((((((T_2202 & T_968) & T_2181[1]) & 1'h1) & 1'h1) & (T_1226[7:0] != 8'h0))),
    .io_deq_valid(rxq_io_deq_valid),
    .io_deq_bits(rxq_io_deq_bits),
    .io_count(rxq_io_count)
  );
  assign io_interrupts_0_0 = ((T_916 & ie_txwm) | (T_917 & ie_rxwm));
  assign io_in_0_a_ready = ((io_in_0_d_ready & T_2167) & T_2164);
  assign io_in_0_b_valid = 1'h0;
  assign io_in_0_b_bits_opcode = 3'b0;
  assign io_in_0_b_bits_param = 2'b0;
  assign io_in_0_b_bits_size = 3'b0;
  assign io_in_0_b_bits_source = 5'b0;
  assign io_in_0_b_bits_address = 29'b0;
  assign io_in_0_b_bits_mask = 4'b0;
  assign io_in_0_b_bits_data = 32'b0;
  assign io_in_0_c_ready = 1'h1;
  assign io_in_0_d_valid = (T_2169 & T_2167);
  assign io_in_0_d_bits_opcode = {{2'd0}, T_968};
  assign io_in_0_d_bits_param = 2'h0;
  assign io_in_0_d_bits_size = T_972[2:0];
  assign io_in_0_d_bits_source = T_972[7:3];
  assign io_in_0_d_bits_sink = 1'h0;
  assign io_in_0_d_bits_addr_lo = T_972[9:8];
//  assign io_in_0_d_bits_data = ((3'h7 == T_2149 ? 1'h1 : (3'h6 == T_2149 ? T_1092 : (3'h5 == T_2149 ? T_1074 : (3'h4 == T_2149 ? T_1119 : (3'h3 == T_2149 ? T_1110 : (3'h2 == T_2149 ? T_1101 : (3'h1 == T_2149 ? T_1083 : T_1065))))))) ? (3'h7 == T_2149 ? 32'h0 : (3'h6 == T_2149 ? ({{16'd0}, div}) : (3'h5 == T_2149 ? ({{30'd0}, (({{1'd0}, T_916}) | (({{1'd0}, T_917}) << 1))}) : (3'h4 == T_2149 ? ({{30'd0}, (({{1'd0}, ie_txwm}) | (({{1'd0}, ie_rxwm}) << 1))}) : (3'h3 == T_2149 ? ({{12'd0}, (({{19'd0}, rxen}) | (({{16'd0}, rxwm}) << 16))}) : (3'h2 == T_2149 ? ({{12'd0}, (({{18'd0}, (({{1'd0}, txen}) | (({{1'd0}, nstop}) << 1))}) | (({{16'd0}, txwm}) << 16))}) : (3'h1 == T_2149 ? (({{1'd0}, ({{23'd0}, rxq_io_deq_bits})}) | (({{31'd0}, (rxq_io_deq_valid == 1'h0)}) << 31)) : (({{31'd0}, (txq_io_enq_ready == 1'h0)}) << 31)))))))) : 32'h0);
  assign io_in_0_d_bits_data = T_1065 ? (3'h7 == T_2149 ? 32'h0 : (3'h6 == T_2149 ? ({16'd0, div}) : (3'h5 == T_2149 ? {30'd0,T_917,T_916} : (3'h4 == T_2149 ? {30'd0,ie_rxwm,ie_txwm} : (3'h3 == T_2149 ? {16'd0,rxwm,15'd0,rxen} : (3'h2 == T_2149 ? {12'd0,txwm,14'd0,nstop,txen} : (3'h1 == T_2149 ? {~rxq_io_deq_valid,23'd0,rxq_io_deq_bits} : {~txq_io_enq_ready,31'd0} ))))))) : 32'h0;
  assign io_in_0_d_bits_error = 1'h0;
  assign io_in_0_e_ready = 1'h1;
  assign io_port_txd = txm_io_out;
  assign T_916 = txq_io_count < txwm;
  assign T_917 = rxq_io_count > rxwm;
  assign T_968 = io_in_0_a_bits_opcode == 3'h4;
  assign T_972 = {io_in_0_a_bits_address[1:0],io_in_0_a_bits_source,io_in_0_a_bits_size};
//  assign T_1065 = (io_in_0_a_bits_address[11:2] & 10'h3f8) == 10'h0;
  assign T_1065 = io_in_0_a_bits_address[11:5] == 10'h0;
//  assign T_1074 = ((io_in_0_a_bits_address[11:2] ^ 10'h5) & 10'h3f8) == 10'h0;
//  assign T_1083 = ((io_in_0_a_bits_address[11:2] ^ 10'h1) & 10'h3f8) == 10'h0;
//  assign T_1092 = ((io_in_0_a_bits_address[11:2] ^ 10'h6) & 10'h3f8) == 10'h0;
//  assign T_1101 = ((io_in_0_a_bits_address[11:2] ^ 10'h2) & 10'h3f8) == 10'h0;
//  assign T_1110 = ((io_in_0_a_bits_address[11:2] ^ 10'h3) & 10'h3f8) == 10'h0;
//  assign T_1119 = ((io_in_0_a_bits_address[11:2] ^ 10'h4) & 10'h3f8) == 10'h0;
//  assign T_1226 = {({(io_in_0_a_bits_mask[3] ? 8'hff : 8'h0),(io_in_0_a_bits_mask[2] ? 8'hff : 8'h0)}),({(io_in_0_a_bits_mask[1] ? 8'hff : 8'h0),(io_in_0_a_bits_mask[0] ? 8'hff : 8'h0)})};
  assign T_1226 = { {8{io_in_0_a_bits_mask[3]}}, {8{io_in_0_a_bits_mask[2]}}, {8{io_in_0_a_bits_mask[1]}}, {8{io_in_0_a_bits_mask[0]}} };
  assign T_1376 = T_1226[0];
  assign T_1416 = T_1226[1];
  assign T_1696 = T_1226[19:16] == 4'hf;
//  assign T_1891 = ~T_1065;
//  assign T_1897 = ~T_1083;
//  assign T_1903 = ~T_1101;
//  assign T_1909 = ~T_1110;
//  assign T_1914 = ~T_1119;
//  assign T_1919 = ~T_1074;
//  assign T_1924 = ~T_1092;
  assign T_2149 = io_in_0_a_bits_address[4:2];
//  assign T_2164 = T_968 ? (3'h7 == T_2149 ? 1'h1 : (3'h6 == T_2149 ? (T_1924 | 1'h1) : (3'h5 == T_2149 ? (T_1919 | (1'h1 & 1'h1)) : (3'h4 == T_2149 ? (T_1914 | (1'h1 & 1'h1)) : (3'h3 == T_2149 ? (T_1909 | (1'h1 & 1'h1)) : (3'h2 == T_2149 ? (T_1903 | ((1'h1 & 1'h1) & 1'h1)) : (3'h1 == T_2149 ? (T_1897 | ((1'h1 & 1'h1) & 1'h1)) : (T_1891 | ((1'h1 & 1'h1) & 1'h1))))))))) : (3'h7 == T_2149 ? 1'h1 : (3'h6 == T_2149 ? (T_1924 | 1'h1) : (3'h5 == T_2149 ? (T_1919 | (1'h1 & 1'h1)) : (3'h4 == T_2149 ? (T_1914 | (1'h1 & 1'h1)) : (3'h3 == T_2149 ? (T_1909 | (1'h1 & 1'h1)) : (3'h2 == T_2149 ? (T_1903 | ((1'h1 & 1'h1) & 1'h1)) : (3'h1 == T_2149 ? (T_1897 | ((1'h1 & 1'h1) & 1'h1)) : (T_1891 | ((1'h1 & 1'h1) & 1'h1)))))))));
  assign T_2164 = 1'b1;
//  assign T_2167 = T_968 ? (3'h7 == T_2149 ? 1'h1 : (3'h6 == T_2149 ? (T_1924 | 1'h1) : (3'h5 == T_2149 ? (T_1919 | (1'h1 & 1'h1)) : (3'h4 == T_2149 ? (T_1914 | (1'h1 & 1'h1)) : (3'h3 == T_2149 ? (T_1909 | (1'h1 & 1'h1)) : (3'h2 == T_2149 ? (T_1903 | ((1'h1 & 1'h1) & 1'h1)) : (3'h1 == T_2149 ? (T_1897 | ((1'h1 & 1'h1) & 1'h1)) : (T_1891 | ((1'h1 & 1'h1) & 1'h1))))))))) : (3'h7 == T_2149 ? 1'h1 : (3'h6 == T_2149 ? (T_1924 | 1'h1) : (3'h5 == T_2149 ? (T_1919 | (1'h1 & 1'h1)) : (3'h4 == T_2149 ? (T_1914 | (1'h1 & 1'h1)) : (3'h3 == T_2149 ? (T_1909 | (1'h1 & 1'h1)) : (3'h2 == T_2149 ? (T_1903 | ((1'h1 & 1'h1) & 1'h1)) : (3'h1 == T_2149 ? (T_1897 | ((1'h1 & 1'h1) & 1'h1)) : (T_1891 | ((1'h1 & 1'h1) & 1'h1)))))))));
  assign T_2167 = 1'b1;
  assign T_2169 = io_in_0_a_valid & T_2164;
//  assign T_2181 = (8'h1 << T_2149) & ({({({1'h1,T_1092}),({T_1074,T_1119})}),({({T_1110,T_1101}),({T_1083,T_1065})})});
  assign T_2181 = (8'h1 << T_2149);
  assign T_2202 = T_2169 & io_in_0_d_ready;
  assign T_2209 = T_2202 & ~T_968;
  assign T_2251 = T_2209 & T_2181[2];
  assign T_2271 = T_2209 & T_2181[3];
  assign T_2291 = T_2209 & T_2181[4];

  always @(posedge clock or posedge reset)
    if (reset) begin
      div <= 16'h21e;
    end else if (T_2209 & T_2181[6] & ((~T_1226[15:0]) == 16'h0)) begin
      div <= io_in_0_a_bits_data[15:0];
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      txen <= 1'h0;
    end else if (T_2251 & T_1376) begin
      txen <= io_in_0_a_bits_data[0];
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      rxen <= 1'h0;
    end else if (T_2271 & T_1376) begin
      rxen <= io_in_0_a_bits_data[0];
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      txwm <= 4'h0;
    end else if (T_2251 & T_1696) begin
      txwm <= io_in_0_a_bits_data[19:16];
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      rxwm <= 4'h0;
    end else if (T_2271 & T_1696) begin
      rxwm <= io_in_0_a_bits_data[19:16];
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      nstop <= 1'h0;
    end else if (T_2251 & T_1416) begin
      nstop <= io_in_0_a_bits_data[1];
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ie_rxwm <= 1'h0;
    end else if (T_2291 & T_1416) begin
      ie_rxwm <= io_in_0_a_bits_data[1];
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      ie_txwm <= 1'h0;
    end else if (T_2291 & T_1376) begin
      ie_txwm <= io_in_0_a_bits_data[0];
    end

endmodule
