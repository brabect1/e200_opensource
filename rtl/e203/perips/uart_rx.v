//----------------------------------------------------------------------
//   Copyright 2018 Tomas Brabec
//   Copyright 2011-2012 Mentor Graphics Corporation
//   All Rights Reserved Worldwide
//
//   Licensed under the Apache License, Version 2.0 (the
//   "License"); you may not use this file except in
//   compliance with the License.  You may obtain a copy of
//   the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in
//   writing, software distributed under the License is
//   distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
//   CONDITIONS OF ANY KIND, either express or implied.  See
//   the License for the specific language governing
//   permissions and limitations under the License.
//
//   Note:
//     This code comes from an example from Verification Cookbook
//     available at Verification Accademy web page.
//
//   Change log:
//
//     2018, Aug., Tomas Brabec
//     - Added reference to Verification Accademy, where this code comes
//       from.
//     - Modified for purposes of SiFive UART IP (removed FIFO, changed
//       control interface to match sirv_uart, removed bit_counter and
//       implemented baud divisor).
//
//----------------------------------------------------------------------

//
// UART receive engine
//
module uart_rx(
  input clock,
  input reset,
  input   io_en,
  input   io_in,
  output  io_out_valid,
  output [7:0] io_out_bits,
  input  [15:0] io_div,

  // Line Control Register (LCR)
  // [1:0]  Number of bits per charcter (00=5, 01=6, 10=7, 11=8)
  // [2]    Number of stop bits (0=1, 1=2)
  // [3]    Parity enable (0=no parity, 1=parity on)
  // [4]    Even parity select (0=odd, 1=even)
  // [5]    Srick parity select (0=stick parity disabled, 1=inverse of bit 4 expected as parity)
  // [6]    Break control bit (0=break disabled, 1=Tx line held low to indicate break condition)
  // [7]    unused
  input[7:0] LCR,
  output reg rx_idle,
  output reg parity_error,
  output reg framing_error,
  output reg break_error
);

localparam IDLE = 4'd0;
localparam START = 4'd1;
localparam BIT0 = 4'd2;
localparam BIT1 = 4'd3;
localparam BIT2 = 4'd4;
localparam BIT3 = 4'd5;
localparam BIT4 = 4'd6;
localparam BIT5 = 4'd7;
localparam BIT6 = 4'd8;
localparam BIT7 = 4'd9;
localparam PARITY = 4'd10;
localparam STOP1 = 4'd11;
localparam STOP2 = 4'd12;

wire rx_start;
reg[3:0] rx_state;
//reg[3:0] bit_counter;
reg[10:0] rx_buffer;
reg push_rx_fifo;

reg[2:0] filter;
wire filtered_rxd;

reg[15:0] dlc;
reg enable;

assign io_out_valid = push_rx_fifo;
assign io_out_bits = rx_buffer;

assign rx_start = io_en & (filtered_rxd == 0);

//
// Baud rate generator:
//
// Frequency divider
always @(posedge clock or posedge reset) begin
  if (reset)
    dlc <= 0;
  else
    if (rx_state == IDLE)
      // The start bit is checked in the half of the baud cycle and since
      // that on all others then in a baud cycle (so that a data/parity/stop
      // bit is sampled at the half of a baud time).
      dlc <= {1'b0,io_div[15:1]} - 1;      // preset counter to half a baud
    else if (dlc == 16'd0)
      dlc <= io_div - 1;               // preset counter for a baud
    else
      dlc <= dlc - 1;              // decrement counter
end

// Enable signal generation logic
always @(posedge clock or posedge reset) begin
  if (reset)
    enable <= 1'b0;
  else
    if ((io_div != 16'd0) & (dlc == 16'd0))     // div>0 & dlc==0
      enable <= 1'b1;
    else
      enable <= 1'b0;
end

// Majority logic filter and sync stage:
always @(posedge clock or posedge reset) begin
  if(reset) begin
    filter <= 3'b111;
  end
  else begin
    filter[0] <= io_in;
    filter[2:1] <= filter[1:0];
  end
end

always @(*)
  case(filter)
    3'b000: filtered_rxd = 0;
    3'b001: filtered_rxd = 0;
    3'b010: filtered_rxd = 0;
    3'b011: filtered_rxd = 1;
    3'b100: filtered_rxd = 0;
    3'b101: filtered_rxd = 1;
    3'b110: filtered_rxd = 1;
    3'b111: filtered_rxd = 1;
    default: filtered_rxd = 1;
  endcase

// RX FSM:
always @(posedge clock or posedge reset) begin
  if(reset) begin
    rx_state <= IDLE;
//    bit_counter <= 0;
    push_rx_fifo <= 0;
    rx_buffer <= 0;
    parity_error <= 0;
    framing_error <= 0;
    break_error <= 0;
    rx_idle <= 1;
  end
  else begin
    case(rx_state)
      IDLE: begin
              push_rx_fifo <= 0;
              rx_buffer <= 0;
//              bit_counter <= 0;
              if(rx_start) begin
                rx_state <= START;
                rx_idle <= 0;
              end
              else begin
                rx_idle <= 1;
              end
            end
      START: begin
               if(enable == 1) begin
//                 if((bit_counter == 4'h6) && (filtered_rxd == 0)) begin
                 if(filtered_rxd == 0) begin
                   rx_state <= BIT0;
//                   bit_counter <= 0;
                 end
                 else begin
                   if(filtered_rxd == 1) begin
                     rx_state <= IDLE;
                   end
//                   else begin
//                     bit_counter <= bit_counter + 1;
//                   end
                 end
               end
             end
      BIT0: begin
//               if((enable == 1) && (bit_counter == 4'hf)) begin
               if(enable == 1) begin
                 rx_state <= BIT1;
                 rx_buffer[0] <= filtered_rxd;
               end
//               if(enable == 1) begin
//                 bit_counter <= bit_counter + 1;
//               end
             end
      BIT1: begin
//               if((enable == 1) && (bit_counter == 4'hf)) begin
               if(enable == 1) begin
                 rx_buffer[1] <= filtered_rxd;
                 rx_state <= BIT2;
               end
//               if(enable == 1) begin
//                 bit_counter <= bit_counter + 1;
//               end
             end
      BIT2: begin
//               if((enable == 1) && (bit_counter == 4'hf)) begin
               if(enable == 1) begin
                 rx_state <= BIT3;
                 rx_buffer[2] <= filtered_rxd;
               end
//               if(enable == 1) begin
//                 bit_counter <= bit_counter + 1;
//               end
             end
      BIT3: begin
//               if((enable == 1) && (bit_counter == 4'hf)) begin
               if(enable == 1) begin
                 rx_buffer[3] <= filtered_rxd;
                 rx_state <= BIT4;
               end
//               if(enable == 1) begin
//                 bit_counter <= bit_counter + 1;
//               end
             end
      BIT4: begin
//               if((enable == 1) && (bit_counter == 4'hf)) begin
               if(enable == 1) begin
                 rx_buffer[4] <= filtered_rxd;
                 if(LCR[1:0] != 0) begin

                   rx_state <= BIT5;
                 end
                 else begin
                   if(LCR[3] == 1) begin
                     rx_state <= PARITY;
                   end
                   else begin
                     rx_state <= STOP1;
                   end
                 end
               end
//               if(enable == 1) begin
//                 bit_counter <= bit_counter + 1;
//               end
             end
      BIT5: begin
//               if((enable == 1) && (bit_counter == 4'hf)) begin
               if(enable == 1) begin
                 rx_buffer[5] <= filtered_rxd;
                 if(LCR[1:0] > 2'b01) begin
                   rx_state <= BIT6;
                   rx_buffer[5] <= filtered_rxd;
                 end
                 else begin
                   if(LCR[3] == 1) begin
                     rx_state <= PARITY;
                   end
                   else begin
                     rx_state <= STOP1;
                   end
                 end
               end
//               if(enable == 1) begin
//                 bit_counter <= bit_counter + 1;
//               end
             end
      BIT6: begin
//               if((enable == 1) && (bit_counter == 4'hf)) begin
               if(enable == 1) begin
                 rx_buffer[6] <= filtered_rxd;
                 if(LCR[1:0] == 2'b11) begin
                   rx_state <= BIT7;
                 end
                 else begin
                   if(LCR[3] == 1) begin
                     rx_state <= PARITY;
                   end
                   else begin
                     rx_state <= STOP1;
                   end
                 end
               end
//               if(enable == 1) begin
//                 bit_counter <= bit_counter + 1;
//               end
             end
      BIT7: begin
//               if((enable == 1) && (bit_counter == 4'hf)) begin
               if(enable == 1) begin
                 rx_buffer[7] <= filtered_rxd;
                 if(LCR[3] == 1) begin
                   rx_state <= PARITY;
                 end
                 else begin
                   rx_state <= STOP1;
                 end
               end
//               if(enable == 1) begin
//                 bit_counter <= bit_counter + 1;
//               end
             end
      PARITY: begin
//                if((enable == 1) && (bit_counter == 4'hf)) begin
                if(enable == 1) begin
                  rx_state <= STOP1;
                  case(LCR[5:3])
                    3'b001: rx_buffer[9] <= ~(filtered_rxd == ~(^rx_buffer));
                    3'b011: rx_buffer[9] <= ~(filtered_rxd == (^rx_buffer));
                    3'b101: rx_buffer[9] <= ~filtered_rxd; // Stick 1
                    3'b111: rx_buffer[9] <= filtered_rxd; // Stick 0
                    default: rx_buffer[9] <= 0;
                  endcase
                end
//                if(enable == 1) begin
//                  bit_counter <= bit_counter + 1;
//                end
              end
       STOP1: begin
                parity_error <= rx_buffer[9];
//                if((enable == 1) && (bit_counter == 4'hf)) begin
                if(enable == 1) begin
                  rx_state <= STOP2;
                  rx_buffer[8] <= ~filtered_rxd;
                  rx_buffer[10] <= ~(|{filtered_rxd, rx_buffer}); // Break error
                end
//                if(enable == 1) begin
//                  bit_counter <= bit_counter + 1;
//                end
              end
       STOP2: begin
                framing_error <= rx_buffer[8];
                break_error <= rx_buffer[10];
                push_rx_fifo <= 1;
                rx_state <= IDLE;
              end
       default: rx_state <= IDLE;
     endcase
   end
end

// property rx_parity;
//   @(posedge clock)
//   $rose(rx_state == STOP1) |=> parity_error == rx_buffer[9];
// endproperty: rx_parity
// 
// RX_PE_CHK: assert property(rx_parity);
// 
// property rx_framing;
//   @(posedge clock)
//   $rose((rx_state == STOP1) && (enable == 1) && (bit_counter == 4'hf)) |=>
//     rx_buffer[8] == ~filtered_rxd;
// endproperty: rx_framing
// 
// RX_FE_CHK: assert property(rx_framing);
// 
// property rx_break;
//   @(posedge clock)
//   $rose((rx_state == STOP2) && ~(|{filtered_rxd, rx_buffer})) |=> break_error;
// endproperty: rx_break
// 
// RX_BE_CHK: assert property(rx_break);

endmodule: uart_rx
