 /*                                                                      
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
 */                                                                      
                                                                         
                                                                         
                                                                         

module sirv_qspi_physical(
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
  input  [1:0] io_ctrl_fmt_proto,
  input   io_ctrl_fmt_endian,
  input   io_ctrl_fmt_iodir,
  output  io_op_ready,
  input   io_op_valid,
  input   io_op_bits_fn,
  input   io_op_bits_stb,
  input  [7:0] io_op_bits_cnt,
  input  [7:0] io_op_bits_data,
  output  io_rx_valid,
  output [7:0] io_rx_bits
);
  reg [11:0] ctrl_sck_div;
  reg [31:0] GEN_2;
  reg  ctrl_sck_pol;
  reg [31:0] GEN_31;
  reg  ctrl_sck_pha;
  reg [31:0] GEN_52;
  reg [1:0] ctrl_fmt_proto;
  reg [31:0] GEN_67;
  reg  ctrl_fmt_endian;
  reg [31:0] GEN_68;
  reg  ctrl_fmt_iodir;
  reg [31:0] GEN_69;
  wire  proto_0;
  wire  proto_1;
  wire  proto_2;
  reg  setup_d;
  reg [31:0] GEN_70;
  reg  T_119;
  reg [31:0] GEN_71;
  reg  T_120;
  reg [31:0] GEN_72;
  reg  sample_d;
  reg [31:0] GEN_73;
  reg  T_122;
  reg [31:0] GEN_74;
  reg  T_123;
  reg [31:0] GEN_75;
  reg  last_d;
  reg [31:0] GEN_76;
  reg [7:0] scnt;
  reg [31:0] GEN_77;
  reg [11:0] tcnt;
  reg [31:0] GEN_78;
  wire  stop;
  wire  beat;
  wire [12:0] T_129;
  wire [11:0] T_130;
  reg  sck;
  reg [31:0] GEN_79;
  reg  cref;
  reg [31:0] GEN_80;
  wire  cinv;
  reg [7:0] buffer;
  reg [31:0] GEN_81;
  wire  T_135;
  wire [7:0] T_150;
  wire [7:0] buffer_in;
  wire [7:0] T_179;
  reg [3:0] txd;
  reg [31:0] GEN_82;
  wire [3:0] T_193;
  wire [3:0] GEN_0;
  wire  T_196;
  wire  txen_1;
  reg  done;
  reg [31:0] GEN_83;
  wire  T_212;
  reg  xfr;
  reg [31:0] GEN_84;
  wire  GEN_1;
  wire  T_234;
  wire  T_236;
  wire  T_237;
  wire  GEN_12;
  wire  GEN_13;
  wire  T_243;
  wire  T_248;
  wire  GEN_21;
  wire  T_251;
  wire  T_256;
  wire  T_259;
  wire [1:0] GEN_54;
  wire  GEN_55;
  wire  GEN_56;
  wire  GEN_57;
  wire [7:0] GEN_58;
  wire  GEN_59;
  wire  GEN_60;
  wire  GEN_61;
  wire [11:0] GEN_62;
  wire  GEN_63;
  wire  GEN_64;
  assign io_port_sck = sck;
  assign io_port_dq_0_o = txd[0];
  assign io_port_dq_0_oe = (proto_0 | txen_1);
  assign io_port_dq_1_o = txd[1];
  assign io_port_dq_1_oe = txen_1;
  assign io_port_dq_2_o = txd[2];
  assign io_port_dq_2_oe = T_196;
  assign io_port_dq_3_o = txd[3];
  assign io_port_dq_3_oe = io_port_dq_2_oe; 
  assign io_port_cs_0 = 1'h1;
  assign io_op_ready = T_251;
  assign io_rx_valid = done;
  assign io_rx_bits = ((ctrl_fmt_endian == 1'h0) ? buffer : ({({({buffer[0],buffer[1]}),({buffer[2],buffer[3]})}),({({buffer[4],buffer[5]}),({buffer[6],buffer[7]})})}));
  assign proto_0 = 2'h0 == ctrl_fmt_proto;
  assign proto_1 = 2'h1 == ctrl_fmt_proto;
  assign proto_2 = 2'h2 == ctrl_fmt_proto;
  assign stop = scnt == 8'h0;
  assign beat = tcnt == 12'h0;
  assign T_129 = (beat ? {{4'd0}, scnt} : tcnt) - 12'h1;
  assign T_130 = GEN_1 ? ctrl_sck_div : T_129[11:0];
  assign cinv = ctrl_sck_pha ^ ctrl_sck_pol;
  assign T_135 = io_ctrl_fmt_endian == 1'h0;
  assign T_150 = {({({io_op_bits_data[0],io_op_bits_data[1]}),({io_op_bits_data[2],io_op_bits_data[3]})}),({({io_op_bits_data[4],io_op_bits_data[5]}),({io_op_bits_data[6],io_op_bits_data[7]})})};
  assign buffer_in = T_135 ? io_op_bits_data : T_150;
  assign T_179 = (
      (proto_0 ? ({((setup_d | (sample_d & stop)) ? buffer[6:0] : buffer[7:1]),(sample_d ? io_port_dq_1_i : buffer[0])}) : 8'h0) | 
      (proto_1 ? ({((setup_d | (sample_d & stop)) ? buffer[5:0] : buffer[7:2]),(sample_d ? {io_port_dq_1_i,io_port_dq_0_i} : buffer[1:0])}) : 8'h0)
  ) | 
      (proto_2 ? ({((setup_d | (sample_d & stop)) ? buffer[3:0] : buffer[7:4]),(sample_d ? ({({io_port_dq_3_i,io_port_dq_2_i}),({io_port_dq_1_i,io_port_dq_0_i})}) : buffer[3:0])}) : 8'h0);
  assign T_193 = ({{2'd0}, (({{1'd0}, ((2'h0 == (GEN_21 ? io_ctrl_fmt_proto : ctrl_fmt_proto)) ? (GEN_21 ? buffer_in[7] : buffer[7]) : 1'h0)}) | ((2'h1 == (GEN_21 ? io_ctrl_fmt_proto : ctrl_fmt_proto)) ? (GEN_21 ? buffer_in[7:5] : buffer[7:5]) : 2'h0))}) | ((2'h2 == (GEN_21 ? io_ctrl_fmt_proto : ctrl_fmt_proto)) ? (GEN_21 ? buffer_in[7:4] : buffer[7:4]) : 4'h0);
  assign GEN_0 = GEN_60 ? T_193 : txd;
  assign T_196 = proto_2 & ctrl_fmt_iodir;
  assign txen_1 = (proto_1 & ctrl_fmt_iodir) | T_196;
  assign T_212 = done | last_d;
  assign GEN_1 = stop ? 1'h1 : beat;
  assign T_234 = stop == 1'h0;
  assign T_236 = cref == 1'h0;
  assign T_237 = cref ^ cinv;
  assign GEN_12 = T_234 ? (beat ? T_236 : cref) : cref;
  assign GEN_13 = T_234 ? (beat ? (xfr ? T_237 : sck) : sck) : sck;
  assign T_243 = scnt == 8'h1;
  assign T_248 = beat & T_236;
  assign GEN_21 = T_243 ? (T_248 ? 1'h1 : stop) : stop;
  assign T_251 = GEN_21 & done;
  assign T_256 = 1'h0 == io_op_bits_fn;
  assign T_259 = io_op_bits_cnt == 8'h0;
  assign GEN_54 = T_251 ? (io_op_valid ? (io_op_bits_stb ? io_ctrl_fmt_proto : ctrl_fmt_proto) : ctrl_fmt_proto) : ctrl_fmt_proto;
  assign GEN_55 = T_251 ? (io_op_valid ? (io_op_bits_stb ? io_ctrl_fmt_endian : ctrl_fmt_endian) : ctrl_fmt_endian) : ctrl_fmt_endian;
  assign GEN_56 = T_251 ? (io_op_valid ? (io_op_bits_stb ? io_ctrl_fmt_iodir : ctrl_fmt_iodir) : ctrl_fmt_iodir) : ctrl_fmt_iodir;
  assign GEN_57 = T_251 ? (io_op_valid ? T_256 : xfr) : xfr;
  assign GEN_58 = T_251 ? (io_op_valid ? (T_256 ? buffer_in : T_179) : T_179) : T_179;
  assign GEN_59 = T_251 ? (io_op_valid ? (io_op_bits_fn ? (io_op_bits_stb ? io_ctrl_sck_pol : (T_256 ? cinv : (T_243 ? (T_248 ? ctrl_sck_pol : GEN_13) : GEN_13))) : (T_256 ? cinv : (T_243 ? (T_248 ? ctrl_sck_pol : GEN_13) : GEN_13))) : (T_243 ? (T_248 ? ctrl_sck_pol : GEN_13) : GEN_13)) : (T_243 ? (T_248 ? ctrl_sck_pol : GEN_13) : GEN_13);
  assign GEN_60 = T_251 ? (io_op_valid ? (T_256 ? 1'h1 : (T_243 ? (T_248 ? 1'h0 : (T_234 ? (beat ? (xfr ? T_236 : 1'h0) : 1'h0) : 1'h0)) : (T_234 ? (beat ? (xfr ? T_236 : 1'h0) : 1'h0) : 1'h0))) : (T_243 ? (T_248 ? 1'h0 : (T_234 ? (beat ? (xfr ? T_236 : 1'h0) : 1'h0) : 1'h0)) : (T_234 ? (beat ? (xfr ? T_236 : 1'h0) : 1'h0) : 1'h0))) : (T_243 ? (T_248 ? 1'h0 : (T_234 ? (beat ? (xfr ? T_236 : 1'h0) : 1'h0) : 1'h0)) : (T_234 ? (beat ? (xfr ? T_236 : 1'h0) : 1'h0) : 1'h0));
  assign GEN_61 = T_251 ? (io_op_valid ? (T_256 ? T_259 : T_212) : T_212) : T_212;
  assign GEN_62 = T_251 ? (io_op_valid ? (io_op_bits_fn ? (io_op_bits_stb ? io_ctrl_sck_div : ctrl_sck_div) : ctrl_sck_div) : ctrl_sck_div) : ctrl_sck_div;
  assign GEN_63 = T_251 ? (io_op_valid ? (io_op_bits_fn ? (io_op_bits_stb ? io_ctrl_sck_pol : ctrl_sck_pol) : ctrl_sck_pol) : ctrl_sck_pol) : ctrl_sck_pol;
  assign GEN_64 = T_251 ? (io_op_valid ? (io_op_bits_fn ? (io_op_bits_stb ? io_ctrl_sck_pha : ctrl_sck_pha) : ctrl_sck_pha) : ctrl_sck_pha) : ctrl_sck_pha;

  always @(posedge clock or posedge reset)
  if (reset) begin
    ctrl_sck_div <= 12'b0;
    ctrl_sck_pol <= 1'b0;
    ctrl_sck_pha <= 1'b0;
    ctrl_fmt_proto <= 2'b0;
    ctrl_fmt_endian <= 1'b0;
    ctrl_fmt_iodir <= 1'b0;
    setup_d <= 1'b0;
    tcnt <= 12'b0;
    sck <= 1'b0;
    buffer <= 8'b0;
    xfr <= 1'b0;
  end
  else begin
    if (T_251) begin
      if (io_op_valid) begin
        if (io_op_bits_fn) begin
          if (io_op_bits_stb) begin
            ctrl_sck_div <= io_ctrl_sck_div;
          end
        end
      end
    end
    if (T_251) begin
      if (io_op_valid) begin
        if (io_op_bits_fn) begin
          if (io_op_bits_stb) begin
            ctrl_sck_pol <= io_ctrl_sck_pol;
          end
        end
      end
    end
    if (T_251) begin
      if (io_op_valid) begin
        if (io_op_bits_fn) begin
          if (io_op_bits_stb) begin
            ctrl_sck_pha <= io_ctrl_sck_pha;
          end
        end
      end
    end
    if (T_251) begin
      if (io_op_valid) begin
        if (io_op_bits_stb) begin
          ctrl_fmt_proto <= io_ctrl_fmt_proto;
        end
      end
    end
    if (T_251) begin
      if (io_op_valid) begin
        if (io_op_bits_stb) begin
          ctrl_fmt_endian <= io_ctrl_fmt_endian;
        end
      end
    end
    if (T_251) begin
      if (io_op_valid) begin
        if (io_op_bits_stb) begin
          ctrl_fmt_iodir <= io_ctrl_fmt_iodir;
        end
      end
    end
    setup_d <= GEN_60;




    if (GEN_1) begin
      tcnt <= ctrl_sck_div;
    end else begin
      tcnt <= T_129[11:0];
    end
    if (T_251) begin
      if (io_op_valid) begin
        if (io_op_bits_fn) begin
          if (io_op_bits_stb) begin
            sck <= io_ctrl_sck_pol;
          end else begin
            if (T_256) begin
              sck <= cinv;
            end else begin
              if (T_243) begin
                if (T_248) begin
                  sck <= ctrl_sck_pol;
                end else begin
                  if (T_234) begin
                    if (beat) begin
                      if (xfr) begin
                        sck <= T_237;
                      end
                    end
                  end
                end
              end else begin
                if (T_234) begin
                  if (beat) begin
                    if (xfr) begin
                      sck <= T_237;
                    end
                  end
                end
              end
            end
          end
        end else begin
          if (T_256) begin
            sck <= cinv;
          end else begin
            if (T_243) begin
              if (T_248) begin
                sck <= ctrl_sck_pol;
              end else begin
                if (T_234) begin
                  if (beat) begin
                    if (xfr) begin
                      sck <= T_237;
                    end
                  end
                end
              end
            end else begin
              if (T_234) begin
                if (beat) begin
                  if (xfr) begin
                    sck <= T_237;
                  end
                end
              end
            end
          end
        end
      end else begin
        if (T_243) begin
          if (T_248) begin
            sck <= ctrl_sck_pol;
          end else begin
            sck <= GEN_13;
          end
        end else begin
          sck <= GEN_13;
        end
      end
    end else begin
      if (T_243) begin
        if (T_248) begin
          sck <= ctrl_sck_pol;
        end else begin
          sck <= GEN_13;
        end
      end else begin
        sck <= GEN_13;
      end
    end



    if (T_251) begin
      if (io_op_valid) begin
        if (T_256) begin
          if (T_135) begin
            buffer <= io_op_bits_data;
          end else begin
            buffer <= T_150;
          end
        end else begin
          buffer <= T_179;
        end
      end else begin
        buffer <= T_179;
      end
    end else begin
      buffer <= T_179;
    end

    if (T_251) begin
      if (io_op_valid) begin
        xfr <= T_256;
      end
    end

  end


  always @(posedge clock or posedge reset)
    if (reset) begin
      cref <= 1'h1;
    end else begin
      if (T_234) begin
        if (beat) begin
          cref <= T_236;
        end
      end
    end


  always @(posedge clock or posedge reset)
    if (reset) begin
      txd <= 4'h0;
    end else begin
      if (GEN_60) begin
        txd <= T_193;
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      done <= 1'h1;
    end else begin
      if (T_251) begin
        if (io_op_valid) begin
          if (T_256) begin
            done <= T_259;
          end else begin
            done <= T_212;
          end
        end else begin
          done <= T_212;
        end
      end else begin
        done <= T_212;
      end
    end



  always @(posedge clock or posedge reset)
    if (reset) begin
      T_119 <= 1'h0;
    end else begin
      T_119 <= (T_234 ? (beat ? (xfr ? cref : 1'h0) : 1'h0) : 1'h0);
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      T_120 <= 1'h0;
    end else begin
      T_120 <= T_119;
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      sample_d <= 1'h0;
    end else begin
      sample_d <= T_120;
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      T_122 <= 1'h0;
    end else begin
      T_122 <= (T_243 ? ((beat & cref) & xfr) : 1'h0);
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      T_123 <= 1'h0;
    end else begin
      T_123 <= T_122;
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      last_d <= 1'h0;
    end else begin
      last_d <= T_123;
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      scnt <= 8'h0;
    end else begin
      scnt <= (T_251 ? (io_op_valid ? {{4'd0}, io_op_bits_cnt} : (T_234 ? (beat ? (T_236 ? T_129[11:0] : {{4'd0}, scnt}) : {{4'd0}, scnt}) : {{4'd0}, scnt})) : (T_234 ? (beat ? (T_236 ? T_129[11:0] : {{4'd0}, scnt}) : {{4'd0}, scnt}) : {{4'd0}, scnt}));
    end

endmodule
