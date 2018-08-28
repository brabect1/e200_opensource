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
   - Made the formatting settings be latched so that users can change formatting
     without adverse effects on an in-flight flash transaction.

 */                                                                      
                                                                         
                                                                         
                                                                         

module sirv_qspi_flashmap(
  input   clock,
  input   reset,
  input   io_en,
  input  [1:0] io_ctrl_insn_cmd_proto,
  input  [7:0] io_ctrl_insn_cmd_code,
  input   io_ctrl_insn_cmd_en,
  input  [1:0] io_ctrl_insn_addr_proto,
  input  [2:0] io_ctrl_insn_addr_len,
  input  [7:0] io_ctrl_insn_pad_code,
  input  [3:0] io_ctrl_insn_pad_cnt,
  input  [1:0] io_ctrl_insn_data_proto,
  input   io_ctrl_fmt_endian,
  output  io_addr_ready,
  input   io_addr_valid,
  input  [31:0] io_addr_bits_next,
  input  [31:0] io_addr_bits_hold,
  input   io_data_ready,
  output  io_data_valid,
  output [7:0] io_data_bits,
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
  output  io_link_lock
);
  wire [1:0] ctrl_insn_cmd_proto;
  wire [7:0] ctrl_insn_cmd_code;
  wire  ctrl_insn_cmd_en;
  wire [1:0] ctrl_insn_addr_proto;
  wire [2:0] ctrl_insn_addr_len;
  wire [7:0] ctrl_insn_pad_code;
  wire [3:0] ctrl_insn_pad_cnt;
  wire [1:0] ctrl_insn_data_proto;
  wire  ctrl_fmt_endian;
  reg [1:0] latched_ctrl_insn_cmd_proto;
  reg [7:0] latched_ctrl_insn_cmd_code;
  reg  latched_ctrl_insn_cmd_en;
  reg [1:0] latched_ctrl_insn_addr_proto;
  reg [2:0] latched_ctrl_insn_addr_len;
  reg [7:0] latched_ctrl_insn_pad_code;
  reg [3:0] latched_ctrl_insn_pad_cnt;
  reg [1:0] latched_ctrl_insn_data_proto;
  reg  latched_ctrl_fmt_endian;
  wire  merge;
  reg [3:0] cnt;
  wire  cnt_cmp_0;
  wire  cnt_cmp_1;
  wire  cnt_done;
  wire  T_144;
  wire [4:0] T_146;
  reg [2:0] state;
  wire  s_idle;
  wire  T_153;
  wire  T_160;
  wire [2:0] GEN_19;
  wire  s_cmd;
  wire [2:0] GEN_28;
  wire  s_addr;
  wire [2:0] GEN_33;
  wire  s_pad;
  wire  s_pre;
  wire  s_data_post;
  assign io_addr_ready = (s_idle ? (T_160 ? io_data_ready : io_en) : 1'h0);
  assign io_data_valid = (s_data_post ? io_link_rx_valid : (s_idle ? (T_160 ? io_addr_valid : 1'h0) : 1'h0));
  assign io_data_bits = (s_idle ? (T_160 ? 8'h0 : io_link_rx_bits) : io_link_rx_bits);
  assign io_link_tx_valid = (s_data_post ? 1'h0 : (s_idle ? 1'h0 : (s_addr ? (cnt_cmp_0 == 1'h0) : 1'h1)));
  assign io_link_tx_bits = (s_pad ? ctrl_insn_pad_code : (s_addr ? ((((cnt_cmp_1 ? io_addr_bits_hold[7:0] : 8'h0) | ((cnt == 4'h2) ? io_addr_bits_hold[15:8] : 8'h0)) | ((cnt == 4'h3) ? io_addr_bits_hold[23:16] : 8'h0)) | ((cnt == 4'h4) ? io_addr_bits_hold[31:24] : 8'h0)) : ctrl_insn_cmd_code));
  assign io_link_cnt = {{4'd0}, (s_pad ? ctrl_insn_pad_cnt : ((((2'h0 == io_link_fmt_proto) ? 4'h8 : 4'h0) | ({{1'd0}, ((2'h1 == io_link_fmt_proto) ? 3'h4 : 3'h0)})) | ({{2'd0}, ((2'h2 == io_link_fmt_proto) ? 2'h2 : 2'h0)})))};
  assign io_link_fmt_proto = (s_pre ? ctrl_insn_data_proto : (s_cmd ? ctrl_insn_cmd_proto : ctrl_insn_addr_proto));
  assign io_link_fmt_endian = ctrl_fmt_endian;
  assign io_link_fmt_iodir = ~s_pre;
  assign io_link_cs_set = 1'h1;
  assign io_link_cs_clear = s_idle & io_en & io_addr_valid & T_153;
  assign io_link_cs_hold = 1'h1;
  assign io_link_lock = (~s_idle | (~T_160 & (~io_en | io_addr_valid)));
  assign merge = io_link_active & (io_addr_bits_next == (io_addr_bits_hold + 32'h1));
  assign cnt_cmp_0 = cnt == 4'h0;
  assign cnt_cmp_1 = cnt == 4'h1;
  assign cnt_done = (cnt_cmp_1 & io_link_tx_ready) | cnt_cmp_0;
  assign T_144 = io_link_tx_ready & io_link_tx_valid;
  assign T_146 = cnt - 4'h1;
  assign T_153 = ~merge;
  assign T_160 = ~io_en;
  assign GEN_19 = s_idle ? (io_en ? (io_addr_valid ? (T_153 ? (ctrl_insn_cmd_en ? 3'h1 : 3'h2) : (merge ? 3'h4 : state)) : state) : state) : state;
  assign GEN_28 = (s_cmd & io_link_tx_ready) ? 3'h2 : GEN_19;
  assign GEN_33 = (s_addr & cnt_done) ? 3'h3 : GEN_28;
  assign s_idle = 3'h0 == state;
  assign s_cmd = 3'h1 == state;
  assign s_addr = 3'h2 == state;
  assign s_pad = 3'h3 == state;
  assign s_pre = 3'h4 == state;
  assign s_data_post = 3'h5 == state;

  always @(posedge clock or posedge reset)
  if (reset) begin
     cnt <= 4'b0;
  end
  else begin
    if (s_cmd & io_link_tx_ready) begin
      cnt <= {1'd0, ctrl_insn_addr_len};
    end else if (s_addr & T_144) begin
      cnt <= T_146[3:0];
    end
  end

  always @(posedge clock or posedge reset)
    if (reset) begin
      state <= 3'h0;
    end else begin
      if (s_data_post) begin
        if ((io_data_ready & io_data_valid)) begin
          state <= 3'h0;
        end else begin
          if (s_pre) begin
                $fatal(1,"line 132");
            if (io_link_tx_ready) begin
              state <= 3'h5;
            end else begin
              if (s_pad) begin
                $fatal(1,"line 138");
                if (io_link_tx_ready) begin
                  state <= 3'h4;
                end else begin
                  if (s_addr) begin
                    $fatal(1,"line 143");
                    if (cnt_done) begin
                      state <= 3'h3;
                    end else begin
                      if (s_cmd) begin
                        $fatal(1,"line 148");
                        if (io_link_tx_ready) begin
                          state <= 3'h2;
                        end else begin
                          if (s_idle) begin
                            $fatal(1,"line 153");
                            if (io_en) begin
                              if (io_addr_valid) begin
                                if (T_153) begin
                                  if (ctrl_insn_cmd_en) begin
                                    state <= 3'h1;
                                  end else begin
                                    state <= 3'h2;
                                  end
                                end else begin
                                  if (merge) begin
                                    state <= 3'h4;
                                  end
                                end
                              end
                            end
                          end
                        end
                      end else begin
                        if (s_idle) begin
                          $fatal(1,"line 172");
                          if (io_en) begin
                            if (io_addr_valid) begin
                              if (T_153) begin
                                if (ctrl_insn_cmd_en) begin
                                  state <= 3'h1;
                                end else begin
                                  state <= 3'h2;
                                end
                              end else begin
                                if (merge) begin
                                  state <= 3'h4;
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end else begin
                    if (s_cmd) begin
                      $fatal(1,"line 194");
                      if (io_link_tx_ready) begin
                        state <= 3'h2;
                      end else begin
                        if (s_idle) begin
                          $fatal(1,"line 199");
                          if (io_en) begin
                            if (io_addr_valid) begin
                              if (T_153) begin
                                if (ctrl_insn_cmd_en) begin
                                  state <= 3'h1;
                                end else begin
                                  state <= 3'h2;
                                end
                              end else begin
                                if (merge) begin
                                  state <= 3'h4;
                                end
                              end
                            end
                          end
                        end
                      end
                    end else begin
                      if (s_idle) begin
                        $fatal(1,"line 219");
                        if (io_en) begin
                          if (io_addr_valid) begin
                            if (T_153) begin
                              if (ctrl_insn_cmd_en) begin
                                state <= 3'h1;
                              end else begin
                                state <= 3'h2;
                              end
                            end else begin
                              if (merge) begin
                                state <= 3'h4;
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end else begin
                if (s_addr) begin
                  $fatal(1,"line 241");
                  if (cnt_done) begin
                    state <= 3'h3;
                  end else begin
                    if (s_cmd) begin
                      $fatal(1,"line 246");
                      if (io_link_tx_ready) begin
                        state <= 3'h2;
                      end else begin
                        state <= GEN_19;
                      end
                    end else begin
                      state <= GEN_19;
                    end
                  end
                end else begin
                  if (s_cmd) begin
                    $fatal(1,"line 258");
                    if (io_link_tx_ready) begin
                      state <= 3'h2;
                    end else begin
                      state <= GEN_19;
                    end
                  end else begin
                    state <= GEN_19;
                  end
                end
              end
            end
//
          end else begin
            if (s_pad) begin
              if (io_link_tx_ready) begin
                state <= 3'h4;
              end else begin
                if (s_addr) begin
                  if (cnt_done) begin
                    state <= 3'h3;
                  end else begin
                    state <= GEN_28;
                  end
                end else begin
                  state <= GEN_28;
                end
              end
            end else begin
              if (s_addr) begin
                if (cnt_done) begin
                  state <= 3'h3;
                end else begin
                  state <= GEN_28;
                end
              end else begin
                state <= GEN_28;
              end
            end
          end
        end
      end else begin
        if (s_pre) begin
          if (io_link_tx_ready) begin
            state <= 3'h5;
          end else begin
            if (s_pad) begin
              if (io_link_tx_ready) begin
                state <= 3'h4;
              end else begin
                state <= GEN_33;
              end
            end else begin
              state <= GEN_33;
            end
          end
        end else begin
          if (s_pad) begin
            if (io_link_tx_ready) begin
              state <= 3'h4;
            end else begin
              state <= GEN_33;
            end
          end else begin
            state <= GEN_33;
          end
        end
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      latched_ctrl_insn_cmd_proto   <= 2'd0;
      latched_ctrl_insn_cmd_code    <= 8'd0;
      latched_ctrl_insn_cmd_en      <= 1'b0;
      latched_ctrl_insn_addr_proto  <= 2'd0;
      latched_ctrl_insn_addr_len    <= 3'd0;
      latched_ctrl_insn_pad_code    <= 8'd0;
      latched_ctrl_insn_pad_cnt     <= 4'd0;
      latched_ctrl_insn_data_proto  <= 2'd0;
      latched_ctrl_fmt_endian       <= 1'b0;
    end
    else if (~io_link_active) begin
      latched_ctrl_insn_cmd_proto   <= io_ctrl_insn_cmd_proto  ;
      latched_ctrl_insn_cmd_code    <= io_ctrl_insn_cmd_code   ;
      latched_ctrl_insn_cmd_en      <= io_ctrl_insn_cmd_en     ;
      latched_ctrl_insn_addr_proto  <= io_ctrl_insn_addr_proto ;
      latched_ctrl_insn_addr_len    <= io_ctrl_insn_addr_len   ;
      latched_ctrl_insn_pad_code    <= io_ctrl_insn_pad_code   ;
      latched_ctrl_insn_pad_cnt     <= io_ctrl_insn_pad_cnt    ;
      latched_ctrl_insn_data_proto  <= io_ctrl_insn_data_proto ;
      latched_ctrl_fmt_endian       <= io_ctrl_fmt_endian      ;
    end

  assign ctrl_insn_cmd_proto   = io_link_active ? latched_ctrl_insn_cmd_proto  : io_ctrl_insn_cmd_proto  ;
  assign ctrl_insn_cmd_code    = io_link_active ? latched_ctrl_insn_cmd_code   : io_ctrl_insn_cmd_code   ;
  assign ctrl_insn_cmd_en      = io_link_active ? latched_ctrl_insn_cmd_en     : io_ctrl_insn_cmd_en     ;
  assign ctrl_insn_addr_proto  = io_link_active ? latched_ctrl_insn_addr_proto : io_ctrl_insn_addr_proto ;
  assign ctrl_insn_addr_len    = io_link_active ? latched_ctrl_insn_addr_len   : io_ctrl_insn_addr_len   ;
  assign ctrl_insn_pad_code    = io_link_active ? latched_ctrl_insn_pad_code   : io_ctrl_insn_pad_code   ;
  assign ctrl_insn_pad_cnt     = io_link_active ? latched_ctrl_insn_pad_cnt    : io_ctrl_insn_pad_cnt    ;
  assign ctrl_insn_data_proto  = io_link_active ? latched_ctrl_insn_data_proto : io_ctrl_insn_data_proto ;
  assign ctrl_fmt_endian       = io_link_active ? latched_ctrl_fmt_endian      : io_ctrl_fmt_endian      ;

endmodule
