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
                                                                         
                                                                         
                                                                         

module sirv_qspi_fifo(
  input   clock,
  input   reset,
  input  [1:0] io_ctrl_fmt_proto,
  input   io_ctrl_fmt_endian,
  input   io_ctrl_fmt_iodir,
  input  [3:0] io_ctrl_fmt_len,
  input  [1:0] io_ctrl_cs_mode,
  input  [3:0] io_ctrl_wm_tx,
  input  [3:0] io_ctrl_wm_rx,
  input   io_link_tx_ready,
  output  io_link_tx_valid,
  output [7:0] io_link_tx_bits,
  input   io_link_rx_valid,
  input  [7:0] io_link_rx_bits,
  output [7:0] io_link_cnt,
  output [1:0] io_link_fmt_proto,
  output  io_link_fmt_endian,
  output  io_link_fmt_iodir,
  output  io_link_cs_set,
  output  io_link_cs_clear,
  output  io_link_cs_hold,
  input   io_link_active,
  output  io_link_lock,
  output  io_tx_ready,
  input   io_tx_valid,
  input  [7:0] io_tx_bits,
  input   io_rx_ready,
  output  io_rx_valid,
  output [7:0] io_rx_bits,
  output  io_ip_txwm,
  output  io_ip_rxwm
);
  wire  txq_io_enq_ready;
  wire  txq_io_deq_valid;
  wire [7:0] txq_io_deq_bits;
  wire [3:0] txq_io_count;
  wire  rxq_io_enq_ready;
  wire  rxq_io_deq_valid;
  wire [7:0] rxq_io_deq_bits;
  wire [3:0] rxq_io_count;
  wire  fire_tx;
  reg  rxen;
  reg [1:0] cs_mode;
  wire  cs_mode_off;
  sirv_queue_1 txq (
    .clock(clock),
    .reset(reset),
    .io_enq_ready(txq_io_enq_ready),
    .io_enq_valid(io_tx_valid),
    .io_enq_bits(io_tx_bits),
    .io_deq_ready(io_link_tx_ready),
    .io_deq_valid(txq_io_deq_valid),
    .io_deq_bits(txq_io_deq_bits),
    .io_count(txq_io_count)
  );
  sirv_queue_1 rxq (
    .clock(clock),
    .reset(reset),
    .io_enq_ready(rxq_io_enq_ready),
    .io_enq_valid((io_link_rx_valid & rxen)),
    .io_enq_bits(io_link_rx_bits),
    .io_deq_ready(io_rx_ready),
    .io_deq_valid(rxq_io_deq_valid),
    .io_deq_bits(rxq_io_deq_bits),
    .io_count(rxq_io_count)
  );
  assign io_link_tx_valid = txq_io_deq_valid;
  assign io_link_tx_bits = txq_io_deq_bits;
  assign io_link_cnt = 
      (((2'h0 == io_link_fmt_proto) ? io_ctrl_fmt_len : 4'h0) |
       ((2'h1 == io_link_fmt_proto) ? {1'h0,io_ctrl_fmt_len[3:1]} : 4'h0) |
       ((2'h2 == io_link_fmt_proto) ? {2'h0,io_ctrl_fmt_len[3:2]} : 4'h0))
      +
      // TODO: length correction element??? but this does not seem correct
      (((2'h0 == io_link_fmt_proto) & io_ctrl_fmt_len[0]) |
       ((2'h1 == io_link_fmt_proto) & (io_ctrl_fmt_len[1:0] != 2'h0)) | 
       ((2'h2 == io_link_fmt_proto) & (io_ctrl_fmt_len[2:0] != 3'h0)));
  assign io_link_fmt_proto = io_ctrl_fmt_proto;
  assign io_link_fmt_endian = io_ctrl_fmt_endian;
  assign io_link_fmt_iodir = io_ctrl_fmt_iodir;
  assign io_link_cs_set = ~cs_mode_off;
  assign io_link_cs_clear = ((cs_mode != io_ctrl_cs_mode) | (fire_tx & ~((cs_mode == 2'h2) | cs_mode_off)));
  assign io_link_cs_hold = 1'h0;
  assign io_link_lock = io_link_tx_valid | rxen;
  assign io_tx_ready = txq_io_enq_ready;
  assign io_rx_valid = rxq_io_deq_valid;
  assign io_rx_bits = rxq_io_deq_bits;
  assign io_ip_txwm = (txq_io_count < io_ctrl_wm_tx);
  assign io_ip_rxwm = (rxq_io_count > io_ctrl_wm_rx);
  assign fire_tx = io_link_tx_ready & io_link_tx_valid;
  assign cs_mode_off = cs_mode == 2'h3;

  always @(posedge clock or posedge reset)
    if (reset) begin
      rxen <= 1'h0;
    end else begin
      if (fire_tx) begin
        rxen <= ~io_link_fmt_iodir;
      end else if (io_link_rx_valid) begin
        rxen <= 1'h0;
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      cs_mode <= 2'h0;
    end else begin
      cs_mode <= io_ctrl_cs_mode;
    end

endmodule
