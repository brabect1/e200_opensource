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
                                                                         
                                                                         
                                                                         
module sirv_uartrx(
  input   clock,
  input   reset,
  input   io_en,
  input   io_in,
  output  io_out_valid,
  output [7:0] io_out_bits,
  input  [15:0] io_div
);
  reg [1:0] debounce;
  wire  debounce_max;
  reg [11:0] prescaler;
  wire  pulse;
  reg [2:0] sample;
  wire  T_35;
  reg [4:0] timer;
  reg [3:0] counter;
  reg [7:0] shifter;
  wire  expire;
  wire [5:0] T_44;
  reg  valid;
  reg [1:0] state;
  wire  T_50;
  wire [1:0] GEN_14;
  wire  T_68;
  wire  T_74;
  wire  T_80;
  wire  GEN_36;
  wire  GEN_41;
  assign io_out_valid = valid;
  assign io_out_bits = shifter;
  assign debounce_max = debounce == 2'h3;
  assign pulse = (prescaler == 12'h0) & GEN_36;
  assign T_35 = ((sample[0] & sample[1]) | (sample[0] & sample[2])) | (sample[1] & sample[2]);
  assign expire = (timer == 5'h0) & pulse;
  assign T_44 = timer - 5'h1;
  assign T_50 = 2'h0 == state;
  assign GEN_14 = T_50 ? (~io_in ? (debounce_max ? 2'h1 : state) : state) : state;
  assign T_68 = 2'h1 == state;
  assign T_74 = 2'h2 == state;
  assign T_80 = counter == 4'h0;
  assign GEN_36 = T_74 | T_68;
  assign GEN_41 = T_74 ? (expire ? (~T_80 ? 1'h1 : (T_68 ? expire : 1'h0)) : (T_68 ? expire : 1'h0)) : (T_68 ? expire : 1'h0);

  always @(posedge clock or posedge reset)
    if (reset) begin
      debounce <= 2'h0;
    end else begin
      if (~io_en) begin
        debounce <= 2'h0;
      end else if (T_50) begin
        if (~io_in) begin
          debounce <= debounce + 1'h1;
        end else if (io_in & (debounce != 2'h0)) begin
          debounce <= debounce - 1'h1;
        end
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      prescaler <= 12'h0;
    end else begin
      if ((T_50 & ~io_in & debounce_max) | pulse) begin
        prescaler <= io_div[15:4];
      end else if (GEN_36) begin
        prescaler <= prescaler - 1'h1;
      end
    end


  always @(posedge clock or posedge reset)
  if (reset) begin

    sample <= 3'b0;
    timer <= 5'h0;
    counter <= 4'b0;
    shifter <= 8'b0;

  end
  else begin
    if (pulse) begin
      sample <= {sample[1:0],io_in};
    end

    if (T_50) begin
      if (~io_in) begin
        if (debounce_max) begin
          timer <= 5'h8;
        end else begin
          if (GEN_41) begin
            timer <= 5'hf;
          end else begin
            if (pulse) begin
              timer <= T_44[4:0];
            end
          end
        end
      end else begin
        if (GEN_41) begin
          timer <= 5'hf;
        end else begin
          if (pulse) begin
            timer <= T_44[4:0];
          end
        end
      end
    end else begin
      if (GEN_41) begin
        timer <= 5'hf;
      end else begin
        if (pulse) begin
          timer <= T_44[4:0];
        end
      end
    end
    if (T_74) begin
      if (expire) begin
        counter <= counter - 1'h1;
      end else begin
        if (T_68) begin
          if (expire) begin
            if (~T_35) begin
              counter <= 4'h8;
            end
          end
        end
      end
    end else begin
      if (T_68) begin
        if (expire) begin
          if (~T_35) begin
            counter <= 4'h8;
          end
        end
      end
    end
    if (T_74) begin
      if (expire) begin
        if (~T_80) begin
          shifter <= ({T_35,shifter[7:1]});
        end
      end
    end
  end


  always @(posedge clock or posedge reset)
    if (reset) begin
      valid <= 1'h0;
    end else begin
      if (T_74 & expire) begin
          valid <= T_80;
      end else begin
        valid <= 1'h0;
      end
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      state <= 2'h0;
    end else begin
      if (T_74) begin
        if (expire) begin
          if (T_80) begin
            state <= 2'h0;
          end else begin
            if (T_68) begin
              if (expire) begin
                if (~T_35) begin
                  state <= 2'h2;
                end else begin
                  if (T_35) begin
                    state <= 2'h0;
                  end else begin
                    if (T_50) begin
                      if (~io_in) begin
                        if (debounce_max) begin
                          state <= 2'h1;
                        end
                      end
                    end
                  end
                end
              end else begin
                if (T_50) begin
                  if (~io_in) begin
                    if (debounce_max) begin
                      state <= 2'h1;
                    end
                  end
                end
              end
            end else begin
              if (T_50) begin
                if (~io_in) begin
                  if (debounce_max) begin
                    state <= 2'h1;
                  end
                end
              end
            end
          end
        end else begin
          if (T_68) begin
            if (expire) begin
              if (~T_35) begin
                state <= 2'h2;
              end else begin
                if (T_35) begin
                  state <= 2'h0;
                end else begin
                  if (T_50) begin
                    if (~io_in) begin
                      if (debounce_max) begin
                        state <= 2'h1;
                      end
                    end
                  end
                end
              end
            end else begin
              state <= GEN_14;
            end
          end else begin
            state <= GEN_14;
          end
        end
      end else begin
        if (T_68) begin
          if (expire) begin
            if (~T_35) begin
              state <= 2'h2;
            end else begin
              if (T_35) begin
                state <= 2'h0;
              end else begin
                state <= GEN_14;
              end
            end
          end else begin
            state <= GEN_14;
          end
        end else begin
          state <= GEN_14;
        end
      end
    end

endmodule

