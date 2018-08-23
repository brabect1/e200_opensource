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
                                                                         
                                                                         
                                                                         

module sirv_tl_repeater_5(
  input   clock,
  input   reset,
  input   io_repeat,
  output  io_full,
  output  io_enq_ready,
  input   io_enq_valid,
  input  [2:0] io_enq_bits_opcode,
  input  [2:0] io_enq_bits_param,
  input  [2:0] io_enq_bits_size,
  input  [1:0] io_enq_bits_source,
  input  [29:0] io_enq_bits_address,
  input  [3:0] io_enq_bits_mask,
  input  [31:0] io_enq_bits_data,
  input   io_deq_ready,
  output  io_deq_valid,
  output [2:0] io_deq_bits_opcode,
  output [2:0] io_deq_bits_param,
  output [2:0] io_deq_bits_size,
  output [1:0] io_deq_bits_source,
  output [29:0] io_deq_bits_address,
  output [3:0] io_deq_bits_mask,
  output [31:0] io_deq_bits_data
);
  reg  full;
  reg [2:0] saved_opcode;
  reg [2:0] saved_param;
  reg [2:0] saved_size;
  reg [1:0] saved_source;
  reg [29:0] saved_address;
  reg [3:0] saved_mask;
  reg [31:0] saved_data;
  wire  T_90;
  assign io_full = full;
  assign io_enq_ready = io_deq_ready & ~full;
  assign io_deq_valid = io_enq_valid | full;
  assign io_deq_bits_opcode = (full ? saved_opcode : io_enq_bits_opcode);
  assign io_deq_bits_param = (full ? saved_param : io_enq_bits_param);
  assign io_deq_bits_size = (full ? saved_size : io_enq_bits_size);
  assign io_deq_bits_source = (full ? saved_source : io_enq_bits_source);
  assign io_deq_bits_address = (full ? saved_address : io_enq_bits_address);
  assign io_deq_bits_mask = (full ? saved_mask : io_enq_bits_mask);
  assign io_deq_bits_data = (full ? saved_data : io_enq_bits_data);
  assign T_90 = (io_enq_ready & io_enq_valid) & io_repeat;

  always @(posedge clock or posedge reset)
    if (reset) begin
      full <= 1'h0;
    end else begin
      if (io_deq_ready & io_deq_valid & ~io_repeat) begin
        full <= 1'h0;
      end else begin
        if (T_90) begin
          full <= 1'h1;
        end
      end
    end


  always @(posedge clock or posedge reset)
  if (reset) begin
    saved_opcode  <= 3'b0;
    saved_param   <= 3'b0;
    saved_size    <= 3'b0;
    saved_source  <= 2'b0;
    saved_address <= 30'b0;
    saved_mask    <= 4'b0;
    saved_data    <= 32'b0;
  end
  else begin
    if (T_90) begin
      saved_opcode <= io_enq_bits_opcode;
    end
    if (T_90) begin
      saved_param <= io_enq_bits_param;
    end
    if (T_90) begin
      saved_size <= io_enq_bits_size;
    end
    if (T_90) begin
      saved_source <= io_enq_bits_source;
    end
    if (T_90) begin
      saved_address <= io_enq_bits_address;
    end
    if (T_90) begin
      saved_mask <= io_enq_bits_mask;
    end
    if (T_90) begin
      saved_data <= io_enq_bits_data;
    end
  end

endmodule
