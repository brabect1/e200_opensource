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
                                                                         
                                                                         
                                                                         
module sirv_uarttx(
  input   clock,
  input   reset,
  input   io_en,
  output  io_in_ready,
  input   io_in_valid,
  input  [7:0] io_in_bits,
  output  io_out,
  input  [15:0] io_div,
  input   io_nstop
);
  reg [15:0] prescaler;
  wire  pulse;
  reg [3:0] counter;
  reg [8:0] shifter;
  reg  out;
  wire  busy;
  wire  start_T_34;
  wire  next_bit_T_56;
  assign io_in_ready = (io_en & (busy == 1'h0));
  assign io_out = out;
  assign pulse = prescaler == 16'h0;
  assign busy = counter != 4'h0;
  assign start_T_34 = io_in_ready & io_in_valid;
  assign next_bit_T_56 = pulse & busy;

  always @(posedge clock or posedge reset)
    if (reset) begin
      prescaler <= 16'h0;
    end else begin
      if (busy) begin
        if (pulse) begin
          prescaler <= io_div;
        end else begin
          prescaler <= prescaler - 1'h1;
        end
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      counter <= 4'h0;
    end else begin
      if (next_bit_T_56) begin
        counter <= counter - 1'h1;
      end else if (start_T_34) begin
        counter <= io_nstop ? 4'hb : 4'ha;
      end
    end



  always @(posedge clock or posedge reset)
  if (reset) begin
      shifter <= 9'b0;
  end
  else begin
    if (next_bit_T_56) begin
      shifter <= {1'h1,shifter[8:1]};
    end else if (start_T_34) begin
      shifter <= {io_in_bits,1'h0};
    end
  end


  always @(posedge clock or posedge reset)
    if (reset) begin
      out <= 1'h1;
    end else begin
      if (next_bit_T_56) begin
        out <= shifter[0];
      end
    end

    //`ifndef SYNTHESIS
    //`ifdef PRINTF_COND
    //  if (`PRINTF_COND) begin
    //`endif
    //    if (start_T_34 & ~reset) begin
    //      $fwrite(32'h80000002,"%c",io_in_bits);
    //    end
    //`ifdef PRINTF_COND
    //  end
    //`endif
    //`endif

    //synopsys translate_off
  always @(posedge clock or posedge reset) begin
        if (start_T_34 & ~reset) begin
          $fwrite(32'h80000002,"%c",io_in_bits);
        end
  end
    //synopsys translate_on
endmodule

