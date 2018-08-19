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
                                                                         
                                                                         
                                                                         
module sirv_queue_1(
  input   clock,
  input   reset,
  output  io_enq_ready,
  input   io_enq_valid,
  input  [7:0] io_enq_bits,
  input   io_deq_ready,
  output  io_deq_valid,
  output [7:0] io_deq_bits,
  output [3:0] io_count
);
  reg [7:0] ram [0:7]; // FIFO memory
  reg [2:0] wptr; // enqueue/write pointer
  reg [2:0] rptr; // dequeue/read pointer
  reg  maybe_full; // last op decreased (0) or increased (1) records count
  wire  ptr_match;
  wire [2:0] ptr_diff;
  wire  enq;
  wire  deq;
  assign ptr_match = wptr == rptr;
//---->>>> TODO: These are outputs and would rather be registered.
  assign io_enq_ready = ~ptr_match | ~maybe_full;
  assign io_deq_valid = ~ptr_match |  maybe_full;
//<<<<----
  assign io_deq_bits = ram[rptr];
  assign enq = io_enq_ready & io_enq_valid;
  assign deq = io_deq_ready & io_deq_valid;


//---->>>> TODO: The records count is used for water marking and hence
//               would rather be registered.
  assign ptr_diff = wptr - rptr;
  assign io_count = {(maybe_full & ptr_match),ptr_diff};
//<<<<----

  always @(posedge clock) begin // The RAM block does not need reset
    if (enq) begin
      ram[wptr] <= io_enq_bits;
    end
  end

  always @(posedge clock or posedge reset)
    if (reset) begin
      wptr <= 3'h0;
    end else if (enq) begin
      wptr <= wptr + 1'h1;
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      rptr <= 3'h0;
    end else if (deq) begin
      rptr <= rptr + 3'h1;
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      maybe_full <= 1'h0;
    end else if (enq != deq) begin
      maybe_full <= enq;
    end

endmodule
