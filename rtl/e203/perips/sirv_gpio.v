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
                                                                         
                                                                         
                                                                         
module sirv_gpio(
  input   clock,
  input   reset,
  output  io_interrupts_0_0,
  output  io_interrupts_0_1,
  output  io_interrupts_0_2,
  output  io_interrupts_0_3,
  output  io_interrupts_0_4,
  output  io_interrupts_0_5,
  output  io_interrupts_0_6,
  output  io_interrupts_0_7,
  output  io_interrupts_0_8,
  output  io_interrupts_0_9,
  output  io_interrupts_0_10,
  output  io_interrupts_0_11,
  output  io_interrupts_0_12,
  output  io_interrupts_0_13,
  output  io_interrupts_0_14,
  output  io_interrupts_0_15,
  output  io_interrupts_0_16,
  output  io_interrupts_0_17,
  output  io_interrupts_0_18,
  output  io_interrupts_0_19,
  output  io_interrupts_0_20,
  output  io_interrupts_0_21,
  output  io_interrupts_0_22,
  output  io_interrupts_0_23,
  output  io_interrupts_0_24,
  output  io_interrupts_0_25,
  output  io_interrupts_0_26,
  output  io_interrupts_0_27,
  output  io_interrupts_0_28,
  output  io_interrupts_0_29,
  output  io_interrupts_0_30,
  output  io_interrupts_0_31,
  output  io_in_0_a_ready,
  input   io_in_0_a_valid,
  input  [2:0] io_in_0_a_bits_opcode,
  input  [2:0] io_in_0_a_bits_param,
  input  [2:0] io_in_0_a_bits_size,
  input  [4:0] io_in_0_a_bits_source,
  input  [28:0] io_in_0_a_bits_address,
  input  [3:0] io_in_0_a_bits_mask,
  input  [31:0] io_in_0_a_bits_data,
  input   io_in_0_b_ready,
  output  io_in_0_b_valid,
  output [2:0] io_in_0_b_bits_opcode,
  output [1:0] io_in_0_b_bits_param,
  output [2:0] io_in_0_b_bits_size,
  output [4:0] io_in_0_b_bits_source,
  output [28:0] io_in_0_b_bits_address,
  output [3:0] io_in_0_b_bits_mask,
  output [31:0] io_in_0_b_bits_data,
  output  io_in_0_c_ready,
  input   io_in_0_c_valid,
  input  [2:0] io_in_0_c_bits_opcode,
  input  [2:0] io_in_0_c_bits_param,
  input  [2:0] io_in_0_c_bits_size,
  input  [4:0] io_in_0_c_bits_source,
  input  [28:0] io_in_0_c_bits_address,
  input  [31:0] io_in_0_c_bits_data,
  input   io_in_0_c_bits_error,
  input   io_in_0_d_ready,
  output  io_in_0_d_valid,
  output [2:0] io_in_0_d_bits_opcode,
  output [1:0] io_in_0_d_bits_param,
  output [2:0] io_in_0_d_bits_size,
  output [4:0] io_in_0_d_bits_source,
  output  io_in_0_d_bits_sink,
  output [1:0] io_in_0_d_bits_addr_lo,
  output [31:0] io_in_0_d_bits_data,
  output  io_in_0_d_bits_error,
  output  io_in_0_e_ready,
  input   io_in_0_e_valid,
  input   io_in_0_e_bits_sink,
  input   io_port_pins_0_i_ival,
  output  io_port_pins_0_o_oval,
  output  io_port_pins_0_o_oe,
  output  io_port_pins_0_o_ie,
  output  io_port_pins_0_o_pue,
  output  io_port_pins_0_o_ds,
  input   io_port_pins_1_i_ival,
  output  io_port_pins_1_o_oval,
  output  io_port_pins_1_o_oe,
  output  io_port_pins_1_o_ie,
  output  io_port_pins_1_o_pue,
  output  io_port_pins_1_o_ds,
  input   io_port_pins_2_i_ival,
  output  io_port_pins_2_o_oval,
  output  io_port_pins_2_o_oe,
  output  io_port_pins_2_o_ie,
  output  io_port_pins_2_o_pue,
  output  io_port_pins_2_o_ds,
  input   io_port_pins_3_i_ival,
  output  io_port_pins_3_o_oval,
  output  io_port_pins_3_o_oe,
  output  io_port_pins_3_o_ie,
  output  io_port_pins_3_o_pue,
  output  io_port_pins_3_o_ds,
  input   io_port_pins_4_i_ival,
  output  io_port_pins_4_o_oval,
  output  io_port_pins_4_o_oe,
  output  io_port_pins_4_o_ie,
  output  io_port_pins_4_o_pue,
  output  io_port_pins_4_o_ds,
  input   io_port_pins_5_i_ival,
  output  io_port_pins_5_o_oval,
  output  io_port_pins_5_o_oe,
  output  io_port_pins_5_o_ie,
  output  io_port_pins_5_o_pue,
  output  io_port_pins_5_o_ds,
  input   io_port_pins_6_i_ival,
  output  io_port_pins_6_o_oval,
  output  io_port_pins_6_o_oe,
  output  io_port_pins_6_o_ie,
  output  io_port_pins_6_o_pue,
  output  io_port_pins_6_o_ds,
  input   io_port_pins_7_i_ival,
  output  io_port_pins_7_o_oval,
  output  io_port_pins_7_o_oe,
  output  io_port_pins_7_o_ie,
  output  io_port_pins_7_o_pue,
  output  io_port_pins_7_o_ds,
  input   io_port_pins_8_i_ival,
  output  io_port_pins_8_o_oval,
  output  io_port_pins_8_o_oe,
  output  io_port_pins_8_o_ie,
  output  io_port_pins_8_o_pue,
  output  io_port_pins_8_o_ds,
  input   io_port_pins_9_i_ival,
  output  io_port_pins_9_o_oval,
  output  io_port_pins_9_o_oe,
  output  io_port_pins_9_o_ie,
  output  io_port_pins_9_o_pue,
  output  io_port_pins_9_o_ds,
  input   io_port_pins_10_i_ival,
  output  io_port_pins_10_o_oval,
  output  io_port_pins_10_o_oe,
  output  io_port_pins_10_o_ie,
  output  io_port_pins_10_o_pue,
  output  io_port_pins_10_o_ds,
  input   io_port_pins_11_i_ival,
  output  io_port_pins_11_o_oval,
  output  io_port_pins_11_o_oe,
  output  io_port_pins_11_o_ie,
  output  io_port_pins_11_o_pue,
  output  io_port_pins_11_o_ds,
  input   io_port_pins_12_i_ival,
  output  io_port_pins_12_o_oval,
  output  io_port_pins_12_o_oe,
  output  io_port_pins_12_o_ie,
  output  io_port_pins_12_o_pue,
  output  io_port_pins_12_o_ds,
  input   io_port_pins_13_i_ival,
  output  io_port_pins_13_o_oval,
  output  io_port_pins_13_o_oe,
  output  io_port_pins_13_o_ie,
  output  io_port_pins_13_o_pue,
  output  io_port_pins_13_o_ds,
  input   io_port_pins_14_i_ival,
  output  io_port_pins_14_o_oval,
  output  io_port_pins_14_o_oe,
  output  io_port_pins_14_o_ie,
  output  io_port_pins_14_o_pue,
  output  io_port_pins_14_o_ds,
  input   io_port_pins_15_i_ival,
  output  io_port_pins_15_o_oval,
  output  io_port_pins_15_o_oe,
  output  io_port_pins_15_o_ie,
  output  io_port_pins_15_o_pue,
  output  io_port_pins_15_o_ds,
  input   io_port_pins_16_i_ival,
  output  io_port_pins_16_o_oval,
  output  io_port_pins_16_o_oe,
  output  io_port_pins_16_o_ie,
  output  io_port_pins_16_o_pue,
  output  io_port_pins_16_o_ds,
  input   io_port_pins_17_i_ival,
  output  io_port_pins_17_o_oval,
  output  io_port_pins_17_o_oe,
  output  io_port_pins_17_o_ie,
  output  io_port_pins_17_o_pue,
  output  io_port_pins_17_o_ds,
  input   io_port_pins_18_i_ival,
  output  io_port_pins_18_o_oval,
  output  io_port_pins_18_o_oe,
  output  io_port_pins_18_o_ie,
  output  io_port_pins_18_o_pue,
  output  io_port_pins_18_o_ds,
  input   io_port_pins_19_i_ival,
  output  io_port_pins_19_o_oval,
  output  io_port_pins_19_o_oe,
  output  io_port_pins_19_o_ie,
  output  io_port_pins_19_o_pue,
  output  io_port_pins_19_o_ds,
  input   io_port_pins_20_i_ival,
  output  io_port_pins_20_o_oval,
  output  io_port_pins_20_o_oe,
  output  io_port_pins_20_o_ie,
  output  io_port_pins_20_o_pue,
  output  io_port_pins_20_o_ds,
  input   io_port_pins_21_i_ival,
  output  io_port_pins_21_o_oval,
  output  io_port_pins_21_o_oe,
  output  io_port_pins_21_o_ie,
  output  io_port_pins_21_o_pue,
  output  io_port_pins_21_o_ds,
  input   io_port_pins_22_i_ival,
  output  io_port_pins_22_o_oval,
  output  io_port_pins_22_o_oe,
  output  io_port_pins_22_o_ie,
  output  io_port_pins_22_o_pue,
  output  io_port_pins_22_o_ds,
  input   io_port_pins_23_i_ival,
  output  io_port_pins_23_o_oval,
  output  io_port_pins_23_o_oe,
  output  io_port_pins_23_o_ie,
  output  io_port_pins_23_o_pue,
  output  io_port_pins_23_o_ds,
  input   io_port_pins_24_i_ival,
  output  io_port_pins_24_o_oval,
  output  io_port_pins_24_o_oe,
  output  io_port_pins_24_o_ie,
  output  io_port_pins_24_o_pue,
  output  io_port_pins_24_o_ds,
  input   io_port_pins_25_i_ival,
  output  io_port_pins_25_o_oval,
  output  io_port_pins_25_o_oe,
  output  io_port_pins_25_o_ie,
  output  io_port_pins_25_o_pue,
  output  io_port_pins_25_o_ds,
  input   io_port_pins_26_i_ival,
  output  io_port_pins_26_o_oval,
  output  io_port_pins_26_o_oe,
  output  io_port_pins_26_o_ie,
  output  io_port_pins_26_o_pue,
  output  io_port_pins_26_o_ds,
  input   io_port_pins_27_i_ival,
  output  io_port_pins_27_o_oval,
  output  io_port_pins_27_o_oe,
  output  io_port_pins_27_o_ie,
  output  io_port_pins_27_o_pue,
  output  io_port_pins_27_o_ds,
  input   io_port_pins_28_i_ival,
  output  io_port_pins_28_o_oval,
  output  io_port_pins_28_o_oe,
  output  io_port_pins_28_o_ie,
  output  io_port_pins_28_o_pue,
  output  io_port_pins_28_o_ds,
  input   io_port_pins_29_i_ival,
  output  io_port_pins_29_o_oval,
  output  io_port_pins_29_o_oe,
  output  io_port_pins_29_o_ie,
  output  io_port_pins_29_o_pue,
  output  io_port_pins_29_o_ds,
  input   io_port_pins_30_i_ival,
  output  io_port_pins_30_o_oval,
  output  io_port_pins_30_o_oe,
  output  io_port_pins_30_o_ie,
  output  io_port_pins_30_o_pue,
  output  io_port_pins_30_o_ds,
  input   io_port_pins_31_i_ival,
  output  io_port_pins_31_o_oval,
  output  io_port_pins_31_o_oe,
  output  io_port_pins_31_o_ie,
  output  io_port_pins_31_o_pue,
  output  io_port_pins_31_o_ds,
  output  io_port_iof_0_0_i_ival,
  input   io_port_iof_0_0_o_oval,
  input   io_port_iof_0_0_o_oe,
  input   io_port_iof_0_0_o_ie,
  input   io_port_iof_0_0_o_valid,
  output  io_port_iof_0_1_i_ival,
  input   io_port_iof_0_1_o_oval,
  input   io_port_iof_0_1_o_oe,
  input   io_port_iof_0_1_o_ie,
  input   io_port_iof_0_1_o_valid,
  output  io_port_iof_0_2_i_ival,
  input   io_port_iof_0_2_o_oval,
  input   io_port_iof_0_2_o_oe,
  input   io_port_iof_0_2_o_ie,
  input   io_port_iof_0_2_o_valid,
  output  io_port_iof_0_3_i_ival,
  input   io_port_iof_0_3_o_oval,
  input   io_port_iof_0_3_o_oe,
  input   io_port_iof_0_3_o_ie,
  input   io_port_iof_0_3_o_valid,
  output  io_port_iof_0_4_i_ival,
  input   io_port_iof_0_4_o_oval,
  input   io_port_iof_0_4_o_oe,
  input   io_port_iof_0_4_o_ie,
  input   io_port_iof_0_4_o_valid,
  output  io_port_iof_0_5_i_ival,
  input   io_port_iof_0_5_o_oval,
  input   io_port_iof_0_5_o_oe,
  input   io_port_iof_0_5_o_ie,
  input   io_port_iof_0_5_o_valid,
  output  io_port_iof_0_6_i_ival,
  input   io_port_iof_0_6_o_oval,
  input   io_port_iof_0_6_o_oe,
  input   io_port_iof_0_6_o_ie,
  input   io_port_iof_0_6_o_valid,
  output  io_port_iof_0_7_i_ival,
  input   io_port_iof_0_7_o_oval,
  input   io_port_iof_0_7_o_oe,
  input   io_port_iof_0_7_o_ie,
  input   io_port_iof_0_7_o_valid,
  output  io_port_iof_0_8_i_ival,
  input   io_port_iof_0_8_o_oval,
  input   io_port_iof_0_8_o_oe,
  input   io_port_iof_0_8_o_ie,
  input   io_port_iof_0_8_o_valid,
  output  io_port_iof_0_9_i_ival,
  input   io_port_iof_0_9_o_oval,
  input   io_port_iof_0_9_o_oe,
  input   io_port_iof_0_9_o_ie,
  input   io_port_iof_0_9_o_valid,
  output  io_port_iof_0_10_i_ival,
  input   io_port_iof_0_10_o_oval,
  input   io_port_iof_0_10_o_oe,
  input   io_port_iof_0_10_o_ie,
  input   io_port_iof_0_10_o_valid,
  output  io_port_iof_0_11_i_ival,
  input   io_port_iof_0_11_o_oval,
  input   io_port_iof_0_11_o_oe,
  input   io_port_iof_0_11_o_ie,
  input   io_port_iof_0_11_o_valid,
  output  io_port_iof_0_12_i_ival,
  input   io_port_iof_0_12_o_oval,
  input   io_port_iof_0_12_o_oe,
  input   io_port_iof_0_12_o_ie,
  input   io_port_iof_0_12_o_valid,
  output  io_port_iof_0_13_i_ival,
  input   io_port_iof_0_13_o_oval,
  input   io_port_iof_0_13_o_oe,
  input   io_port_iof_0_13_o_ie,
  input   io_port_iof_0_13_o_valid,
  output  io_port_iof_0_14_i_ival,
  input   io_port_iof_0_14_o_oval,
  input   io_port_iof_0_14_o_oe,
  input   io_port_iof_0_14_o_ie,
  input   io_port_iof_0_14_o_valid,
  output  io_port_iof_0_15_i_ival,
  input   io_port_iof_0_15_o_oval,
  input   io_port_iof_0_15_o_oe,
  input   io_port_iof_0_15_o_ie,
  input   io_port_iof_0_15_o_valid,
  output  io_port_iof_0_16_i_ival,
  input   io_port_iof_0_16_o_oval,
  input   io_port_iof_0_16_o_oe,
  input   io_port_iof_0_16_o_ie,
  input   io_port_iof_0_16_o_valid,
  output  io_port_iof_0_17_i_ival,
  input   io_port_iof_0_17_o_oval,
  input   io_port_iof_0_17_o_oe,
  input   io_port_iof_0_17_o_ie,
  input   io_port_iof_0_17_o_valid,
  output  io_port_iof_0_18_i_ival,
  input   io_port_iof_0_18_o_oval,
  input   io_port_iof_0_18_o_oe,
  input   io_port_iof_0_18_o_ie,
  input   io_port_iof_0_18_o_valid,
  output  io_port_iof_0_19_i_ival,
  input   io_port_iof_0_19_o_oval,
  input   io_port_iof_0_19_o_oe,
  input   io_port_iof_0_19_o_ie,
  input   io_port_iof_0_19_o_valid,
  output  io_port_iof_0_20_i_ival,
  input   io_port_iof_0_20_o_oval,
  input   io_port_iof_0_20_o_oe,
  input   io_port_iof_0_20_o_ie,
  input   io_port_iof_0_20_o_valid,
  output  io_port_iof_0_21_i_ival,
  input   io_port_iof_0_21_o_oval,
  input   io_port_iof_0_21_o_oe,
  input   io_port_iof_0_21_o_ie,
  input   io_port_iof_0_21_o_valid,
  output  io_port_iof_0_22_i_ival,
  input   io_port_iof_0_22_o_oval,
  input   io_port_iof_0_22_o_oe,
  input   io_port_iof_0_22_o_ie,
  input   io_port_iof_0_22_o_valid,
  output  io_port_iof_0_23_i_ival,
  input   io_port_iof_0_23_o_oval,
  input   io_port_iof_0_23_o_oe,
  input   io_port_iof_0_23_o_ie,
  input   io_port_iof_0_23_o_valid,
  output  io_port_iof_0_24_i_ival,
  input   io_port_iof_0_24_o_oval,
  input   io_port_iof_0_24_o_oe,
  input   io_port_iof_0_24_o_ie,
  input   io_port_iof_0_24_o_valid,
  output  io_port_iof_0_25_i_ival,
  input   io_port_iof_0_25_o_oval,
  input   io_port_iof_0_25_o_oe,
  input   io_port_iof_0_25_o_ie,
  input   io_port_iof_0_25_o_valid,
  output  io_port_iof_0_26_i_ival,
  input   io_port_iof_0_26_o_oval,
  input   io_port_iof_0_26_o_oe,
  input   io_port_iof_0_26_o_ie,
  input   io_port_iof_0_26_o_valid,
  output  io_port_iof_0_27_i_ival,
  input   io_port_iof_0_27_o_oval,
  input   io_port_iof_0_27_o_oe,
  input   io_port_iof_0_27_o_ie,
  input   io_port_iof_0_27_o_valid,
  output  io_port_iof_0_28_i_ival,
  input   io_port_iof_0_28_o_oval,
  input   io_port_iof_0_28_o_oe,
  input   io_port_iof_0_28_o_ie,
  input   io_port_iof_0_28_o_valid,
  output  io_port_iof_0_29_i_ival,
  input   io_port_iof_0_29_o_oval,
  input   io_port_iof_0_29_o_oe,
  input   io_port_iof_0_29_o_ie,
  input   io_port_iof_0_29_o_valid,
  output  io_port_iof_0_30_i_ival,
  input   io_port_iof_0_30_o_oval,
  input   io_port_iof_0_30_o_oe,
  input   io_port_iof_0_30_o_ie,
  input   io_port_iof_0_30_o_valid,
  output  io_port_iof_0_31_i_ival,
  input   io_port_iof_0_31_o_oval,
  input   io_port_iof_0_31_o_oe,
  input   io_port_iof_0_31_o_ie,
  input   io_port_iof_0_31_o_valid,
  output  io_port_iof_1_0_i_ival,
  input   io_port_iof_1_0_o_oval,
  input   io_port_iof_1_0_o_oe,
  input   io_port_iof_1_0_o_ie,
  input   io_port_iof_1_0_o_valid,
  output  io_port_iof_1_1_i_ival,
  input   io_port_iof_1_1_o_oval,
  input   io_port_iof_1_1_o_oe,
  input   io_port_iof_1_1_o_ie,
  input   io_port_iof_1_1_o_valid,
  output  io_port_iof_1_2_i_ival,
  input   io_port_iof_1_2_o_oval,
  input   io_port_iof_1_2_o_oe,
  input   io_port_iof_1_2_o_ie,
  input   io_port_iof_1_2_o_valid,
  output  io_port_iof_1_3_i_ival,
  input   io_port_iof_1_3_o_oval,
  input   io_port_iof_1_3_o_oe,
  input   io_port_iof_1_3_o_ie,
  input   io_port_iof_1_3_o_valid,
  output  io_port_iof_1_4_i_ival,
  input   io_port_iof_1_4_o_oval,
  input   io_port_iof_1_4_o_oe,
  input   io_port_iof_1_4_o_ie,
  input   io_port_iof_1_4_o_valid,
  output  io_port_iof_1_5_i_ival,
  input   io_port_iof_1_5_o_oval,
  input   io_port_iof_1_5_o_oe,
  input   io_port_iof_1_5_o_ie,
  input   io_port_iof_1_5_o_valid,
  output  io_port_iof_1_6_i_ival,
  input   io_port_iof_1_6_o_oval,
  input   io_port_iof_1_6_o_oe,
  input   io_port_iof_1_6_o_ie,
  input   io_port_iof_1_6_o_valid,
  output  io_port_iof_1_7_i_ival,
  input   io_port_iof_1_7_o_oval,
  input   io_port_iof_1_7_o_oe,
  input   io_port_iof_1_7_o_ie,
  input   io_port_iof_1_7_o_valid,
  output  io_port_iof_1_8_i_ival,
  input   io_port_iof_1_8_o_oval,
  input   io_port_iof_1_8_o_oe,
  input   io_port_iof_1_8_o_ie,
  input   io_port_iof_1_8_o_valid,
  output  io_port_iof_1_9_i_ival,
  input   io_port_iof_1_9_o_oval,
  input   io_port_iof_1_9_o_oe,
  input   io_port_iof_1_9_o_ie,
  input   io_port_iof_1_9_o_valid,
  output  io_port_iof_1_10_i_ival,
  input   io_port_iof_1_10_o_oval,
  input   io_port_iof_1_10_o_oe,
  input   io_port_iof_1_10_o_ie,
  input   io_port_iof_1_10_o_valid,
  output  io_port_iof_1_11_i_ival,
  input   io_port_iof_1_11_o_oval,
  input   io_port_iof_1_11_o_oe,
  input   io_port_iof_1_11_o_ie,
  input   io_port_iof_1_11_o_valid,
  output  io_port_iof_1_12_i_ival,
  input   io_port_iof_1_12_o_oval,
  input   io_port_iof_1_12_o_oe,
  input   io_port_iof_1_12_o_ie,
  input   io_port_iof_1_12_o_valid,
  output  io_port_iof_1_13_i_ival,
  input   io_port_iof_1_13_o_oval,
  input   io_port_iof_1_13_o_oe,
  input   io_port_iof_1_13_o_ie,
  input   io_port_iof_1_13_o_valid,
  output  io_port_iof_1_14_i_ival,
  input   io_port_iof_1_14_o_oval,
  input   io_port_iof_1_14_o_oe,
  input   io_port_iof_1_14_o_ie,
  input   io_port_iof_1_14_o_valid,
  output  io_port_iof_1_15_i_ival,
  input   io_port_iof_1_15_o_oval,
  input   io_port_iof_1_15_o_oe,
  input   io_port_iof_1_15_o_ie,
  input   io_port_iof_1_15_o_valid,
  output  io_port_iof_1_16_i_ival,
  input   io_port_iof_1_16_o_oval,
  input   io_port_iof_1_16_o_oe,
  input   io_port_iof_1_16_o_ie,
  input   io_port_iof_1_16_o_valid,
  output  io_port_iof_1_17_i_ival,
  input   io_port_iof_1_17_o_oval,
  input   io_port_iof_1_17_o_oe,
  input   io_port_iof_1_17_o_ie,
  input   io_port_iof_1_17_o_valid,
  output  io_port_iof_1_18_i_ival,
  input   io_port_iof_1_18_o_oval,
  input   io_port_iof_1_18_o_oe,
  input   io_port_iof_1_18_o_ie,
  input   io_port_iof_1_18_o_valid,
  output  io_port_iof_1_19_i_ival,
  input   io_port_iof_1_19_o_oval,
  input   io_port_iof_1_19_o_oe,
  input   io_port_iof_1_19_o_ie,
  input   io_port_iof_1_19_o_valid,
  output  io_port_iof_1_20_i_ival,
  input   io_port_iof_1_20_o_oval,
  input   io_port_iof_1_20_o_oe,
  input   io_port_iof_1_20_o_ie,
  input   io_port_iof_1_20_o_valid,
  output  io_port_iof_1_21_i_ival,
  input   io_port_iof_1_21_o_oval,
  input   io_port_iof_1_21_o_oe,
  input   io_port_iof_1_21_o_ie,
  input   io_port_iof_1_21_o_valid,
  output  io_port_iof_1_22_i_ival,
  input   io_port_iof_1_22_o_oval,
  input   io_port_iof_1_22_o_oe,
  input   io_port_iof_1_22_o_ie,
  input   io_port_iof_1_22_o_valid,
  output  io_port_iof_1_23_i_ival,
  input   io_port_iof_1_23_o_oval,
  input   io_port_iof_1_23_o_oe,
  input   io_port_iof_1_23_o_ie,
  input   io_port_iof_1_23_o_valid,
  output  io_port_iof_1_24_i_ival,
  input   io_port_iof_1_24_o_oval,
  input   io_port_iof_1_24_o_oe,
  input   io_port_iof_1_24_o_ie,
  input   io_port_iof_1_24_o_valid,
  output  io_port_iof_1_25_i_ival,
  input   io_port_iof_1_25_o_oval,
  input   io_port_iof_1_25_o_oe,
  input   io_port_iof_1_25_o_ie,
  input   io_port_iof_1_25_o_valid,
  output  io_port_iof_1_26_i_ival,
  input   io_port_iof_1_26_o_oval,
  input   io_port_iof_1_26_o_oe,
  input   io_port_iof_1_26_o_ie,
  input   io_port_iof_1_26_o_valid,
  output  io_port_iof_1_27_i_ival,
  input   io_port_iof_1_27_o_oval,
  input   io_port_iof_1_27_o_oe,
  input   io_port_iof_1_27_o_ie,
  input   io_port_iof_1_27_o_valid,
  output  io_port_iof_1_28_i_ival,
  input   io_port_iof_1_28_o_oval,
  input   io_port_iof_1_28_o_oe,
  input   io_port_iof_1_28_o_ie,
  input   io_port_iof_1_28_o_valid,
  output  io_port_iof_1_29_i_ival,
  input   io_port_iof_1_29_o_oval,
  input   io_port_iof_1_29_o_oe,
  input   io_port_iof_1_29_o_ie,
  input   io_port_iof_1_29_o_valid,
  output  io_port_iof_1_30_i_ival,
  input   io_port_iof_1_30_o_oval,
  input   io_port_iof_1_30_o_oe,
  input   io_port_iof_1_30_o_ie,
  input   io_port_iof_1_30_o_valid,
  output  io_port_iof_1_31_i_ival,
  input   io_port_iof_1_31_o_oval,
  input   io_port_iof_1_31_o_oe,
  input   io_port_iof_1_31_o_ie,
  input   io_port_iof_1_31_o_valid
);
  reg [31:0] portReg;
  wire [31:0] oeReg_io_q;
  wire [31:0] pueReg_io_q;
  reg [31:0] dsReg;
  wire [31:0] ieReg_io_q;
  reg [31:0] T_3256;
  reg [31:0] T_3257;
  reg [31:0] inSyncReg;
  reg [31:0] valueReg;
  reg [31:0] highIeReg;
  reg [31:0] lowIeReg;
  reg [31:0] riseIeReg;
  reg [31:0] fallIeReg;
  reg [31:0] highIpReg;
  reg [31:0] lowIpReg;
  reg [31:0] riseIpReg;
  reg [31:0] fallIpReg;
  wire [31:0] iofEnReg_io_q;
  reg [31:0] iofSelReg;
  reg [31:0] xorReg;
  wire [31:0] T_3269;
  wire  T_3312;
  wire [9:0] T_3316;
  wire  T_3457;
  wire  T_3466;
  wire  T_3475;
  wire  T_3484;
  wire  T_3493;
  wire  T_3502;
  wire  T_3511;
  wire  T_3520;
  wire  T_3529;
  wire  T_3538;
  wire  T_3547;
  wire  T_3556;
  wire  T_3565;
  wire  T_3574;
  wire  T_3583;
  wire  T_3592;
  wire  T_3601;
  wire  T_3858;
  wire  T_4557;
  wire  T_4561;
  wire  T_4565;
  wire  T_4569;
  wire  T_4573;
  wire  T_4577;
  wire  T_4581;
  wire  T_4585;
  wire  T_4589;
  wire  T_4593;
  wire  T_4597;
  wire  T_4601;
  wire  T_4605;
  wire  T_4609;
  wire  T_4613;
  wire  T_4617;
  wire  T_4621;
  wire [4:0] T_5301;
  wire  T_5318;
  wire  T_5321;
  wire  T_5323;
  wire [31:0] T_5359;
  wire  T_5411;
  sirv_AsyncResetRegVec_67 u_oeReg (
    .clock(clock),
    .reset(reset),
    .io_d(io_in_0_a_bits_data),
    .io_q(oeReg_io_q),
    .io_en(((T_5411 & T_5359[2]) & T_3858))
  );
  sirv_AsyncResetRegVec_67 u_pueReg (
    .clock(clock),
    .reset(reset),
    .io_d(io_in_0_a_bits_data),
    .io_q(pueReg_io_q),
    .io_en(((T_5411 & T_5359[4]) & T_3858))
  );
  sirv_AsyncResetRegVec_67 u_ieReg (
    .clock(clock),
    .reset(reset),
    .io_d(io_in_0_a_bits_data),
    .io_q(ieReg_io_q),
    .io_en(((T_5411 & T_5359[1]) & T_3858))
  );
  sirv_AsyncResetRegVec_67 u_iofEnReg (
    .clock(clock),
    .reset(reset),
    .io_d(io_in_0_a_bits_data),
    .io_q(iofEnReg_io_q),
    .io_en(((T_5411 & T_5359[14]) & T_3858))
  );
  assign io_interrupts_0_0 = ((((riseIpReg[0] & riseIeReg[0]) | (fallIpReg[0] & fallIeReg[0])) | (highIpReg[0] & highIeReg[0])) | (lowIpReg[0] & lowIeReg[0]));
  assign io_interrupts_0_1 = ((((riseIpReg[1] & riseIeReg[1]) | (fallIpReg[1] & fallIeReg[1])) | (highIpReg[1] & highIeReg[1])) | (lowIpReg[1] & lowIeReg[1]));
  assign io_interrupts_0_2 = ((((riseIpReg[2] & riseIeReg[2]) | (fallIpReg[2] & fallIeReg[2])) | (highIpReg[2] & highIeReg[2])) | (lowIpReg[2] & lowIeReg[2]));
  assign io_interrupts_0_3 = ((((riseIpReg[3] & riseIeReg[3]) | (fallIpReg[3] & fallIeReg[3])) | (highIpReg[3] & highIeReg[3])) | (lowIpReg[3] & lowIeReg[3]));
  assign io_interrupts_0_4 = ((((riseIpReg[4] & riseIeReg[4]) | (fallIpReg[4] & fallIeReg[4])) | (highIpReg[4] & highIeReg[4])) | (lowIpReg[4] & lowIeReg[4]));
  assign io_interrupts_0_5 = ((((riseIpReg[5] & riseIeReg[5]) | (fallIpReg[5] & fallIeReg[5])) | (highIpReg[5] & highIeReg[5])) | (lowIpReg[5] & lowIeReg[5]));
  assign io_interrupts_0_6 = ((((riseIpReg[6] & riseIeReg[6]) | (fallIpReg[6] & fallIeReg[6])) | (highIpReg[6] & highIeReg[6])) | (lowIpReg[6] & lowIeReg[6]));
  assign io_interrupts_0_7 = ((((riseIpReg[7] & riseIeReg[7]) | (fallIpReg[7] & fallIeReg[7])) | (highIpReg[7] & highIeReg[7])) | (lowIpReg[7] & lowIeReg[7]));
  assign io_interrupts_0_8 = ((((riseIpReg[8] & riseIeReg[8]) | (fallIpReg[8] & fallIeReg[8])) | (highIpReg[8] & highIeReg[8])) | (lowIpReg[8] & lowIeReg[8]));
  assign io_interrupts_0_9 = ((((riseIpReg[9] & riseIeReg[9]) | (fallIpReg[9] & fallIeReg[9])) | (highIpReg[9] & highIeReg[9])) | (lowIpReg[9] & lowIeReg[9]));
  assign io_interrupts_0_10 = ((((riseIpReg[10] & riseIeReg[10]) | (fallIpReg[10] & fallIeReg[10])) | (highIpReg[10] & highIeReg[10])) | (lowIpReg[10] & lowIeReg[10]));
  assign io_interrupts_0_11 = ((((riseIpReg[11] & riseIeReg[11]) | (fallIpReg[11] & fallIeReg[11])) | (highIpReg[11] & highIeReg[11])) | (lowIpReg[11] & lowIeReg[11]));
  assign io_interrupts_0_12 = ((((riseIpReg[12] & riseIeReg[12]) | (fallIpReg[12] & fallIeReg[12])) | (highIpReg[12] & highIeReg[12])) | (lowIpReg[12] & lowIeReg[12]));
  assign io_interrupts_0_13 = ((((riseIpReg[13] & riseIeReg[13]) | (fallIpReg[13] & fallIeReg[13])) | (highIpReg[13] & highIeReg[13])) | (lowIpReg[13] & lowIeReg[13]));
  assign io_interrupts_0_14 = ((((riseIpReg[14] & riseIeReg[14]) | (fallIpReg[14] & fallIeReg[14])) | (highIpReg[14] & highIeReg[14])) | (lowIpReg[14] & lowIeReg[14]));
  assign io_interrupts_0_15 = ((((riseIpReg[15] & riseIeReg[15]) | (fallIpReg[15] & fallIeReg[15])) | (highIpReg[15] & highIeReg[15])) | (lowIpReg[15] & lowIeReg[15]));
  assign io_interrupts_0_16 = ((((riseIpReg[16] & riseIeReg[16]) | (fallIpReg[16] & fallIeReg[16])) | (highIpReg[16] & highIeReg[16])) | (lowIpReg[16] & lowIeReg[16]));
  assign io_interrupts_0_17 = ((((riseIpReg[17] & riseIeReg[17]) | (fallIpReg[17] & fallIeReg[17])) | (highIpReg[17] & highIeReg[17])) | (lowIpReg[17] & lowIeReg[17]));
  assign io_interrupts_0_18 = ((((riseIpReg[18] & riseIeReg[18]) | (fallIpReg[18] & fallIeReg[18])) | (highIpReg[18] & highIeReg[18])) | (lowIpReg[18] & lowIeReg[18]));
  assign io_interrupts_0_19 = ((((riseIpReg[19] & riseIeReg[19]) | (fallIpReg[19] & fallIeReg[19])) | (highIpReg[19] & highIeReg[19])) | (lowIpReg[19] & lowIeReg[19]));
  assign io_interrupts_0_20 = ((((riseIpReg[20] & riseIeReg[20]) | (fallIpReg[20] & fallIeReg[20])) | (highIpReg[20] & highIeReg[20])) | (lowIpReg[20] & lowIeReg[20]));
  assign io_interrupts_0_21 = ((((riseIpReg[21] & riseIeReg[21]) | (fallIpReg[21] & fallIeReg[21])) | (highIpReg[21] & highIeReg[21])) | (lowIpReg[21] & lowIeReg[21]));
  assign io_interrupts_0_22 = ((((riseIpReg[22] & riseIeReg[22]) | (fallIpReg[22] & fallIeReg[22])) | (highIpReg[22] & highIeReg[22])) | (lowIpReg[22] & lowIeReg[22]));
  assign io_interrupts_0_23 = ((((riseIpReg[23] & riseIeReg[23]) | (fallIpReg[23] & fallIeReg[23])) | (highIpReg[23] & highIeReg[23])) | (lowIpReg[23] & lowIeReg[23]));
  assign io_interrupts_0_24 = ((((riseIpReg[24] & riseIeReg[24]) | (fallIpReg[24] & fallIeReg[24])) | (highIpReg[24] & highIeReg[24])) | (lowIpReg[24] & lowIeReg[24]));
  assign io_interrupts_0_25 = ((((riseIpReg[25] & riseIeReg[25]) | (fallIpReg[25] & fallIeReg[25])) | (highIpReg[25] & highIeReg[25])) | (lowIpReg[25] & lowIeReg[25]));
  assign io_interrupts_0_26 = ((((riseIpReg[26] & riseIeReg[26]) | (fallIpReg[26] & fallIeReg[26])) | (highIpReg[26] & highIeReg[26])) | (lowIpReg[26] & lowIeReg[26]));
  assign io_interrupts_0_27 = ((((riseIpReg[27] & riseIeReg[27]) | (fallIpReg[27] & fallIeReg[27])) | (highIpReg[27] & highIeReg[27])) | (lowIpReg[27] & lowIeReg[27]));
  assign io_interrupts_0_28 = ((((riseIpReg[28] & riseIeReg[28]) | (fallIpReg[28] & fallIeReg[28])) | (highIpReg[28] & highIeReg[28])) | (lowIpReg[28] & lowIeReg[28]));
  assign io_interrupts_0_29 = ((((riseIpReg[29] & riseIeReg[29]) | (fallIpReg[29] & fallIeReg[29])) | (highIpReg[29] & highIeReg[29])) | (lowIpReg[29] & lowIeReg[29]));
  assign io_interrupts_0_30 = ((((riseIpReg[30] & riseIeReg[30]) | (fallIpReg[30] & fallIeReg[30])) | (highIpReg[30] & highIeReg[30])) | (lowIpReg[30] & lowIeReg[30]));
  assign io_interrupts_0_31 = ((((riseIpReg[31] & riseIeReg[31]) | (fallIpReg[31] & fallIeReg[31])) | (highIpReg[31] & highIeReg[31])) | (lowIpReg[31] & lowIeReg[31]));
  assign io_in_0_a_ready = ((io_in_0_d_ready & T_5321) & T_5318);
  assign io_in_0_b_valid = 1'h0;
  assign io_in_0_b_bits_opcode = 3'b0;
  assign io_in_0_b_bits_param = 2'b0;
  assign io_in_0_b_bits_size = 3'b0;
  assign io_in_0_b_bits_source = 5'b0;
  assign io_in_0_b_bits_address = 29'b0;
  assign io_in_0_b_bits_mask = 4'b0;
  assign io_in_0_b_bits_data = 32'b0;
  assign io_in_0_c_ready = 1'h1;
  assign io_in_0_d_valid = (T_5323 & T_5321);
  assign io_in_0_d_bits_opcode = {{2'd0}, T_3312};
  assign io_in_0_d_bits_param = 2'h0;
  assign io_in_0_d_bits_size = T_3316[2:0];
  assign io_in_0_d_bits_source = T_3316[7:3];
  assign io_in_0_d_bits_sink = 1'h0;
  assign io_in_0_d_bits_addr_lo = T_3316[9:8];
  assign io_in_0_d_bits_data = ((5'h1f == T_5301 ? 1'h1 : (5'h1e == T_5301 ? 1'h1 : (5'h1d == T_5301 ? 1'h1 : (5'h1c == T_5301 ? 1'h1 : (5'h1b == T_5301 ? 1'h1 : (5'h1a == T_5301 ? 1'h1 : (5'h19 == T_5301 ? 1'h1 : (5'h18 == T_5301 ? 1'h1 : (5'h17 == T_5301 ? 1'h1 : (5'h16 == T_5301 ? 1'h1 : (5'h15 == T_5301 ? 1'h1 : (5'h14 == T_5301 ? 1'h1 : (5'h13 == T_5301 ? 1'h1 : (5'h12 == T_5301 ? 1'h1 : (5'h11 == T_5301 ? 1'h1 : (5'h10 == T_5301 ? T_3565 : (5'hf == T_5301 ? T_3601 : (5'he == T_5301 ? T_3484 : (5'hd == T_5301 ? T_3520 : (5'hc == T_5301 ? T_3538 : (5'hb == T_5301 ? T_3574 : (5'ha == T_5301 ? T_3475 : (5'h9 == T_5301 ? T_3511 : (5'h8 == T_5301 ? T_3583 : (5'h7 == T_5301 ? T_3547 : (5'h6 == T_5301 ? T_3502 : (5'h5 == T_5301 ? T_3466 : (5'h4 == T_5301 ? T_3592 : (5'h3 == T_5301 ? T_3556 : (5'h2 == T_5301 ? T_3529 : (5'h1 == T_5301 ? T_3493 : T_3457))))))))))))))))))))))))))))))) ? (5'h1f == T_5301 ? 32'h0 : (5'h1e == T_5301 ? 32'h0 : (5'h1d == T_5301 ? 32'h0 : (5'h1c == T_5301 ? 32'h0 : (5'h1b == T_5301 ? 32'h0 : (5'h1a == T_5301 ? 32'h0 : (5'h19 == T_5301 ? 32'h0 : (5'h18 == T_5301 ? 32'h0 : (5'h17 == T_5301 ? 32'h0 : (5'h16 == T_5301 ? 32'h0 : (5'h15 == T_5301 ? 32'h0 : (5'h14 == T_5301 ? 32'h0 : (5'h13 == T_5301 ? 32'h0 : (5'h12 == T_5301 ? 32'h0 : (5'h11 == T_5301 ? 32'h0 : (5'h10 == T_5301 ? xorReg : (5'hf == T_5301 ? iofSelReg : (5'he == T_5301 ? iofEnReg_io_q : (5'hd == T_5301 ? lowIpReg : (5'hc == T_5301 ? lowIeReg : (5'hb == T_5301 ? highIpReg : (5'ha == T_5301 ? highIeReg : (5'h9 == T_5301 ? fallIpReg : (5'h8 == T_5301 ? fallIeReg : (5'h7 == T_5301 ? riseIpReg : (5'h6 == T_5301 ? riseIeReg : (5'h5 == T_5301 ? dsReg : (5'h4 == T_5301 ? pueReg_io_q : (5'h3 == T_5301 ? portReg : (5'h2 == T_5301 ? oeReg_io_q : (5'h1 == T_5301 ? ieReg_io_q : valueReg))))))))))))))))))))))))))))))) : 32'h0);
  assign io_in_0_d_bits_error = 1'h0;
  assign io_in_0_e_ready = 1'h1;
  assign io_port_pins_0_o_oval = ((iofEnReg_io_q[0] ? (iofSelReg[0] ? (io_port_iof_1_0_o_valid ? io_port_iof_1_0_o_oval : portReg[0]) : (io_port_iof_0_0_o_valid ? io_port_iof_0_0_o_oval : portReg[0])) : portReg[0]) ^ xorReg[0]);
  assign io_port_pins_0_o_oe = (iofEnReg_io_q[0] ? (iofSelReg[0] ? (io_port_iof_1_0_o_valid ? io_port_iof_1_0_o_oe : oeReg_io_q[0]) : (io_port_iof_0_0_o_valid ? io_port_iof_0_0_o_oe : oeReg_io_q[0])) : oeReg_io_q[0]);
  assign io_port_pins_0_o_ie = (iofEnReg_io_q[0] ? (iofSelReg[0] ? (io_port_iof_1_0_o_valid ? io_port_iof_1_0_o_ie : ieReg_io_q[0]) : (io_port_iof_0_0_o_valid ? io_port_iof_0_0_o_ie : ieReg_io_q[0])) : ieReg_io_q[0]);
  assign io_port_pins_0_o_pue = (iofEnReg_io_q[0] ? pueReg_io_q[0] : pueReg_io_q[0]);
  assign io_port_pins_0_o_ds = (iofEnReg_io_q[0] ? dsReg[0] : dsReg[0]);
  assign io_port_pins_1_o_oval = ((iofEnReg_io_q[1] ? (iofSelReg[1] ? (io_port_iof_1_1_o_valid ? io_port_iof_1_1_o_oval : portReg[1]) : (io_port_iof_0_1_o_valid ? io_port_iof_0_1_o_oval : portReg[1])) : portReg[1]) ^ xorReg[1]);
  assign io_port_pins_1_o_oe = (iofEnReg_io_q[1] ? (iofSelReg[1] ? (io_port_iof_1_1_o_valid ? io_port_iof_1_1_o_oe : oeReg_io_q[1]) : (io_port_iof_0_1_o_valid ? io_port_iof_0_1_o_oe : oeReg_io_q[1])) : oeReg_io_q[1]);
  assign io_port_pins_1_o_ie = (iofEnReg_io_q[1] ? (iofSelReg[1] ? (io_port_iof_1_1_o_valid ? io_port_iof_1_1_o_ie : ieReg_io_q[1]) : (io_port_iof_0_1_o_valid ? io_port_iof_0_1_o_ie : ieReg_io_q[1])) : ieReg_io_q[1]);
  assign io_port_pins_1_o_pue = (iofEnReg_io_q[1] ? pueReg_io_q[1] : pueReg_io_q[1]);
  assign io_port_pins_1_o_ds = (iofEnReg_io_q[1] ? dsReg[1] : dsReg[1]);
  assign io_port_pins_2_o_oval = ((iofEnReg_io_q[2] ? (iofSelReg[2] ? (io_port_iof_1_2_o_valid ? io_port_iof_1_2_o_oval : portReg[2]) : (io_port_iof_0_2_o_valid ? io_port_iof_0_2_o_oval : portReg[2])) : portReg[2]) ^ xorReg[2]);
  assign io_port_pins_2_o_oe = (iofEnReg_io_q[2] ? (iofSelReg[2] ? (io_port_iof_1_2_o_valid ? io_port_iof_1_2_o_oe : oeReg_io_q[2]) : (io_port_iof_0_2_o_valid ? io_port_iof_0_2_o_oe : oeReg_io_q[2])) : oeReg_io_q[2]);
  assign io_port_pins_2_o_ie = (iofEnReg_io_q[2] ? (iofSelReg[2] ? (io_port_iof_1_2_o_valid ? io_port_iof_1_2_o_ie : ieReg_io_q[2]) : (io_port_iof_0_2_o_valid ? io_port_iof_0_2_o_ie : ieReg_io_q[2])) : ieReg_io_q[2]);
  assign io_port_pins_2_o_pue = (iofEnReg_io_q[2] ? pueReg_io_q[2] : pueReg_io_q[2]);
  assign io_port_pins_2_o_ds = (iofEnReg_io_q[2] ? dsReg[2] : dsReg[2]);
  assign io_port_pins_3_o_oval = ((iofEnReg_io_q[3] ? (iofSelReg[3] ? (io_port_iof_1_3_o_valid ? io_port_iof_1_3_o_oval : portReg[3]) : (io_port_iof_0_3_o_valid ? io_port_iof_0_3_o_oval : portReg[3])) : portReg[3]) ^ xorReg[3]);
  assign io_port_pins_3_o_oe = (iofEnReg_io_q[3] ? (iofSelReg[3] ? (io_port_iof_1_3_o_valid ? io_port_iof_1_3_o_oe : oeReg_io_q[3]) : (io_port_iof_0_3_o_valid ? io_port_iof_0_3_o_oe : oeReg_io_q[3])) : oeReg_io_q[3]);
  assign io_port_pins_3_o_ie = (iofEnReg_io_q[3] ? (iofSelReg[3] ? (io_port_iof_1_3_o_valid ? io_port_iof_1_3_o_ie : ieReg_io_q[3]) : (io_port_iof_0_3_o_valid ? io_port_iof_0_3_o_ie : ieReg_io_q[3])) : ieReg_io_q[3]);
  assign io_port_pins_3_o_pue = (iofEnReg_io_q[3] ? pueReg_io_q[3] : pueReg_io_q[3]);
  assign io_port_pins_3_o_ds = (iofEnReg_io_q[3] ? dsReg[3] : dsReg[3]);
  assign io_port_pins_4_o_oval = ((iofEnReg_io_q[4] ? (iofSelReg[4] ? (io_port_iof_1_4_o_valid ? io_port_iof_1_4_o_oval : portReg[4]) : (io_port_iof_0_4_o_valid ? io_port_iof_0_4_o_oval : portReg[4])) : portReg[4]) ^ xorReg[4]);
  assign io_port_pins_4_o_oe = (iofEnReg_io_q[4] ? (iofSelReg[4] ? (io_port_iof_1_4_o_valid ? io_port_iof_1_4_o_oe : oeReg_io_q[4]) : (io_port_iof_0_4_o_valid ? io_port_iof_0_4_o_oe : oeReg_io_q[4])) : oeReg_io_q[4]);
  assign io_port_pins_4_o_ie = (iofEnReg_io_q[4] ? (iofSelReg[4] ? (io_port_iof_1_4_o_valid ? io_port_iof_1_4_o_ie : ieReg_io_q[4]) : (io_port_iof_0_4_o_valid ? io_port_iof_0_4_o_ie : ieReg_io_q[4])) : ieReg_io_q[4]);
  assign io_port_pins_4_o_pue = (iofEnReg_io_q[4] ? pueReg_io_q[4] : pueReg_io_q[4]);
  assign io_port_pins_4_o_ds = (iofEnReg_io_q[4] ? dsReg[4] : dsReg[4]);
  assign io_port_pins_5_o_oval = ((iofEnReg_io_q[5] ? (iofSelReg[5] ? (io_port_iof_1_5_o_valid ? io_port_iof_1_5_o_oval : portReg[5]) : (io_port_iof_0_5_o_valid ? io_port_iof_0_5_o_oval : portReg[5])) : portReg[5]) ^ xorReg[5]);
  assign io_port_pins_5_o_oe = (iofEnReg_io_q[5] ? (iofSelReg[5] ? (io_port_iof_1_5_o_valid ? io_port_iof_1_5_o_oe : oeReg_io_q[5]) : (io_port_iof_0_5_o_valid ? io_port_iof_0_5_o_oe : oeReg_io_q[5])) : oeReg_io_q[5]);
  assign io_port_pins_5_o_ie = (iofEnReg_io_q[5] ? (iofSelReg[5] ? (io_port_iof_1_5_o_valid ? io_port_iof_1_5_o_ie : ieReg_io_q[5]) : (io_port_iof_0_5_o_valid ? io_port_iof_0_5_o_ie : ieReg_io_q[5])) : ieReg_io_q[5]);
  assign io_port_pins_5_o_pue = (iofEnReg_io_q[5] ? pueReg_io_q[5] : pueReg_io_q[5]);
  assign io_port_pins_5_o_ds = (iofEnReg_io_q[5] ? dsReg[5] : dsReg[5]);
  assign io_port_pins_6_o_oval = ((iofEnReg_io_q[6] ? (iofSelReg[6] ? (io_port_iof_1_6_o_valid ? io_port_iof_1_6_o_oval : portReg[6]) : (io_port_iof_0_6_o_valid ? io_port_iof_0_6_o_oval : portReg[6])) : portReg[6]) ^ xorReg[6]);
  assign io_port_pins_6_o_oe = (iofEnReg_io_q[6] ? (iofSelReg[6] ? (io_port_iof_1_6_o_valid ? io_port_iof_1_6_o_oe : oeReg_io_q[6]) : (io_port_iof_0_6_o_valid ? io_port_iof_0_6_o_oe : oeReg_io_q[6])) : oeReg_io_q[6]);
  assign io_port_pins_6_o_ie = (iofEnReg_io_q[6] ? (iofSelReg[6] ? (io_port_iof_1_6_o_valid ? io_port_iof_1_6_o_ie : ieReg_io_q[6]) : (io_port_iof_0_6_o_valid ? io_port_iof_0_6_o_ie : ieReg_io_q[6])) : ieReg_io_q[6]);
  assign io_port_pins_6_o_pue = (iofEnReg_io_q[6] ? pueReg_io_q[6] : pueReg_io_q[6]);
  assign io_port_pins_6_o_ds = (iofEnReg_io_q[6] ? dsReg[6] : dsReg[6]);
  assign io_port_pins_7_o_oval = ((iofEnReg_io_q[7] ? (iofSelReg[7] ? (io_port_iof_1_7_o_valid ? io_port_iof_1_7_o_oval : portReg[7]) : (io_port_iof_0_7_o_valid ? io_port_iof_0_7_o_oval : portReg[7])) : portReg[7]) ^ xorReg[7]);
  assign io_port_pins_7_o_oe = (iofEnReg_io_q[7] ? (iofSelReg[7] ? (io_port_iof_1_7_o_valid ? io_port_iof_1_7_o_oe : oeReg_io_q[7]) : (io_port_iof_0_7_o_valid ? io_port_iof_0_7_o_oe : oeReg_io_q[7])) : oeReg_io_q[7]);
  assign io_port_pins_7_o_ie = (iofEnReg_io_q[7] ? (iofSelReg[7] ? (io_port_iof_1_7_o_valid ? io_port_iof_1_7_o_ie : ieReg_io_q[7]) : (io_port_iof_0_7_o_valid ? io_port_iof_0_7_o_ie : ieReg_io_q[7])) : ieReg_io_q[7]);
  assign io_port_pins_7_o_pue = (iofEnReg_io_q[7] ? pueReg_io_q[7] : pueReg_io_q[7]);
  assign io_port_pins_7_o_ds = (iofEnReg_io_q[7] ? dsReg[7] : dsReg[7]);
  assign io_port_pins_8_o_oval = ((iofEnReg_io_q[8] ? (iofSelReg[8] ? (io_port_iof_1_8_o_valid ? io_port_iof_1_8_o_oval : portReg[8]) : (io_port_iof_0_8_o_valid ? io_port_iof_0_8_o_oval : portReg[8])) : portReg[8]) ^ xorReg[8]);
  assign io_port_pins_8_o_oe = (iofEnReg_io_q[8] ? (iofSelReg[8] ? (io_port_iof_1_8_o_valid ? io_port_iof_1_8_o_oe : oeReg_io_q[8]) : (io_port_iof_0_8_o_valid ? io_port_iof_0_8_o_oe : oeReg_io_q[8])) : oeReg_io_q[8]);
  assign io_port_pins_8_o_ie = (iofEnReg_io_q[8] ? (iofSelReg[8] ? (io_port_iof_1_8_o_valid ? io_port_iof_1_8_o_ie : ieReg_io_q[8]) : (io_port_iof_0_8_o_valid ? io_port_iof_0_8_o_ie : ieReg_io_q[8])) : ieReg_io_q[8]);
  assign io_port_pins_8_o_pue = (iofEnReg_io_q[8] ? pueReg_io_q[8] : pueReg_io_q[8]);
  assign io_port_pins_8_o_ds = (iofEnReg_io_q[8] ? dsReg[8] : dsReg[8]);
  assign io_port_pins_9_o_oval = ((iofEnReg_io_q[9] ? (iofSelReg[9] ? (io_port_iof_1_9_o_valid ? io_port_iof_1_9_o_oval : portReg[9]) : (io_port_iof_0_9_o_valid ? io_port_iof_0_9_o_oval : portReg[9])) : portReg[9]) ^ xorReg[9]);
  assign io_port_pins_9_o_oe = (iofEnReg_io_q[9] ? (iofSelReg[9] ? (io_port_iof_1_9_o_valid ? io_port_iof_1_9_o_oe : oeReg_io_q[9]) : (io_port_iof_0_9_o_valid ? io_port_iof_0_9_o_oe : oeReg_io_q[9])) : oeReg_io_q[9]);
  assign io_port_pins_9_o_ie = (iofEnReg_io_q[9] ? (iofSelReg[9] ? (io_port_iof_1_9_o_valid ? io_port_iof_1_9_o_ie : ieReg_io_q[9]) : (io_port_iof_0_9_o_valid ? io_port_iof_0_9_o_ie : ieReg_io_q[9])) : ieReg_io_q[9]);
  assign io_port_pins_9_o_pue = (iofEnReg_io_q[9] ? pueReg_io_q[9] : pueReg_io_q[9]);
  assign io_port_pins_9_o_ds = (iofEnReg_io_q[9] ? dsReg[9] : dsReg[9]);
  assign io_port_pins_10_o_oval = ((iofEnReg_io_q[10] ? (iofSelReg[10] ? (io_port_iof_1_10_o_valid ? io_port_iof_1_10_o_oval : portReg[10]) : (io_port_iof_0_10_o_valid ? io_port_iof_0_10_o_oval : portReg[10])) : portReg[10]) ^ xorReg[10]);
  assign io_port_pins_10_o_oe = (iofEnReg_io_q[10] ? (iofSelReg[10] ? (io_port_iof_1_10_o_valid ? io_port_iof_1_10_o_oe : oeReg_io_q[10]) : (io_port_iof_0_10_o_valid ? io_port_iof_0_10_o_oe : oeReg_io_q[10])) : oeReg_io_q[10]);
  assign io_port_pins_10_o_ie = (iofEnReg_io_q[10] ? (iofSelReg[10] ? (io_port_iof_1_10_o_valid ? io_port_iof_1_10_o_ie : ieReg_io_q[10]) : (io_port_iof_0_10_o_valid ? io_port_iof_0_10_o_ie : ieReg_io_q[10])) : ieReg_io_q[10]);
  assign io_port_pins_10_o_pue = (iofEnReg_io_q[10] ? pueReg_io_q[10] : pueReg_io_q[10]);
  assign io_port_pins_10_o_ds = (iofEnReg_io_q[10] ? dsReg[10] : dsReg[10]);
  assign io_port_pins_11_o_oval = ((iofEnReg_io_q[11] ? (iofSelReg[11] ? (io_port_iof_1_11_o_valid ? io_port_iof_1_11_o_oval : portReg[11]) : (io_port_iof_0_11_o_valid ? io_port_iof_0_11_o_oval : portReg[11])) : portReg[11]) ^ xorReg[11]);
  assign io_port_pins_11_o_oe = (iofEnReg_io_q[11] ? (iofSelReg[11] ? (io_port_iof_1_11_o_valid ? io_port_iof_1_11_o_oe : oeReg_io_q[11]) : (io_port_iof_0_11_o_valid ? io_port_iof_0_11_o_oe : oeReg_io_q[11])) : oeReg_io_q[11]);
  assign io_port_pins_11_o_ie = (iofEnReg_io_q[11] ? (iofSelReg[11] ? (io_port_iof_1_11_o_valid ? io_port_iof_1_11_o_ie : ieReg_io_q[11]) : (io_port_iof_0_11_o_valid ? io_port_iof_0_11_o_ie : ieReg_io_q[11])) : ieReg_io_q[11]);
  assign io_port_pins_11_o_pue = (iofEnReg_io_q[11] ? pueReg_io_q[11] : pueReg_io_q[11]);
  assign io_port_pins_11_o_ds = (iofEnReg_io_q[11] ? dsReg[11] : dsReg[11]);
  assign io_port_pins_12_o_oval = ((iofEnReg_io_q[12] ? (iofSelReg[12] ? (io_port_iof_1_12_o_valid ? io_port_iof_1_12_o_oval : portReg[12]) : (io_port_iof_0_12_o_valid ? io_port_iof_0_12_o_oval : portReg[12])) : portReg[12]) ^ xorReg[12]);
  assign io_port_pins_12_o_oe = (iofEnReg_io_q[12] ? (iofSelReg[12] ? (io_port_iof_1_12_o_valid ? io_port_iof_1_12_o_oe : oeReg_io_q[12]) : (io_port_iof_0_12_o_valid ? io_port_iof_0_12_o_oe : oeReg_io_q[12])) : oeReg_io_q[12]);
  assign io_port_pins_12_o_ie = (iofEnReg_io_q[12] ? (iofSelReg[12] ? (io_port_iof_1_12_o_valid ? io_port_iof_1_12_o_ie : ieReg_io_q[12]) : (io_port_iof_0_12_o_valid ? io_port_iof_0_12_o_ie : ieReg_io_q[12])) : ieReg_io_q[12]);
  assign io_port_pins_12_o_pue = (iofEnReg_io_q[12] ? pueReg_io_q[12] : pueReg_io_q[12]);
  assign io_port_pins_12_o_ds = (iofEnReg_io_q[12] ? dsReg[12] : dsReg[12]);
  assign io_port_pins_13_o_oval = ((iofEnReg_io_q[13] ? (iofSelReg[13] ? (io_port_iof_1_13_o_valid ? io_port_iof_1_13_o_oval : portReg[13]) : (io_port_iof_0_13_o_valid ? io_port_iof_0_13_o_oval : portReg[13])) : portReg[13]) ^ xorReg[13]);
  assign io_port_pins_13_o_oe = (iofEnReg_io_q[13] ? (iofSelReg[13] ? (io_port_iof_1_13_o_valid ? io_port_iof_1_13_o_oe : oeReg_io_q[13]) : (io_port_iof_0_13_o_valid ? io_port_iof_0_13_o_oe : oeReg_io_q[13])) : oeReg_io_q[13]);
  assign io_port_pins_13_o_ie = (iofEnReg_io_q[13] ? (iofSelReg[13] ? (io_port_iof_1_13_o_valid ? io_port_iof_1_13_o_ie : ieReg_io_q[13]) : (io_port_iof_0_13_o_valid ? io_port_iof_0_13_o_ie : ieReg_io_q[13])) : ieReg_io_q[13]);
  assign io_port_pins_13_o_pue = (iofEnReg_io_q[13] ? pueReg_io_q[13] : pueReg_io_q[13]);
  assign io_port_pins_13_o_ds = (iofEnReg_io_q[13] ? dsReg[13] : dsReg[13]);
  assign io_port_pins_14_o_oval = ((iofEnReg_io_q[14] ? (iofSelReg[14] ? (io_port_iof_1_14_o_valid ? io_port_iof_1_14_o_oval : portReg[14]) : (io_port_iof_0_14_o_valid ? io_port_iof_0_14_o_oval : portReg[14])) : portReg[14]) ^ xorReg[14]);
  assign io_port_pins_14_o_oe = (iofEnReg_io_q[14] ? (iofSelReg[14] ? (io_port_iof_1_14_o_valid ? io_port_iof_1_14_o_oe : oeReg_io_q[14]) : (io_port_iof_0_14_o_valid ? io_port_iof_0_14_o_oe : oeReg_io_q[14])) : oeReg_io_q[14]);
  assign io_port_pins_14_o_ie = (iofEnReg_io_q[14] ? (iofSelReg[14] ? (io_port_iof_1_14_o_valid ? io_port_iof_1_14_o_ie : ieReg_io_q[14]) : (io_port_iof_0_14_o_valid ? io_port_iof_0_14_o_ie : ieReg_io_q[14])) : ieReg_io_q[14]);
  assign io_port_pins_14_o_pue = (iofEnReg_io_q[14] ? pueReg_io_q[14] : pueReg_io_q[14]);
  assign io_port_pins_14_o_ds = (iofEnReg_io_q[14] ? dsReg[14] : dsReg[14]);
  assign io_port_pins_15_o_oval = ((iofEnReg_io_q[15] ? (iofSelReg[15] ? (io_port_iof_1_15_o_valid ? io_port_iof_1_15_o_oval : portReg[15]) : (io_port_iof_0_15_o_valid ? io_port_iof_0_15_o_oval : portReg[15])) : portReg[15]) ^ xorReg[15]);
  assign io_port_pins_15_o_oe = (iofEnReg_io_q[15] ? (iofSelReg[15] ? (io_port_iof_1_15_o_valid ? io_port_iof_1_15_o_oe : oeReg_io_q[15]) : (io_port_iof_0_15_o_valid ? io_port_iof_0_15_o_oe : oeReg_io_q[15])) : oeReg_io_q[15]);
  assign io_port_pins_15_o_ie = (iofEnReg_io_q[15] ? (iofSelReg[15] ? (io_port_iof_1_15_o_valid ? io_port_iof_1_15_o_ie : ieReg_io_q[15]) : (io_port_iof_0_15_o_valid ? io_port_iof_0_15_o_ie : ieReg_io_q[15])) : ieReg_io_q[15]);
  assign io_port_pins_15_o_pue = (iofEnReg_io_q[15] ? pueReg_io_q[15] : pueReg_io_q[15]);
  assign io_port_pins_15_o_ds = (iofEnReg_io_q[15] ? dsReg[15] : dsReg[15]);
  assign io_port_pins_16_o_oval = ((iofEnReg_io_q[16] ? (iofSelReg[16] ? (io_port_iof_1_16_o_valid ? io_port_iof_1_16_o_oval : portReg[16]) : (io_port_iof_0_16_o_valid ? io_port_iof_0_16_o_oval : portReg[16])) : portReg[16]) ^ xorReg[16]);
  assign io_port_pins_16_o_oe = (iofEnReg_io_q[16] ? (iofSelReg[16] ? (io_port_iof_1_16_o_valid ? io_port_iof_1_16_o_oe : oeReg_io_q[16]) : (io_port_iof_0_16_o_valid ? io_port_iof_0_16_o_oe : oeReg_io_q[16])) : oeReg_io_q[16]);
  assign io_port_pins_16_o_ie = (iofEnReg_io_q[16] ? (iofSelReg[16] ? (io_port_iof_1_16_o_valid ? io_port_iof_1_16_o_ie : ieReg_io_q[16]) : (io_port_iof_0_16_o_valid ? io_port_iof_0_16_o_ie : ieReg_io_q[16])) : ieReg_io_q[16]);
  assign io_port_pins_16_o_pue = (iofEnReg_io_q[16] ? pueReg_io_q[16] : pueReg_io_q[16]);
  assign io_port_pins_16_o_ds = (iofEnReg_io_q[16] ? dsReg[16] : dsReg[16]);
  assign io_port_pins_17_o_oval = ((iofEnReg_io_q[17] ? (iofSelReg[17] ? (io_port_iof_1_17_o_valid ? io_port_iof_1_17_o_oval : portReg[17]) : (io_port_iof_0_17_o_valid ? io_port_iof_0_17_o_oval : portReg[17])) : portReg[17]) ^ xorReg[17]);
  assign io_port_pins_17_o_oe = (iofEnReg_io_q[17] ? (iofSelReg[17] ? (io_port_iof_1_17_o_valid ? io_port_iof_1_17_o_oe : oeReg_io_q[17]) : (io_port_iof_0_17_o_valid ? io_port_iof_0_17_o_oe : oeReg_io_q[17])) : oeReg_io_q[17]);
  assign io_port_pins_17_o_ie = (iofEnReg_io_q[17] ? (iofSelReg[17] ? (io_port_iof_1_17_o_valid ? io_port_iof_1_17_o_ie : ieReg_io_q[17]) : (io_port_iof_0_17_o_valid ? io_port_iof_0_17_o_ie : ieReg_io_q[17])) : ieReg_io_q[17]);
  assign io_port_pins_17_o_pue = (iofEnReg_io_q[17] ? pueReg_io_q[17] : pueReg_io_q[17]);
  assign io_port_pins_17_o_ds = (iofEnReg_io_q[17] ? dsReg[17] : dsReg[17]);
  assign io_port_pins_18_o_oval = ((iofEnReg_io_q[18] ? (iofSelReg[18] ? (io_port_iof_1_18_o_valid ? io_port_iof_1_18_o_oval : portReg[18]) : (io_port_iof_0_18_o_valid ? io_port_iof_0_18_o_oval : portReg[18])) : portReg[18]) ^ xorReg[18]);
  assign io_port_pins_18_o_oe = (iofEnReg_io_q[18] ? (iofSelReg[18] ? (io_port_iof_1_18_o_valid ? io_port_iof_1_18_o_oe : oeReg_io_q[18]) : (io_port_iof_0_18_o_valid ? io_port_iof_0_18_o_oe : oeReg_io_q[18])) : oeReg_io_q[18]);
  assign io_port_pins_18_o_ie = (iofEnReg_io_q[18] ? (iofSelReg[18] ? (io_port_iof_1_18_o_valid ? io_port_iof_1_18_o_ie : ieReg_io_q[18]) : (io_port_iof_0_18_o_valid ? io_port_iof_0_18_o_ie : ieReg_io_q[18])) : ieReg_io_q[18]);
  assign io_port_pins_18_o_pue = (iofEnReg_io_q[18] ? pueReg_io_q[18] : pueReg_io_q[18]);
  assign io_port_pins_18_o_ds = (iofEnReg_io_q[18] ? dsReg[18] : dsReg[18]);
  assign io_port_pins_19_o_oval = ((iofEnReg_io_q[19] ? (iofSelReg[19] ? (io_port_iof_1_19_o_valid ? io_port_iof_1_19_o_oval : portReg[19]) : (io_port_iof_0_19_o_valid ? io_port_iof_0_19_o_oval : portReg[19])) : portReg[19]) ^ xorReg[19]);
  assign io_port_pins_19_o_oe = (iofEnReg_io_q[19] ? (iofSelReg[19] ? (io_port_iof_1_19_o_valid ? io_port_iof_1_19_o_oe : oeReg_io_q[19]) : (io_port_iof_0_19_o_valid ? io_port_iof_0_19_o_oe : oeReg_io_q[19])) : oeReg_io_q[19]);
  assign io_port_pins_19_o_ie = (iofEnReg_io_q[19] ? (iofSelReg[19] ? (io_port_iof_1_19_o_valid ? io_port_iof_1_19_o_ie : ieReg_io_q[19]) : (io_port_iof_0_19_o_valid ? io_port_iof_0_19_o_ie : ieReg_io_q[19])) : ieReg_io_q[19]);
  assign io_port_pins_19_o_pue = (iofEnReg_io_q[19] ? pueReg_io_q[19] : pueReg_io_q[19]);
  assign io_port_pins_19_o_ds = (iofEnReg_io_q[19] ? dsReg[19] : dsReg[19]);
  assign io_port_pins_20_o_oval = ((iofEnReg_io_q[20] ? (iofSelReg[20] ? (io_port_iof_1_20_o_valid ? io_port_iof_1_20_o_oval : portReg[20]) : (io_port_iof_0_20_o_valid ? io_port_iof_0_20_o_oval : portReg[20])) : portReg[20]) ^ xorReg[20]);
  assign io_port_pins_20_o_oe = (iofEnReg_io_q[20] ? (iofSelReg[20] ? (io_port_iof_1_20_o_valid ? io_port_iof_1_20_o_oe : oeReg_io_q[20]) : (io_port_iof_0_20_o_valid ? io_port_iof_0_20_o_oe : oeReg_io_q[20])) : oeReg_io_q[20]);
  assign io_port_pins_20_o_ie = (iofEnReg_io_q[20] ? (iofSelReg[20] ? (io_port_iof_1_20_o_valid ? io_port_iof_1_20_o_ie : ieReg_io_q[20]) : (io_port_iof_0_20_o_valid ? io_port_iof_0_20_o_ie : ieReg_io_q[20])) : ieReg_io_q[20]);
  assign io_port_pins_20_o_pue = (iofEnReg_io_q[20] ? pueReg_io_q[20] : pueReg_io_q[20]);
  assign io_port_pins_20_o_ds = (iofEnReg_io_q[20] ? dsReg[20] : dsReg[20]);
  assign io_port_pins_21_o_oval = ((iofEnReg_io_q[21] ? (iofSelReg[21] ? (io_port_iof_1_21_o_valid ? io_port_iof_1_21_o_oval : portReg[21]) : (io_port_iof_0_21_o_valid ? io_port_iof_0_21_o_oval : portReg[21])) : portReg[21]) ^ xorReg[21]);
  assign io_port_pins_21_o_oe = (iofEnReg_io_q[21] ? (iofSelReg[21] ? (io_port_iof_1_21_o_valid ? io_port_iof_1_21_o_oe : oeReg_io_q[21]) : (io_port_iof_0_21_o_valid ? io_port_iof_0_21_o_oe : oeReg_io_q[21])) : oeReg_io_q[21]);
  assign io_port_pins_21_o_ie = (iofEnReg_io_q[21] ? (iofSelReg[21] ? (io_port_iof_1_21_o_valid ? io_port_iof_1_21_o_ie : ieReg_io_q[21]) : (io_port_iof_0_21_o_valid ? io_port_iof_0_21_o_ie : ieReg_io_q[21])) : ieReg_io_q[21]);
  assign io_port_pins_21_o_pue = (iofEnReg_io_q[21] ? pueReg_io_q[21] : pueReg_io_q[21]);
  assign io_port_pins_21_o_ds = (iofEnReg_io_q[21] ? dsReg[21] : dsReg[21]);
  assign io_port_pins_22_o_oval = ((iofEnReg_io_q[22] ? (iofSelReg[22] ? (io_port_iof_1_22_o_valid ? io_port_iof_1_22_o_oval : portReg[22]) : (io_port_iof_0_22_o_valid ? io_port_iof_0_22_o_oval : portReg[22])) : portReg[22]) ^ xorReg[22]);
  assign io_port_pins_22_o_oe = (iofEnReg_io_q[22] ? (iofSelReg[22] ? (io_port_iof_1_22_o_valid ? io_port_iof_1_22_o_oe : oeReg_io_q[22]) : (io_port_iof_0_22_o_valid ? io_port_iof_0_22_o_oe : oeReg_io_q[22])) : oeReg_io_q[22]);
  assign io_port_pins_22_o_ie = (iofEnReg_io_q[22] ? (iofSelReg[22] ? (io_port_iof_1_22_o_valid ? io_port_iof_1_22_o_ie : ieReg_io_q[22]) : (io_port_iof_0_22_o_valid ? io_port_iof_0_22_o_ie : ieReg_io_q[22])) : ieReg_io_q[22]);
  assign io_port_pins_22_o_pue = (iofEnReg_io_q[22] ? pueReg_io_q[22] : pueReg_io_q[22]);
  assign io_port_pins_22_o_ds = (iofEnReg_io_q[22] ? dsReg[22] : dsReg[22]);
  assign io_port_pins_23_o_oval = ((iofEnReg_io_q[23] ? (iofSelReg[23] ? (io_port_iof_1_23_o_valid ? io_port_iof_1_23_o_oval : portReg[23]) : (io_port_iof_0_23_o_valid ? io_port_iof_0_23_o_oval : portReg[23])) : portReg[23]) ^ xorReg[23]);
  assign io_port_pins_23_o_oe = (iofEnReg_io_q[23] ? (iofSelReg[23] ? (io_port_iof_1_23_o_valid ? io_port_iof_1_23_o_oe : oeReg_io_q[23]) : (io_port_iof_0_23_o_valid ? io_port_iof_0_23_o_oe : oeReg_io_q[23])) : oeReg_io_q[23]);
  assign io_port_pins_23_o_ie = (iofEnReg_io_q[23] ? (iofSelReg[23] ? (io_port_iof_1_23_o_valid ? io_port_iof_1_23_o_ie : ieReg_io_q[23]) : (io_port_iof_0_23_o_valid ? io_port_iof_0_23_o_ie : ieReg_io_q[23])) : ieReg_io_q[23]);
  assign io_port_pins_23_o_pue = (iofEnReg_io_q[23] ? pueReg_io_q[23] : pueReg_io_q[23]);
  assign io_port_pins_23_o_ds = (iofEnReg_io_q[23] ? dsReg[23] : dsReg[23]);
  assign io_port_pins_24_o_oval = ((iofEnReg_io_q[24] ? (iofSelReg[24] ? (io_port_iof_1_24_o_valid ? io_port_iof_1_24_o_oval : portReg[24]) : (io_port_iof_0_24_o_valid ? io_port_iof_0_24_o_oval : portReg[24])) : portReg[24]) ^ xorReg[24]);
  assign io_port_pins_24_o_oe = (iofEnReg_io_q[24] ? (iofSelReg[24] ? (io_port_iof_1_24_o_valid ? io_port_iof_1_24_o_oe : oeReg_io_q[24]) : (io_port_iof_0_24_o_valid ? io_port_iof_0_24_o_oe : oeReg_io_q[24])) : oeReg_io_q[24]);
  assign io_port_pins_24_o_ie = (iofEnReg_io_q[24] ? (iofSelReg[24] ? (io_port_iof_1_24_o_valid ? io_port_iof_1_24_o_ie : ieReg_io_q[24]) : (io_port_iof_0_24_o_valid ? io_port_iof_0_24_o_ie : ieReg_io_q[24])) : ieReg_io_q[24]);
  assign io_port_pins_24_o_pue = (iofEnReg_io_q[24] ? pueReg_io_q[24] : pueReg_io_q[24]);
  assign io_port_pins_24_o_ds = (iofEnReg_io_q[24] ? dsReg[24] : dsReg[24]);
  assign io_port_pins_25_o_oval = ((iofEnReg_io_q[25] ? (iofSelReg[25] ? (io_port_iof_1_25_o_valid ? io_port_iof_1_25_o_oval : portReg[25]) : (io_port_iof_0_25_o_valid ? io_port_iof_0_25_o_oval : portReg[25])) : portReg[25]) ^ xorReg[25]);
  assign io_port_pins_25_o_oe = (iofEnReg_io_q[25] ? (iofSelReg[25] ? (io_port_iof_1_25_o_valid ? io_port_iof_1_25_o_oe : oeReg_io_q[25]) : (io_port_iof_0_25_o_valid ? io_port_iof_0_25_o_oe : oeReg_io_q[25])) : oeReg_io_q[25]);
  assign io_port_pins_25_o_ie = (iofEnReg_io_q[25] ? (iofSelReg[25] ? (io_port_iof_1_25_o_valid ? io_port_iof_1_25_o_ie : ieReg_io_q[25]) : (io_port_iof_0_25_o_valid ? io_port_iof_0_25_o_ie : ieReg_io_q[25])) : ieReg_io_q[25]);
  assign io_port_pins_25_o_pue = (iofEnReg_io_q[25] ? pueReg_io_q[25] : pueReg_io_q[25]);
  assign io_port_pins_25_o_ds = (iofEnReg_io_q[25] ? dsReg[25] : dsReg[25]);
  assign io_port_pins_26_o_oval = ((iofEnReg_io_q[26] ? (iofSelReg[26] ? (io_port_iof_1_26_o_valid ? io_port_iof_1_26_o_oval : portReg[26]) : (io_port_iof_0_26_o_valid ? io_port_iof_0_26_o_oval : portReg[26])) : portReg[26]) ^ xorReg[26]);
  assign io_port_pins_26_o_oe = (iofEnReg_io_q[26] ? (iofSelReg[26] ? (io_port_iof_1_26_o_valid ? io_port_iof_1_26_o_oe : oeReg_io_q[26]) : (io_port_iof_0_26_o_valid ? io_port_iof_0_26_o_oe : oeReg_io_q[26])) : oeReg_io_q[26]);
  assign io_port_pins_26_o_ie = (iofEnReg_io_q[26] ? (iofSelReg[26] ? (io_port_iof_1_26_o_valid ? io_port_iof_1_26_o_ie : ieReg_io_q[26]) : (io_port_iof_0_26_o_valid ? io_port_iof_0_26_o_ie : ieReg_io_q[26])) : ieReg_io_q[26]);
  assign io_port_pins_26_o_pue = (iofEnReg_io_q[26] ? pueReg_io_q[26] : pueReg_io_q[26]);
  assign io_port_pins_26_o_ds = (iofEnReg_io_q[26] ? dsReg[26] : dsReg[26]);
  assign io_port_pins_27_o_oval = ((iofEnReg_io_q[27] ? (iofSelReg[27] ? (io_port_iof_1_27_o_valid ? io_port_iof_1_27_o_oval : portReg[27]) : (io_port_iof_0_27_o_valid ? io_port_iof_0_27_o_oval : portReg[27])) : portReg[27]) ^ xorReg[27]);
  assign io_port_pins_27_o_oe = (iofEnReg_io_q[27] ? (iofSelReg[27] ? (io_port_iof_1_27_o_valid ? io_port_iof_1_27_o_oe : oeReg_io_q[27]) : (io_port_iof_0_27_o_valid ? io_port_iof_0_27_o_oe : oeReg_io_q[27])) : oeReg_io_q[27]);
  assign io_port_pins_27_o_ie = (iofEnReg_io_q[27] ? (iofSelReg[27] ? (io_port_iof_1_27_o_valid ? io_port_iof_1_27_o_ie : ieReg_io_q[27]) : (io_port_iof_0_27_o_valid ? io_port_iof_0_27_o_ie : ieReg_io_q[27])) : ieReg_io_q[27]);
  assign io_port_pins_27_o_pue = (iofEnReg_io_q[27] ? pueReg_io_q[27] : pueReg_io_q[27]);
  assign io_port_pins_27_o_ds = (iofEnReg_io_q[27] ? dsReg[27] : dsReg[27]);
  assign io_port_pins_28_o_oval = ((iofEnReg_io_q[28] ? (iofSelReg[28] ? (io_port_iof_1_28_o_valid ? io_port_iof_1_28_o_oval : portReg[28]) : (io_port_iof_0_28_o_valid ? io_port_iof_0_28_o_oval : portReg[28])) : portReg[28]) ^ xorReg[28]);
  assign io_port_pins_28_o_oe = (iofEnReg_io_q[28] ? (iofSelReg[28] ? (io_port_iof_1_28_o_valid ? io_port_iof_1_28_o_oe : oeReg_io_q[28]) : (io_port_iof_0_28_o_valid ? io_port_iof_0_28_o_oe : oeReg_io_q[28])) : oeReg_io_q[28]);
  assign io_port_pins_28_o_ie = (iofEnReg_io_q[28] ? (iofSelReg[28] ? (io_port_iof_1_28_o_valid ? io_port_iof_1_28_o_ie : ieReg_io_q[28]) : (io_port_iof_0_28_o_valid ? io_port_iof_0_28_o_ie : ieReg_io_q[28])) : ieReg_io_q[28]);
  assign io_port_pins_28_o_pue = (iofEnReg_io_q[28] ? pueReg_io_q[28] : pueReg_io_q[28]);
  assign io_port_pins_28_o_ds = (iofEnReg_io_q[28] ? dsReg[28] : dsReg[28]);
  assign io_port_pins_29_o_oval = ((iofEnReg_io_q[29] ? (iofSelReg[29] ? (io_port_iof_1_29_o_valid ? io_port_iof_1_29_o_oval : portReg[29]) : (io_port_iof_0_29_o_valid ? io_port_iof_0_29_o_oval : portReg[29])) : portReg[29]) ^ xorReg[29]);
  assign io_port_pins_29_o_oe = (iofEnReg_io_q[29] ? (iofSelReg[29] ? (io_port_iof_1_29_o_valid ? io_port_iof_1_29_o_oe : oeReg_io_q[29]) : (io_port_iof_0_29_o_valid ? io_port_iof_0_29_o_oe : oeReg_io_q[29])) : oeReg_io_q[29]);
  assign io_port_pins_29_o_ie = (iofEnReg_io_q[29] ? (iofSelReg[29] ? (io_port_iof_1_29_o_valid ? io_port_iof_1_29_o_ie : ieReg_io_q[29]) : (io_port_iof_0_29_o_valid ? io_port_iof_0_29_o_ie : ieReg_io_q[29])) : ieReg_io_q[29]);
  assign io_port_pins_29_o_pue = (iofEnReg_io_q[29] ? pueReg_io_q[29] : pueReg_io_q[29]);
  assign io_port_pins_29_o_ds = (iofEnReg_io_q[29] ? dsReg[29] : dsReg[29]);
  assign io_port_pins_30_o_oval = ((iofEnReg_io_q[30] ? (iofSelReg[30] ? (io_port_iof_1_30_o_valid ? io_port_iof_1_30_o_oval : portReg[30]) : (io_port_iof_0_30_o_valid ? io_port_iof_0_30_o_oval : portReg[30])) : portReg[30]) ^ xorReg[30]);
  assign io_port_pins_30_o_oe = (iofEnReg_io_q[30] ? (iofSelReg[30] ? (io_port_iof_1_30_o_valid ? io_port_iof_1_30_o_oe : oeReg_io_q[30]) : (io_port_iof_0_30_o_valid ? io_port_iof_0_30_o_oe : oeReg_io_q[30])) : oeReg_io_q[30]);
  assign io_port_pins_30_o_ie = (iofEnReg_io_q[30] ? (iofSelReg[30] ? (io_port_iof_1_30_o_valid ? io_port_iof_1_30_o_ie : ieReg_io_q[30]) : (io_port_iof_0_30_o_valid ? io_port_iof_0_30_o_ie : ieReg_io_q[30])) : ieReg_io_q[30]);
  assign io_port_pins_30_o_pue = (iofEnReg_io_q[30] ? pueReg_io_q[30] : pueReg_io_q[30]);
  assign io_port_pins_30_o_ds = (iofEnReg_io_q[30] ? dsReg[30] : dsReg[30]);
  assign io_port_pins_31_o_oval = ((iofEnReg_io_q[31] ? (iofSelReg[31] ? (io_port_iof_1_31_o_valid ? io_port_iof_1_31_o_oval : portReg[31]) : (io_port_iof_0_31_o_valid ? io_port_iof_0_31_o_oval : portReg[31])) : portReg[31]) ^ xorReg[31]);
  assign io_port_pins_31_o_oe = (iofEnReg_io_q[31] ? (iofSelReg[31] ? (io_port_iof_1_31_o_valid ? io_port_iof_1_31_o_oe : oeReg_io_q[31]) : (io_port_iof_0_31_o_valid ? io_port_iof_0_31_o_oe : oeReg_io_q[31])) : oeReg_io_q[31]);
  assign io_port_pins_31_o_ie = (iofEnReg_io_q[31] ? (iofSelReg[31] ? (io_port_iof_1_31_o_valid ? io_port_iof_1_31_o_ie : ieReg_io_q[31]) : (io_port_iof_0_31_o_valid ? io_port_iof_0_31_o_ie : ieReg_io_q[31])) : ieReg_io_q[31]);
  assign io_port_pins_31_o_pue = (iofEnReg_io_q[31] ? pueReg_io_q[31] : pueReg_io_q[31]);
  assign io_port_pins_31_o_ds = (iofEnReg_io_q[31] ? dsReg[31] : dsReg[31]);
  assign io_port_iof_0_0_i_ival = inSyncReg[0];
  assign io_port_iof_0_1_i_ival = inSyncReg[1];
  assign io_port_iof_0_2_i_ival = inSyncReg[2];
  assign io_port_iof_0_3_i_ival = inSyncReg[3];
  assign io_port_iof_0_4_i_ival = inSyncReg[4];
  assign io_port_iof_0_5_i_ival = inSyncReg[5];
  assign io_port_iof_0_6_i_ival = inSyncReg[6];
  assign io_port_iof_0_7_i_ival = inSyncReg[7];
  assign io_port_iof_0_8_i_ival = inSyncReg[8];
  assign io_port_iof_0_9_i_ival = inSyncReg[9];
  assign io_port_iof_0_10_i_ival = inSyncReg[10];
  assign io_port_iof_0_11_i_ival = inSyncReg[11];
  assign io_port_iof_0_12_i_ival = inSyncReg[12];
  assign io_port_iof_0_13_i_ival = inSyncReg[13];
  assign io_port_iof_0_14_i_ival = inSyncReg[14];
  assign io_port_iof_0_15_i_ival = inSyncReg[15];
  assign io_port_iof_0_16_i_ival = inSyncReg[16];
  assign io_port_iof_0_17_i_ival = inSyncReg[17];
  assign io_port_iof_0_18_i_ival = inSyncReg[18];
  assign io_port_iof_0_19_i_ival = inSyncReg[19];
  assign io_port_iof_0_20_i_ival = inSyncReg[20];
  assign io_port_iof_0_21_i_ival = inSyncReg[21];
  assign io_port_iof_0_22_i_ival = inSyncReg[22];
  assign io_port_iof_0_23_i_ival = inSyncReg[23];
  assign io_port_iof_0_24_i_ival = inSyncReg[24];
  assign io_port_iof_0_25_i_ival = inSyncReg[25];
  assign io_port_iof_0_26_i_ival = inSyncReg[26];
  assign io_port_iof_0_27_i_ival = inSyncReg[27];
  assign io_port_iof_0_28_i_ival = inSyncReg[28];
  assign io_port_iof_0_29_i_ival = inSyncReg[29];
  assign io_port_iof_0_30_i_ival = inSyncReg[30];
  assign io_port_iof_0_31_i_ival = inSyncReg[31];
  assign io_port_iof_1_0_i_ival = inSyncReg[0];
  assign io_port_iof_1_1_i_ival = inSyncReg[1];
  assign io_port_iof_1_2_i_ival = inSyncReg[2];
  assign io_port_iof_1_3_i_ival = inSyncReg[3];
  assign io_port_iof_1_4_i_ival = inSyncReg[4];
  assign io_port_iof_1_5_i_ival = inSyncReg[5];
  assign io_port_iof_1_6_i_ival = inSyncReg[6];
  assign io_port_iof_1_7_i_ival = inSyncReg[7];
  assign io_port_iof_1_8_i_ival = inSyncReg[8];
  assign io_port_iof_1_9_i_ival = inSyncReg[9];
  assign io_port_iof_1_10_i_ival = inSyncReg[10];
  assign io_port_iof_1_11_i_ival = inSyncReg[11];
  assign io_port_iof_1_12_i_ival = inSyncReg[12];
  assign io_port_iof_1_13_i_ival = inSyncReg[13];
  assign io_port_iof_1_14_i_ival = inSyncReg[14];
  assign io_port_iof_1_15_i_ival = inSyncReg[15];
  assign io_port_iof_1_16_i_ival = inSyncReg[16];
  assign io_port_iof_1_17_i_ival = inSyncReg[17];
  assign io_port_iof_1_18_i_ival = inSyncReg[18];
  assign io_port_iof_1_19_i_ival = inSyncReg[19];
  assign io_port_iof_1_20_i_ival = inSyncReg[20];
  assign io_port_iof_1_21_i_ival = inSyncReg[21];
  assign io_port_iof_1_22_i_ival = inSyncReg[22];
  assign io_port_iof_1_23_i_ival = inSyncReg[23];
  assign io_port_iof_1_24_i_ival = inSyncReg[24];
  assign io_port_iof_1_25_i_ival = inSyncReg[25];
  assign io_port_iof_1_26_i_ival = inSyncReg[26];
  assign io_port_iof_1_27_i_ival = inSyncReg[27];
  assign io_port_iof_1_28_i_ival = inSyncReg[28];
  assign io_port_iof_1_29_i_ival = inSyncReg[29];
  assign io_port_iof_1_30_i_ival = inSyncReg[30];
  assign io_port_iof_1_31_i_ival = inSyncReg[31];
  assign T_3269 = ~ valueReg;
  assign T_3312 = io_in_0_a_bits_opcode == 3'h4;
  assign T_3316 = {({io_in_0_a_bits_address[1:0],io_in_0_a_bits_source}),io_in_0_a_bits_size};
  assign T_3457 = (io_in_0_a_bits_address[11:2] & 10'h3e0) == 10'h0;
  assign T_3466 = ((io_in_0_a_bits_address[11:2] ^ 10'h5) & 10'h3e0) == 10'h0;
  assign T_3475 = ((io_in_0_a_bits_address[11:2] ^ 10'ha) & 10'h3e0) == 10'h0;
  assign T_3484 = ((io_in_0_a_bits_address[11:2] ^ 10'he) & 10'h3e0) == 10'h0;
  assign T_3493 = ((io_in_0_a_bits_address[11:2] ^ 10'h1) & 10'h3e0) == 10'h0;
  assign T_3502 = ((io_in_0_a_bits_address[11:2] ^ 10'h6) & 10'h3e0) == 10'h0;
  assign T_3511 = ((io_in_0_a_bits_address[11:2] ^ 10'h9) & 10'h3e0) == 10'h0;
  assign T_3520 = ((io_in_0_a_bits_address[11:2] ^ 10'hd) & 10'h3e0) == 10'h0;
  assign T_3529 = ((io_in_0_a_bits_address[11:2] ^ 10'h2) & 10'h3e0) == 10'h0;
  assign T_3538 = ((io_in_0_a_bits_address[11:2] ^ 10'hc) & 10'h3e0) == 10'h0;
  assign T_3547 = ((io_in_0_a_bits_address[11:2] ^ 10'h7) & 10'h3e0) == 10'h0;
  assign T_3556 = ((io_in_0_a_bits_address[11:2] ^ 10'h3) & 10'h3e0) == 10'h0;
  assign T_3565 = ((io_in_0_a_bits_address[11:2] ^ 10'h10) & 10'h3e0) == 10'h0;
  assign T_3574 = ((io_in_0_a_bits_address[11:2] ^ 10'hb) & 10'h3e0) == 10'h0;
  assign T_3583 = ((io_in_0_a_bits_address[11:2] ^ 10'h8) & 10'h3e0) == 10'h0;
  assign T_3592 = ((io_in_0_a_bits_address[11:2] ^ 10'h4) & 10'h3e0) == 10'h0;
  assign T_3601 = ((io_in_0_a_bits_address[11:2] ^ 10'hf) & 10'h3e0) == 10'h0;
  assign T_3858 = (~ ({({(io_in_0_a_bits_mask[3] ? 8'hff : 8'h0),(io_in_0_a_bits_mask[2] ? 8'hff : 8'h0)}),({(io_in_0_a_bits_mask[1] ? 8'hff : 8'h0),(io_in_0_a_bits_mask[0] ? 8'hff : 8'h0)})})) == 32'h0;
  assign T_4557 = T_3457 == 1'h0;
  assign T_4561 = T_3493 == 1'h0;
  assign T_4565 = T_3529 == 1'h0;
  assign T_4569 = T_3556 == 1'h0;
  assign T_4573 = T_3592 == 1'h0;
  assign T_4577 = T_3466 == 1'h0;
  assign T_4581 = T_3502 == 1'h0;
  assign T_4585 = T_3547 == 1'h0;
  assign T_4589 = T_3583 == 1'h0;
  assign T_4593 = T_3511 == 1'h0;
  assign T_4597 = T_3475 == 1'h0;
  assign T_4601 = T_3574 == 1'h0;
  assign T_4605 = T_3538 == 1'h0;
  assign T_4609 = T_3520 == 1'h0;
  assign T_4613 = T_3484 == 1'h0;
  assign T_4617 = T_3601 == 1'h0;
  assign T_4621 = T_3565 == 1'h0;
  assign T_5301 = {({({io_in_0_a_bits_address[6],io_in_0_a_bits_address[5]}),io_in_0_a_bits_address[4]}),({io_in_0_a_bits_address[3],io_in_0_a_bits_address[2]})};
  assign T_5318 = T_3312 ? (5'h1f == T_5301 ? 1'h1 : (5'h1e == T_5301 ? 1'h1 : (5'h1d == T_5301 ? 1'h1 : (5'h1c == T_5301 ? 1'h1 : (5'h1b == T_5301 ? 1'h1 : (5'h1a == T_5301 ? 1'h1 : (5'h19 == T_5301 ? 1'h1 : (5'h18 == T_5301 ? 1'h1 : (5'h17 == T_5301 ? 1'h1 : (5'h16 == T_5301 ? 1'h1 : (5'h15 == T_5301 ? 1'h1 : (5'h14 == T_5301 ? 1'h1 : (5'h13 == T_5301 ? 1'h1 : (5'h12 == T_5301 ? 1'h1 : (5'h11 == T_5301 ? 1'h1 : (5'h10 == T_5301 ? (T_4621 | 1'h1) : (5'hf == T_5301 ? (T_4617 | 1'h1) : (5'he == T_5301 ? (T_4613 | 1'h1) : (5'hd == T_5301 ? (T_4609 | 1'h1) : (5'hc == T_5301 ? (T_4605 | 1'h1) : (5'hb == T_5301 ? (T_4601 | 1'h1) : (5'ha == T_5301 ? (T_4597 | 1'h1) : (5'h9 == T_5301 ? (T_4593 | 1'h1) : (5'h8 == T_5301 ? (T_4589 | 1'h1) : (5'h7 == T_5301 ? (T_4585 | 1'h1) : (5'h6 == T_5301 ? (T_4581 | 1'h1) : (5'h5 == T_5301 ? (T_4577 | 1'h1) : (5'h4 == T_5301 ? (T_4573 | 1'h1) : (5'h3 == T_5301 ? (T_4569 | 1'h1) : (5'h2 == T_5301 ? (T_4565 | 1'h1) : (5'h1 == T_5301 ? (T_4561 | 1'h1) : (T_4557 | 1'h1)))))))))))))))))))))))))))))))) : (5'h1f == T_5301 ? 1'h1 : (5'h1e == T_5301 ? 1'h1 : (5'h1d == T_5301 ? 1'h1 : (5'h1c == T_5301 ? 1'h1 : (5'h1b == T_5301 ? 1'h1 : (5'h1a == T_5301 ? 1'h1 : (5'h19 == T_5301 ? 1'h1 : (5'h18 == T_5301 ? 1'h1 : (5'h17 == T_5301 ? 1'h1 : (5'h16 == T_5301 ? 1'h1 : (5'h15 == T_5301 ? 1'h1 : (5'h14 == T_5301 ? 1'h1 : (5'h13 == T_5301 ? 1'h1 : (5'h12 == T_5301 ? 1'h1 : (5'h11 == T_5301 ? 1'h1 : (5'h10 == T_5301 ? (T_4621 | 1'h1) : (5'hf == T_5301 ? (T_4617 | 1'h1) : (5'he == T_5301 ? (T_4613 | 1'h1) : (5'hd == T_5301 ? (T_4609 | 1'h1) : (5'hc == T_5301 ? (T_4605 | 1'h1) : (5'hb == T_5301 ? (T_4601 | 1'h1) : (5'ha == T_5301 ? (T_4597 | 1'h1) : (5'h9 == T_5301 ? (T_4593 | 1'h1) : (5'h8 == T_5301 ? (T_4589 | 1'h1) : (5'h7 == T_5301 ? (T_4585 | 1'h1) : (5'h6 == T_5301 ? (T_4581 | 1'h1) : (5'h5 == T_5301 ? (T_4577 | 1'h1) : (5'h4 == T_5301 ? (T_4573 | 1'h1) : (5'h3 == T_5301 ? (T_4569 | 1'h1) : (5'h2 == T_5301 ? (T_4565 | 1'h1) : (5'h1 == T_5301 ? (T_4561 | 1'h1) : (T_4557 | 1'h1))))))))))))))))))))))))))))))));
  assign T_5321 = T_3312 ? (5'h1f == T_5301 ? 1'h1 : (5'h1e == T_5301 ? 1'h1 : (5'h1d == T_5301 ? 1'h1 : (5'h1c == T_5301 ? 1'h1 : (5'h1b == T_5301 ? 1'h1 : (5'h1a == T_5301 ? 1'h1 : (5'h19 == T_5301 ? 1'h1 : (5'h18 == T_5301 ? 1'h1 : (5'h17 == T_5301 ? 1'h1 : (5'h16 == T_5301 ? 1'h1 : (5'h15 == T_5301 ? 1'h1 : (5'h14 == T_5301 ? 1'h1 : (5'h13 == T_5301 ? 1'h1 : (5'h12 == T_5301 ? 1'h1 : (5'h11 == T_5301 ? 1'h1 : (5'h10 == T_5301 ? (T_4621 | 1'h1) : (5'hf == T_5301 ? (T_4617 | 1'h1) : (5'he == T_5301 ? (T_4613 | 1'h1) : (5'hd == T_5301 ? (T_4609 | 1'h1) : (5'hc == T_5301 ? (T_4605 | 1'h1) : (5'hb == T_5301 ? (T_4601 | 1'h1) : (5'ha == T_5301 ? (T_4597 | 1'h1) : (5'h9 == T_5301 ? (T_4593 | 1'h1) : (5'h8 == T_5301 ? (T_4589 | 1'h1) : (5'h7 == T_5301 ? (T_4585 | 1'h1) : (5'h6 == T_5301 ? (T_4581 | 1'h1) : (5'h5 == T_5301 ? (T_4577 | 1'h1) : (5'h4 == T_5301 ? (T_4573 | 1'h1) : (5'h3 == T_5301 ? (T_4569 | 1'h1) : (5'h2 == T_5301 ? (T_4565 | 1'h1) : (5'h1 == T_5301 ? (T_4561 | 1'h1) : (T_4557 | 1'h1)))))))))))))))))))))))))))))))) : (5'h1f == T_5301 ? 1'h1 : (5'h1e == T_5301 ? 1'h1 : (5'h1d == T_5301 ? 1'h1 : (5'h1c == T_5301 ? 1'h1 : (5'h1b == T_5301 ? 1'h1 : (5'h1a == T_5301 ? 1'h1 : (5'h19 == T_5301 ? 1'h1 : (5'h18 == T_5301 ? 1'h1 : (5'h17 == T_5301 ? 1'h1 : (5'h16 == T_5301 ? 1'h1 : (5'h15 == T_5301 ? 1'h1 : (5'h14 == T_5301 ? 1'h1 : (5'h13 == T_5301 ? 1'h1 : (5'h12 == T_5301 ? 1'h1 : (5'h11 == T_5301 ? 1'h1 : (5'h10 == T_5301 ? (T_4621 | 1'h1) : (5'hf == T_5301 ? (T_4617 | 1'h1) : (5'he == T_5301 ? (T_4613 | 1'h1) : (5'hd == T_5301 ? (T_4609 | 1'h1) : (5'hc == T_5301 ? (T_4605 | 1'h1) : (5'hb == T_5301 ? (T_4601 | 1'h1) : (5'ha == T_5301 ? (T_4597 | 1'h1) : (5'h9 == T_5301 ? (T_4593 | 1'h1) : (5'h8 == T_5301 ? (T_4589 | 1'h1) : (5'h7 == T_5301 ? (T_4585 | 1'h1) : (5'h6 == T_5301 ? (T_4581 | 1'h1) : (5'h5 == T_5301 ? (T_4577 | 1'h1) : (5'h4 == T_5301 ? (T_4573 | 1'h1) : (5'h3 == T_5301 ? (T_4569 | 1'h1) : (5'h2 == T_5301 ? (T_4565 | 1'h1) : (5'h1 == T_5301 ? (T_4561 | 1'h1) : (T_4557 | 1'h1))))))))))))))))))))))))))))))));
  assign T_5323 = io_in_0_a_valid & T_5318;
  assign T_5359 = (32'h1 << T_5301) & ({({8'hff,({4'hf,({2'h3,({1'h1,T_3565})})})}),({({({({T_3601,T_3484}),({T_3520,T_3538})}),({({T_3574,T_3475}),({T_3511,T_3583})})}),({({({T_3547,T_3502}),({T_3466,T_3592})}),({({T_3556,T_3529}),({T_3493,T_3457})})})})});
  assign T_5411 = (T_5323 & io_in_0_d_ready) & (T_3312 == 1'h0);

  always @(posedge clock or posedge reset)
    if(reset) begin
      T_3256 <= 32'b0;
      T_3257 <= 32'b0;
      inSyncReg <= 32'b0;
    end
    else begin
      T_3256 <= ({({({({({io_port_pins_31_i_ival,io_port_pins_30_i_ival}),({io_port_pins_29_i_ival,io_port_pins_28_i_ival})}),({({io_port_pins_27_i_ival,io_port_pins_26_i_ival}),({io_port_pins_25_i_ival,io_port_pins_24_i_ival})})}),({({({io_port_pins_23_i_ival,io_port_pins_22_i_ival}),({io_port_pins_21_i_ival,io_port_pins_20_i_ival})}),({({io_port_pins_19_i_ival,io_port_pins_18_i_ival}),({io_port_pins_17_i_ival,io_port_pins_16_i_ival})})})}),({({({({io_port_pins_15_i_ival,io_port_pins_14_i_ival}),({io_port_pins_13_i_ival,io_port_pins_12_i_ival})}),({({io_port_pins_11_i_ival,io_port_pins_10_i_ival}),({io_port_pins_9_i_ival,io_port_pins_8_i_ival})})}),({({({io_port_pins_7_i_ival,io_port_pins_6_i_ival}),({io_port_pins_5_i_ival,io_port_pins_4_i_ival})}),({({io_port_pins_3_i_ival,io_port_pins_2_i_ival}),({io_port_pins_1_i_ival,io_port_pins_0_i_ival})})})})});
      T_3257 <= T_3256;
      inSyncReg <= T_3257;
    end

  always @(posedge clock or posedge reset) 
    if (reset) begin
      portReg <= 32'h0;
    end else if (T_5411 & T_5359[3] & T_3858) begin
      portReg <= io_in_0_a_bits_data;
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      dsReg <= 32'h0;
    end else if (T_5411 & T_5359[5] & T_3858) begin
      dsReg <= io_in_0_a_bits_data;
    end


  always @(posedge clock or posedge reset)
    if (reset) begin
      valueReg <= 32'h0;
    end else begin
      valueReg <= inSyncReg;
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      highIeReg <= 32'h0;
    end else if (T_5411 & T_5359[10] & T_3858) begin
      highIeReg <= io_in_0_a_bits_data;
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      lowIeReg <= 32'h0;
    end else if (T_5411 & T_5359[12] & T_3858) begin
      lowIeReg <= io_in_0_a_bits_data;
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      riseIeReg <= 32'h0;
    end else if (T_5411 & T_5359[6] & T_3858) begin
      riseIeReg <= io_in_0_a_bits_data;
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      fallIeReg <= 32'h0;
    end else if (T_5411 & T_5359[8] & T_3858) begin
      fallIeReg <= io_in_0_a_bits_data;
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      highIpReg <= 32'h0;
    end else begin
      highIpReg <= ((~ ((~ highIpReg) | (((T_5411 & T_5359[11]) & T_3858) ? io_in_0_a_bits_data : 32'h0))) | valueReg);
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      lowIpReg <= 32'h0;
    end else begin
      lowIpReg <= ((~ ((~ lowIpReg) | (((T_5411 & T_5359[13]) & T_3858) ? io_in_0_a_bits_data : 32'h0))) | T_3269);
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      riseIpReg <= 32'h0;
    end else begin
      riseIpReg <= ((~ ((~ riseIpReg) | (((T_5411 & T_5359[7]) & T_3858) ? io_in_0_a_bits_data : 32'h0))) | (T_3269 & inSyncReg));
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      fallIpReg <= 32'h0;
    end else begin
      fallIpReg <= ((~ ((~ fallIpReg) | (((T_5411 & T_5359[9]) & T_3858) ? io_in_0_a_bits_data : 32'h0))) | (valueReg & (~ inSyncReg)));
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      iofSelReg <= 32'h0;
    end else if (T_5411 & T_5359[15] & T_3858) begin
      iofSelReg <= io_in_0_a_bits_data;
    end

  always @(posedge clock or posedge reset)
    if (reset) begin
      xorReg <= 32'h0;
    end else if (T_5411 & T_5359[16] & T_3858) begin
      xorReg <= io_in_0_a_bits_data;
    end

endmodule
