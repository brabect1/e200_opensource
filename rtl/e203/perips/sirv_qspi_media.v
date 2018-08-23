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
                                                                         
                                                                         
                                                                         

module sirv_qspi_media(
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
  input  [11:0] io_ctrl_sck_div,
  input   io_ctrl_sck_pol,
  input   io_ctrl_sck_pha,
  input  [7:0] io_ctrl_dla_cssck,
  input  [7:0] io_ctrl_dla_sckcs,
  input  [7:0] io_ctrl_dla_intercs,
  input  [7:0] io_ctrl_dla_interxfr,
  input   io_ctrl_cs_id,
  input   io_ctrl_cs_dflt_0,
  output  io_link_tx_ready,
  input   io_link_tx_valid,
  input  [7:0] io_link_tx_bits,
  output  io_link_rx_valid,
  output [7:0] io_link_rx_bits,
  input  [7:0] io_link_cnt,
  input  [1:0] io_link_fmt_proto,
  input   io_link_fmt_endian,
  input   io_link_fmt_iodir,
//---->>>> TBD: need to understand the following signals (how they are driven and what is their meaning and mutual relation)
  input   io_link_cs_set,
  input   io_link_cs_clear,
  input   io_link_cs_hold,
//<<<<----
  output  io_link_active
);
  wire  phy_io_port_sck;
  wire  phy_io_port_dq_0_o;
  wire  phy_io_port_dq_0_oe;
  wire  phy_io_port_dq_1_o;
  wire  phy_io_port_dq_1_oe;
  wire  phy_io_port_dq_2_o;
  wire  phy_io_port_dq_2_oe;
  wire  phy_io_port_dq_3_o;
  wire  phy_io_port_dq_3_oe;
//  wire  phy_io_port_cs_0;
  wire  io_op_ready;
  wire  io_rx_valid;
  wire [7:0] io_rx_bits;
  reg  cs_id;
  reg  cs_dflt_0;
  reg  cs_set; // TBD: naming
  wire T_163; // combo input to cs_dflt_0 (i.e. CS output), if there were multiple CSs, this will be a vector
  reg  clear; // TBD: naming
  reg  cs_assert;
  wire  cs_deassert; // TBD: naming
  wire  continuous;
  reg [1:0] state;
  wire  s_main;
//  wire [1:0] GEN_2;
//  wire  T_184;
//  wire  T_186;
//  wire  T_188;
  wire  T_189; // tx start = T_189 & io_op_ready
  wire  T_195; // tx idle
  wire  s_interxfr;
//  wire  T_201;
  wire  io_op_valid;
  wire  s_intercs;
  sirv_qspi_physical phy (
    .clock(clock),
    .reset(reset),
    .io_port_sck(phy_io_port_sck),
    .io_port_dq_0_i(io_port_dq_0_i),
    .io_port_dq_0_o(phy_io_port_dq_0_o),
    .io_port_dq_0_oe(phy_io_port_dq_0_oe),
    .io_port_dq_1_i(io_port_dq_1_i),
    .io_port_dq_1_o(phy_io_port_dq_1_o),
    .io_port_dq_1_oe(phy_io_port_dq_1_oe),
    .io_port_dq_2_i(io_port_dq_2_i),
    .io_port_dq_2_o(phy_io_port_dq_2_o),
    .io_port_dq_2_oe(phy_io_port_dq_2_oe),
    .io_port_dq_3_i(io_port_dq_3_i),
    .io_port_dq_3_o(phy_io_port_dq_3_o),
    .io_port_dq_3_oe(phy_io_port_dq_3_oe),
    .io_port_cs_0(), // (phy_io_port_cs_0),
    .io_ctrl_sck_div(io_ctrl_sck_div),
    .io_ctrl_sck_pol(io_ctrl_sck_pol),
    .io_ctrl_sck_pha(io_ctrl_sck_pha),
    .io_ctrl_fmt_proto(io_link_fmt_proto),
    .io_ctrl_fmt_endian(io_link_fmt_endian),
    .io_ctrl_fmt_iodir(io_link_fmt_iodir),
    .io_op_ready(io_op_ready), // micro-op handshake (acknowledge)
    .io_op_valid(io_op_valid), // micro-op handshake (request)
    .io_op_bits_fn(~(s_main & cs_assert & ~cs_deassert)), // micro-op: 0=xfer, 1=delay
    .io_op_bits_stb(s_intercs | (s_main & T_195) | (s_main & cs_assert & ~cs_deassert)),
    .io_op_bits_cnt(
        (s_intercs ? io_ctrl_dla_intercs : 
        (s_interxfr ? io_ctrl_dla_interxfr :
        (s_main ? (T_195 ? 8'h0 : (T_189 ? io_ctrl_dla_cssck : (cs_assert ? (cs_deassert ? io_ctrl_dla_sckcs : io_link_cnt) : io_link_cnt))) : io_link_cnt)))
          // when io_op_valid==1, then the micro-op corresponds to
          //   idle state:              s_main & T_195=(~cs_assert & ~io_link_tx_valid)
          //   cs to data start:        s_main & T_189=(~cs_assert &  io_link_tx_valid)
          //   data xfer:               s_main & cs_assert & ~cs_deassert
          //   data end to cs:          s_main & cs_assert &  cs_deassert
          //   data end to data start:  s_interxfr
          //   cs inactive:             s_intercs
    ),
    .io_op_bits_data(io_link_tx_bits),
    .io_rx_valid(io_rx_valid),
    .io_rx_bits(io_rx_bits)
  );
  assign io_port_sck = phy_io_port_sck;
  assign io_port_dq_0_o = phy_io_port_dq_0_o;
  assign io_port_dq_0_oe = phy_io_port_dq_0_oe;
  assign io_port_dq_1_o = phy_io_port_dq_1_o;
  assign io_port_dq_1_oe = phy_io_port_dq_1_oe;
  assign io_port_dq_2_o = phy_io_port_dq_2_o;
  assign io_port_dq_2_oe = phy_io_port_dq_2_oe;
  assign io_port_dq_3_o = phy_io_port_dq_3_o;
  assign io_port_dq_3_oe = phy_io_port_dq_3_oe;
  assign io_port_cs_0 = cs_dflt_0;
  assign io_link_tx_ready = s_main & cs_assert & ~cs_deassert & io_op_ready;
  assign io_link_rx_valid = io_rx_valid;
  assign io_link_rx_bits = io_rx_bits;
  assign io_link_active = cs_assert;
  // if there were multiple CSs, then `~io_ctrl_cs_id` would become 
  // `1 << io_ctrl_cs_id` (i.e. binary to one hot decoder)
  assign T_163 = io_ctrl_cs_dflt_0 ^ (io_link_cs_set & ~io_ctrl_cs_id);
  assign cs_deassert = clear | ((T_163 != cs_dflt_0) & ~io_link_cs_hold);
  assign continuous = io_ctrl_dla_interxfr == 8'h0; // TBD: This should get locked at the start of transfer.
  assign s_main = (2'h0 == state);
//  assign GEN_2 = cs_deassert ? (io_op_ready ? 2'h2 : state) : state;
//  assign T_184 = ~cs_deassert;
//  assign T_186 = io_op_ready & io_op_valid;
//  assign T_188 = cs_assert == 1'h0;
  assign T_189 = ~cs_assert &  io_link_tx_valid;
  assign T_195 = ~cs_assert & ~io_link_tx_valid;
  assign s_interxfr = 2'h1 == state;
//  assign T_201 = io_op_ready | continuous;
  assign io_op_valid = (s_interxfr & ~continuous) | (s_main & cs_assert & ~cs_deassert & io_link_tx_valid);
  assign s_intercs = 2'h2 == state;

  always @(posedge clock or posedge reset)
  if(reset) begin
    cs_id     <= 2'b0;
    cs_dflt_0 <= 1'b1;
    cs_set    <= 1'b0;
  end
  else begin//{

    if (s_main) begin
      if (T_195) begin
        cs_id <= io_ctrl_cs_id;
      end
      if (T_189 & io_op_ready) begin
        cs_set <= io_link_cs_set;
      end
    end

    if (s_intercs & io_op_ready) begin
      cs_dflt_0 <= (cs_dflt_0 ^ (cs_set << cs_id));
    end else if (s_main) begin
      if (T_195) begin
        // link is idle
        cs_dflt_0 <= io_ctrl_cs_dflt_0;
      end else if (T_189 & io_op_ready) begin
        // xfr start
        cs_dflt_0 <= T_163;
      end
    end

  end//}

  always @(posedge clock or posedge reset)
    if (reset) begin
      clear <= 1'h0;
    end else begin
      if (s_intercs) begin
        clear <= 1'h0;
      end else if (io_link_cs_clear & cs_assert) begin
        clear <= 1'h1;
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      cs_assert <= 1'h0;
    end else begin
      if (s_intercs) begin
        cs_assert <= 1'h0;
      end else if (s_main & T_189 & io_op_ready) begin
        cs_assert <= 1'h1;
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      state <= 2'h0;
    end else begin
      if (s_intercs) begin
        if (io_op_ready) begin
          state <= 2'h0; // to s_main
//        end else begin
//          if (s_interxfr) begin
//            if (T_201) begin
//              state <= 2'h0;
//            end else begin
//              if (s_main) begin
//                if (cs_assert) begin
//                  if (T_184) begin
//                    if (T_186) begin
//                      state <= 2'h1;
//                    end else begin
//                      if (cs_deassert) begin
//                        if (io_op_ready) begin
//                          state <= 2'h2;
//                        end
//                      end
//                    end
//                  end else begin
//                    if (cs_deassert) begin
//                      if (io_op_ready) begin
//                        state <= 2'h2;
//                      end
//                    end
//                  end
//                end
//              end
//            end
//          end else begin
//            if (s_main) begin
//              if (cs_assert) begin
//                if (T_184) begin
//                  if (T_186) begin
//                    state <= 2'h1;
//                  end else begin
//                    if (cs_deassert) begin
//                      if (io_op_ready) begin
//                        state <= 2'h2;
//                      end
//                    end
//                  end
//                end else begin
//                  if (cs_deassert) begin
//                    if (io_op_ready) begin
//                      state <= 2'h2;
//                    end
//                  end
//                end
//              end
//            end
//          end
        end
      end else if (s_interxfr) begin
        if (io_op_ready | continuous) begin
          state <= 2'h0; // to s_main
//        end else begin
//          if (s_main) begin
//            if (cs_assert) begin
//              if (T_184 & T_186) begin
//                state <= 2'h1;
//              end else begin
//                state <= GEN_2;
//              end
//            end
//          end
        end
      end else if (s_main) begin
          if (cs_assert) begin
            if (~cs_deassert & io_op_ready & io_op_valid) begin
              state <= 2'h1; // to s_intercs
            end else if (cs_deassert & io_op_ready) begin
              state <= 2'h2; // to s_interxfr
            end
          end
      end
    end

endmodule
