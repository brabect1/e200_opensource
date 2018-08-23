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
                                                                         
                                                                         
                                                                         

module sirv_tlwidthwidget_qspi(
  input   clock,
  input   reset,
  output  io_in_0_a_ready,
  input   io_in_0_a_valid,
  input  [2:0] io_in_0_a_bits_opcode,
  input  [2:0] io_in_0_a_bits_param,
  input  [2:0] io_in_0_a_bits_size,
  input  [1:0] io_in_0_a_bits_source,
  input  [29:0] io_in_0_a_bits_address,
  input  [3:0] io_in_0_a_bits_mask,
  input  [31:0] io_in_0_a_bits_data,
  input   io_in_0_b_ready,
  output  io_in_0_b_valid,
  output [2:0] io_in_0_b_bits_opcode,
  output [1:0] io_in_0_b_bits_param,
  output [2:0] io_in_0_b_bits_size,
  output [1:0] io_in_0_b_bits_source,
  output [29:0] io_in_0_b_bits_address,
  output [3:0] io_in_0_b_bits_mask,
  output [31:0] io_in_0_b_bits_data,
  output  io_in_0_c_ready,
  input   io_in_0_c_valid,
  input  [2:0] io_in_0_c_bits_opcode,
  input  [2:0] io_in_0_c_bits_param,
  input  [2:0] io_in_0_c_bits_size,
  input  [1:0] io_in_0_c_bits_source,
  input  [29:0] io_in_0_c_bits_address,
  input  [31:0] io_in_0_c_bits_data,
  input   io_in_0_c_bits_error,
  input   io_in_0_d_ready,
  output  io_in_0_d_valid,
  output [2:0] io_in_0_d_bits_opcode,
  output [1:0] io_in_0_d_bits_param,
  output [2:0] io_in_0_d_bits_size,
  output [1:0] io_in_0_d_bits_source,
  output  io_in_0_d_bits_sink,
  output [1:0] io_in_0_d_bits_addr_lo,
  output [31:0] io_in_0_d_bits_data,
  output  io_in_0_d_bits_error,
  output  io_in_0_e_ready,
  input   io_in_0_e_valid,
  input   io_in_0_e_bits_sink,
  input   io_out_0_a_ready,
  output  io_out_0_a_valid,
  output [2:0] io_out_0_a_bits_opcode,
  output [2:0] io_out_0_a_bits_param,
  output [2:0] io_out_0_a_bits_size,
  output [1:0] io_out_0_a_bits_source,
  output [29:0] io_out_0_a_bits_address,
  output  io_out_0_a_bits_mask,
  output [7:0] io_out_0_a_bits_data,
  output  io_out_0_b_ready,
  input   io_out_0_b_valid,
  input  [2:0] io_out_0_b_bits_opcode,
  input  [1:0] io_out_0_b_bits_param,
  input  [2:0] io_out_0_b_bits_size,
  input  [1:0] io_out_0_b_bits_source,
  input  [29:0] io_out_0_b_bits_address,
  input   io_out_0_b_bits_mask,
  input  [7:0] io_out_0_b_bits_data,
  input   io_out_0_c_ready,
  output  io_out_0_c_valid,
  output [2:0] io_out_0_c_bits_opcode,
  output [2:0] io_out_0_c_bits_param,
  output [2:0] io_out_0_c_bits_size,
  output [1:0] io_out_0_c_bits_source,
  output [29:0] io_out_0_c_bits_address,
  output [7:0] io_out_0_c_bits_data,
  output  io_out_0_c_bits_error,
  output  io_out_0_d_ready,
  input   io_out_0_d_valid,
  input  [2:0] io_out_0_d_bits_opcode,
  input  [1:0] io_out_0_d_bits_param,
  input  [2:0] io_out_0_d_bits_size,
  input  [1:0] io_out_0_d_bits_source,
  input   io_out_0_d_bits_sink,
  input   io_out_0_d_bits_addr_lo,
  input  [7:0] io_out_0_d_bits_data,
  input   io_out_0_d_bits_error,
  input   io_out_0_e_ready,
  output  io_out_0_e_valid,
  output  io_out_0_e_bits_sink
);
  wire  Repeater_5_1_io_full;
  wire  Repeater_5_1_io_enq_ready;
  wire  Repeater_5_1_io_deq_valid;
  wire [2:0] Repeater_5_1_io_deq_bits_opcode;
  wire [2:0] Repeater_5_1_io_deq_bits_param;
  wire [2:0] Repeater_5_1_io_deq_bits_size;
  wire [1:0] Repeater_5_1_io_deq_bits_source;
  wire [29:0] Repeater_5_1_io_deq_bits_address;
  wire [3:0] Repeater_5_1_io_deq_bits_mask;
  wire [31:0] Repeater_5_1_io_deq_bits_data;
  reg [3:0] T_1447;
  reg [23:0] T_1512;
  reg [2:0] T_1514;
  wire [31:0] T_1515;
  reg [1:0] T_1527;
  wire [1:0] T_1534;
  wire [1:0] T_1535;
  wire  T_1536;
  wire  T_1540;
  wire [3:0]  T_1541;
  wire [15:0] T_1548;
  sirv_tl_repeater_5 Repeater_5_1 (
    .clock(clock),
    .reset(reset),
    .io_repeat(1'h0),
    .io_full(Repeater_5_1_io_full),
    .io_enq_ready(Repeater_5_1_io_enq_ready),
    .io_enq_valid(io_in_0_a_valid),
    .io_enq_bits_opcode(io_in_0_a_bits_opcode),
    .io_enq_bits_param(io_in_0_a_bits_param),
    .io_enq_bits_size(io_in_0_a_bits_size),
    .io_enq_bits_source(io_in_0_a_bits_source),
    .io_enq_bits_address(io_in_0_a_bits_address),
    .io_enq_bits_mask(io_in_0_a_bits_mask),
    .io_enq_bits_data(io_in_0_a_bits_data),
    .io_deq_ready(io_out_0_a_ready),
    .io_deq_valid(Repeater_5_1_io_deq_valid),
    .io_deq_bits_opcode(Repeater_5_1_io_deq_bits_opcode),
    .io_deq_bits_param(Repeater_5_1_io_deq_bits_param),
    .io_deq_bits_size(Repeater_5_1_io_deq_bits_size),
    .io_deq_bits_source(Repeater_5_1_io_deq_bits_source),
    .io_deq_bits_address(Repeater_5_1_io_deq_bits_address),
    .io_deq_bits_mask(Repeater_5_1_io_deq_bits_mask),
    .io_deq_bits_data(Repeater_5_1_io_deq_bits_data)
  );
  assign io_in_0_a_ready = Repeater_5_1_io_enq_ready;
  assign io_in_0_b_valid = 1'h0;
  assign io_in_0_b_bits_opcode = 3'b0;
  assign io_in_0_b_bits_param = 2'b0;
  assign io_in_0_b_bits_size = 3'b0;
  assign io_in_0_b_bits_source = 2'b0;
  assign io_in_0_b_bits_address = 30'b0;
  assign io_in_0_b_bits_mask = 4'b0;
  assign io_in_0_b_bits_data = 32'b0;
  assign io_in_0_c_ready = 1'h1;
  assign io_in_0_d_valid = (io_out_0_d_valid & T_1536);
  assign io_in_0_d_bits_opcode = io_out_0_d_bits_opcode;
  assign io_in_0_d_bits_param = io_out_0_d_bits_param;
  assign io_in_0_d_bits_size = io_out_0_d_bits_size;
  assign io_in_0_d_bits_source = io_out_0_d_bits_source;
  assign io_in_0_d_bits_sink = io_out_0_d_bits_sink;
  assign io_in_0_d_bits_addr_lo = {{1'd0}, io_out_0_d_bits_addr_lo};
  assign io_in_0_d_bits_data = (3'h5 == io_out_0_d_bits_size ? T_1515 : (3'h4 == io_out_0_d_bits_size ? T_1515 : (3'h3 == io_out_0_d_bits_size ? T_1515 : (3'h2 == io_out_0_d_bits_size ? T_1515 : (3'h1 == io_out_0_d_bits_size ? ({T_1515[31:16],T_1515[31:16]}) : ({({T_1515[31:24],T_1515[31:24]}),T_1548}))))));
  assign io_in_0_d_bits_error = io_out_0_d_bits_error;
  assign io_in_0_e_ready = 1'h1;
  assign io_out_0_a_valid = Repeater_5_1_io_deq_valid;
  assign io_out_0_a_bits_opcode = Repeater_5_1_io_deq_bits_opcode;
  assign io_out_0_a_bits_param = Repeater_5_1_io_deq_bits_param;
  assign io_out_0_a_bits_size = Repeater_5_1_io_deq_bits_size;
  assign io_out_0_a_bits_source = Repeater_5_1_io_deq_bits_source;
  assign io_out_0_a_bits_address = Repeater_5_1_io_deq_bits_address;
  assign io_out_0_a_bits_mask =
      (T_1541[0] & Repeater_5_1_io_deq_bits_mask[0]) | 
      (T_1541[1] & Repeater_5_1_io_deq_bits_mask[1]) |
      (T_1541[2] & Repeater_5_1_io_deq_bits_mask[2]) |
      (T_1541[3] & Repeater_5_1_io_deq_bits_mask[3]);
  assign io_out_0_a_bits_data = 8'h0;
  assign io_out_0_b_ready = 1'h1;
  assign io_out_0_c_valid = 1'h0;
  assign io_out_0_c_bits_opcode = 3'b0;
  assign io_out_0_c_bits_param = 3'b0;
  assign io_out_0_c_bits_size = 3'b0;
  assign io_out_0_c_bits_source = 2'b0;
  assign io_out_0_c_bits_address = 30'b0;
  assign io_out_0_c_bits_data = 8'b0;
  assign io_out_0_c_bits_error = 1'b0;
  assign io_out_0_d_ready = io_in_0_d_ready | ~T_1536;
  assign io_out_0_e_valid = 1'h0;
  assign io_out_0_e_bits_sink = 1'b0;
  assign T_1515 = {io_out_0_d_bits_data,T_1512};
  assign T_1534 = ~(2'h3 << io_out_0_d_bits_size);
  assign T_1535 = ~(2'h3 << Repeater_5_1_io_deq_bits_size);
  assign T_1536 = T_1527 == T_1534;
  assign T_1540 = io_out_0_d_ready & io_out_0_d_valid;
  assign T_1541 = Repeater_5_1_io_deq_bits_mask[3:0] & (T_1447[3] ? {~T_1535[0],~T_1535[1],~T_1535[0],1'h1} : {T_1447[2:0],1'b0});
  assign T_1548 = {T_1515[31:24],T_1515[31:24]};

  always @(posedge clock or posedge reset) 
    if (reset) begin
      T_1447 <= 4'hf;
    end else begin
      T_1447 <= (io_out_0_a_ready & io_out_0_a_valid) ? 4'hf : T_1447;
    end


  always @(posedge clock or posedge reset) 
  if (reset) begin
      T_1512 <= 24'b0;
      T_1514 <= 3'b0;
  end
  else begin
    if (T_1540) begin
      T_1512 <= T_1515[31:8];
    end
    if (T_1540) begin
      T_1514 <= {1'h1,T_1514[2:1]};
    end
  end


  always @(posedge clock or posedge reset) 
    if (reset) begin
      T_1527 <= 2'h0;
    end else begin
      if (T_1540) begin
        if (T_1536) begin
          T_1527 <= 2'h0;
        end else begin
          T_1527 <= T_1527 + 2'h1;
        end
      end
    end

endmodule
