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
  output  io_port_cs_0,  // unused
  input  [11:0] io_ctrl_sck_div,
  input   io_ctrl_sck_pol,
  input   io_ctrl_sck_pha,
  input  [1:0] io_ctrl_fmt_proto,
  input   io_ctrl_fmt_endian,
  input   io_ctrl_fmt_iodir,
  output  io_op_ready,
  input   io_op_valid,
  // Type of SPI micro opration (0=xfer, 1=delay). An SPI operation consists of
  // micro operations, such as an N-bit data transfer, or a delay (e.g. between
  // CS assertion and 1st SCK change, between two data transfers, after a data
  // transfer and CS de-assertion, etc.).
  input   io_op_bits_fn,
  input   io_op_bits_stb,
  input  [7:0] io_op_bits_cnt,
  input  [7:0] io_op_bits_data,
  output  io_rx_valid,
  output [7:0] io_rx_bits
);
  reg [11:0] ctrl_sck_div;
  reg  ctrl_sck_pol;
  reg  ctrl_sck_pha;
  reg [1:0] ctrl_fmt_proto;
  reg  ctrl_fmt_endian;
  reg  ctrl_fmt_iodir;
//  wire  proto_s;
//  wire  proto_d;
//  wire  proto_q;
  reg  proto_s;
  reg  proto_d;
  reg  proto_q;
  reg  setup_d;
  reg  T_119;
  reg  T_120;
  reg  sample_d;
  reg  T_122;
  reg  T_123;
  reg  last_d;
  // A multi-purpose counter in units of one SCK period (a.k.a. tick). This counter
  // is loaded from the upper "media" access module, which is responsible for frame
  // formatting. Henc, as the transmission proceeds, `scnt` gets loaded with intercs,
  // interxfr, sckcs and cssck (fields of the delay0 and delay1 registers), and counts
  // down those values.
  reg [7:0] scnt;
  // A SCK counter (a.k.a. tick counter). Counts down the number of `clock` cycles that
  // yield one SCK cycle (a.k.a. tick).
  reg [11:0] tcnt;
  // Indicates final count-down of the multi-purpose counter.
  wire  stop;
  // Indicates final count-down of the tick counter.
  wire  beat;
//  wire [11:0] decr;
  reg  sck;
  // Internal SCK, rise edge active.
  reg  cref;
  // defines the polarity of the output SCK
  wire  cinv;
  reg [7:0] buffer;
  wire [7:0] buffer_in;
  wire [7:0] T_179;
  reg [3:0] txd;
  wire [3:0] T_193;
//  wire [3:0] GEN_0;
  reg  done;
//  wire  T_212;
  reg  xfr;
//  wire  _234;
//  wire  _236;
//  wire  T_237;
//  wire  GEN_12;
//  wire  GEN_13;
  wire  scnt_eq_one;
  wire  cref_rise;
  wire  GEN_21;
  wire  T_251;
//  wire  T_259;
//  wire [1:0] GEN_54;
//  wire  GEN_55;
//  wire  GEN_56;
//  wire  GEN_57;
//  wire [7:0] GEN_58;
//  wire  GEN_59;
  wire  GEN_60;
//  wire  GEN_61;
//  wire [11:0] GEN_62;
//  wire  GEN_63;
//  wire  GEN_64;
  wire [7:0] io_op_bits_data_rev;
  assign io_port_sck = sck;
  assign io_port_dq_0_o = txd[0];
  assign io_port_dq_0_oe = ctrl_fmt_iodir & (proto_q | proto_d | proto_s);
  assign io_port_dq_1_o = txd[1];
  assign io_port_dq_1_oe = ctrl_fmt_iodir & (proto_q | proto_d);
  assign io_port_dq_2_o = txd[2];
  assign io_port_dq_2_oe = ctrl_fmt_iodir & (proto_q);
  assign io_port_dq_3_o = txd[3];
  assign io_port_dq_3_oe = io_port_dq_2_oe; 
  assign io_port_cs_0 = 1'h1;
  assign io_op_ready = T_251;
  assign io_rx_valid = done;
  assign io_rx_bits = ctrl_fmt_endian ? {buffer[0],buffer[1],buffer[2],buffer[3],buffer[4],buffer[5],buffer[6],buffer[7]} : buffer;
//  assign proto_s = 2'h0 == ctrl_fmt_proto;
//  assign proto_d = 2'h1 == ctrl_fmt_proto;
//  assign proto_q = 2'h2 == ctrl_fmt_proto;
  assign stop = scnt == 8'h0;
  assign beat = tcnt == 12'h0;
//  assign decr = (beat ? {{4'd0}, scnt} : tcnt) - 12'h1;
  assign cinv = ctrl_sck_pha ^ ctrl_sck_pol;
  assign io_op_bits_data_rev  = {io_op_bits_data[0],io_op_bits_data[1],io_op_bits_data[2],io_op_bits_data[3],io_op_bits_data[4],io_op_bits_data[5],io_op_bits_data[6],io_op_bits_data[7]};
  assign buffer_in = ~io_ctrl_fmt_endian ? io_op_bits_data : io_op_bits_data_rev;
  assign T_179 = 
      ({8{proto_s}} & {((setup_d | (sample_d & stop)) ? buffer[6:0] : buffer[7:1]),(sample_d ? io_port_dq_1_i : buffer[0])}) |
      ({8{proto_d}} & {((setup_d | (sample_d & stop)) ? buffer[5:0] : buffer[7:2]),(sample_d ? {io_port_dq_1_i,io_port_dq_0_i} : buffer[1:0])}) | 
      ({8{proto_q}} & {((setup_d | (sample_d & stop)) ? buffer[3:0] : buffer[7:4]),(sample_d ? ({({io_port_dq_3_i,io_port_dq_2_i}),({io_port_dq_1_i,io_port_dq_0_i})}) : buffer[3:0])});
  assign T_193 = 
      {3'd0, ((GEN_21 ? 2'h0 == io_ctrl_fmt_proto : proto_s) ? (GEN_21 ? buffer_in[7]   : buffer[7]  ) : 1'h0)} |
      {2'd0, ((GEN_21 ? 2'h1 == io_ctrl_fmt_proto : proto_d) ? (GEN_21 ? buffer_in[7:5] : buffer[7:5]) : 2'h0)} |
             ((GEN_21 ? 2'h2 == io_ctrl_fmt_proto : proto_q) ? (GEN_21 ? buffer_in[7:4] : buffer[7:4]) : 4'h0);
//  assign GEN_0 = GEN_60 ? T_193 : txd;
//  assign T_212 = done | last_d;
//  assign _234 = stop == 1'h0;
//  assign _236 = cref == 1'h0;
//  assign T_237 = cref ^ cinv;
//  assign GEN_12 = (~stop & beat) ^ cref;
//  assign GEN_13 = ~stop ? (beat ? (xfr ? T_237 : sck) : sck) : sck;
  assign scnt_eq_one = scnt == 8'h1;
  assign cref_rise = beat & ~cref;
  assign GEN_21 = (scnt_eq_one & cref_rise) | stop;
  assign T_251 = GEN_21 & done;
//  assign T_259 = io_op_bits_cnt == 8'h0;
//  assign GEN_54 = T_251 ? (io_op_valid ? (io_op_bits_stb ? io_ctrl_fmt_proto : ctrl_fmt_proto) : ctrl_fmt_proto) : ctrl_fmt_proto;
//  assign GEN_55 = T_251 ? (io_op_valid ? (io_op_bits_stb ? io_ctrl_fmt_endian : ctrl_fmt_endian) : ctrl_fmt_endian) : ctrl_fmt_endian;
//  assign GEN_56 = T_251 ? (io_op_valid ? (io_op_bits_stb ? io_ctrl_fmt_iodir : ctrl_fmt_iodir) : ctrl_fmt_iodir) : ctrl_fmt_iodir;
//  assign GEN_57 = T_251 ? (io_op_valid ? ~io_op_bits_fn : xfr) : xfr;
//  assign GEN_58 = T_251 ? (io_op_valid ? (~io_op_bits_fn ? buffer_in : T_179) : T_179) : T_179;
//  assign GEN_59 = T_251 ? (io_op_valid ? (io_op_bits_fn ? (io_op_bits_stb ? io_ctrl_sck_pol : (~io_op_bits_fn ? cinv : (scnt_eq_one ? (cref_rise ? ctrl_sck_pol : GEN_13) : GEN_13))) : (~io_op_bits_fn ? cinv : (scnt_eq_one ? (cref_rise ? ctrl_sck_pol : GEN_13) : GEN_13))) : (scnt_eq_one ? (cref_rise ? ctrl_sck_pol : GEN_13) : GEN_13)) : (scnt_eq_one ? (cref_rise ? ctrl_sck_pol : GEN_13) : GEN_13);
  assign GEN_60 = 
          (T_251 & io_op_valid & ~io_op_bits_fn) |
          ((~scnt_eq_one | ~cref_rise) & (~stop & beat & xfr & ~cref));
//  assign GEN_61 = T_251 ? (io_op_valid ? (~io_op_bits_fn ? T_259 : T_212) : T_212) : T_212;
//  assign GEN_62 = T_251 ? (io_op_valid ? (io_op_bits_fn ? (io_op_bits_stb ? io_ctrl_sck_div : ctrl_sck_div) : ctrl_sck_div) : ctrl_sck_div) : ctrl_sck_div;
//  assign GEN_63 = T_251 ? (io_op_valid ? (io_op_bits_fn ? (io_op_bits_stb ? io_ctrl_sck_pol : ctrl_sck_pol) : ctrl_sck_pol) : ctrl_sck_pol) : ctrl_sck_pol;
//  assign GEN_64 = T_251 ? (io_op_valid ? (io_op_bits_fn ? (io_op_bits_stb ? io_ctrl_sck_pha : ctrl_sck_pha) : ctrl_sck_pha) : ctrl_sck_pha) : ctrl_sck_pha;

  always @(posedge clock or posedge reset)
  if (reset) begin
    ctrl_sck_div <= 12'b0;
    ctrl_sck_pol <= 1'b0;
    ctrl_sck_pha <= 1'b0;
    ctrl_fmt_proto <= 2'b0;
    proto_s <= 1'h1; 
    proto_d <= 1'h0;
    proto_q <= 1'h0;
    ctrl_fmt_endian <= 1'b0;
    ctrl_fmt_iodir <= 1'b0;
    setup_d <= 1'b0;
    tcnt <= 12'b0;
    sck <= 1'b0;
    buffer <= 8'b0;
    xfr <= 1'b0;
  end
  else begin
    if (T_251 & io_op_valid & io_op_bits_stb) begin
          ctrl_fmt_proto <= io_ctrl_fmt_proto;
          ctrl_fmt_endian <= io_ctrl_fmt_endian;
          ctrl_fmt_iodir <= io_ctrl_fmt_iodir;
          proto_s <= 2'h0 == io_ctrl_fmt_proto;
          proto_d <= 2'h1 == io_ctrl_fmt_proto;
          proto_q <= 2'h2 == io_ctrl_fmt_proto;

          if (io_op_bits_fn) begin
            ctrl_sck_div <= io_ctrl_sck_div;
            ctrl_sck_pol <= io_ctrl_sck_pol;
            ctrl_sck_pha <= io_ctrl_sck_pha;
          end
    end
//    if (T_251) begin
//      if (io_op_valid) begin
//        if (io_op_bits_fn) begin
//          if (io_op_bits_stb) begin
//            ctrl_sck_div <= io_ctrl_sck_div;
//          end
//        end
//      end
//    end
//    if (T_251) begin
//      if (io_op_valid) begin
//        if (io_op_bits_fn) begin
//          if (io_op_bits_stb) begin
//            ctrl_sck_pol <= io_ctrl_sck_pol;
//          end
//        end
//      end
//    end
//    if (T_251) begin
//      if (io_op_valid) begin
//        if (io_op_bits_fn) begin
//          if (io_op_bits_stb) begin
//            ctrl_sck_pha <= io_ctrl_sck_pha;
//          end
//        end
//      end
//    end
//    if (T_251) begin
//      if (io_op_valid) begin
//        if (io_op_bits_stb) begin
//          ctrl_fmt_proto <= io_ctrl_fmt_proto;
//        end
//      end
//    end
//    if (T_251) begin
//      if (io_op_valid) begin
//        if (io_op_bits_stb) begin
//          ctrl_fmt_endian <= io_ctrl_fmt_endian;
//        end
//      end
//    end
//    if (T_251) begin
//      if (io_op_valid) begin
//        if (io_op_bits_stb) begin
//          ctrl_fmt_iodir <= io_ctrl_fmt_iodir;
//        end
//      end
//    end
    setup_d <= GEN_60;

    tcnt <= (stop | beat) ? ctrl_sck_div : tcnt - 1'b1;

    if (T_251 & io_op_valid & io_op_bits_fn & io_op_bits_stb) begin
        sck <= io_ctrl_sck_pol;
    end else if (T_251 & io_op_valid & ~io_op_bits_fn) begin
        sck <= cinv;
    end else if (beat) begin
      if (scnt_eq_one & ~cref) begin
        sck <= ctrl_sck_pol;
      end else if (~stop & xfr) begin
        sck <=  cref ^ cinv;
      end
    end

    if (T_251 & io_op_valid & ~io_op_bits_fn) begin
      buffer <= buffer_in;
    end else begin
      buffer <= T_179;
    end
//    if (T_251) begin
//      if (io_op_valid) begin
//        if (~io_op_bits_fn) begin
//          buffer <= ~io_ctrl_fmt_endian ? io_op_bits_data : io_op_bits_data_rev;
//        end else begin
//          buffer <= T_179;
//        end
//      end else begin
//        buffer <= T_179;
//      end
//    end else begin
//      buffer <= T_179;
//    end

    if (T_251 & io_op_valid) begin
      xfr <= ~io_op_bits_fn;
    end

  end


  always @(posedge clock or posedge reset)
    if (reset) begin
      cref <= 1'h1;
    end else if (~stop & beat) begin
      cref <= ~cref;
    end


  always @(posedge clock or posedge reset)
    if (reset) begin
      txd <= 4'h0;
    end else if (GEN_60) begin
      txd <= T_193;
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      done <= 1'h1;
    end else begin
      if (T_251 & io_op_valid & ~io_op_bits_fn) begin
        done <= io_op_bits_cnt == 8'h0;
      end else if (last_d) begin
        done <= 1'h1;
      end
    end



//  always @(posedge clock or posedge reset)
//    if (reset) begin
//      T_119 <= 1'h0;
//    end else begin
//      T_119 <= (~stop & beat & xfr & cref);
//    end
//
//  always @(posedge clock or posedge reset)
//    if (reset) begin
//      T_120 <= 1'h0;
//    end else begin
//      T_120 <= T_119;
//    end
//
//  always @(posedge clock or posedge reset)
//    if (reset) begin
//      sample_d <= 1'h0;
//    end else begin
//      sample_d <= T_120;
//    end
  always @(posedge clock or posedge reset)
    if (reset) begin
      T_119 <= 1'h0;
      T_120 <= 1'h0;
      sample_d <= 1'h0;
    end else begin
      T_119 <= (~stop & beat & xfr & cref);
      T_120 <= T_119;
      sample_d <= T_120;
    end

//  always @(posedge clock or posedge reset)
//    if (reset) begin
//      T_122 <= 1'h0;
//    end else begin
//      T_122 <= (scnt_eq_one & beat & xfr & cref);
//    end
//
//  always @(posedge clock or posedge reset)
//    if (reset) begin
//      T_123 <= 1'h0;
//    end else begin
//      T_123 <= T_122;
//    end
//
//  always @(posedge clock or posedge reset)
//    if (reset) begin
//      last_d <= 1'h0;
//    end else begin
//      last_d <= T_123;
//    end
  always @(posedge clock or posedge reset)
    if (reset) begin
      T_122 <= 1'h0;
      T_123 <= 1'h0;
      last_d <= 1'h0;
    end else begin
      T_122 <= (scnt_eq_one & beat & xfr & cref);
      T_123 <= T_122;
      last_d <= T_123;
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      scnt <= 8'h0;
    end else begin
        if (T_251 &  io_op_valid)
            scnt <= io_op_bits_cnt;
        else if (~stop & beat & ~cref)
            scnt <=  scnt - 1'b1;
    end

endmodule
