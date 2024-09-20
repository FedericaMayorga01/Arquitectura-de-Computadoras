`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// TP1 ALU - Modulo ALU
// Mayorga - Segura
// 
// Create Date: 12.09.2024 16:21:08
// Module Name: mod_ALU
// 
//////////////////////////////////////////////////////////////////////////////////


module mod_ALU
#
(
    parameter NB_MODALU_DATA = 8,
    parameter NB_MODALU_OP = 6
)
(
    input   wire signed [NB_MODALU_DATA-1:0]    i_modALU_data_A,
    input   wire signed [NB_MODALU_DATA-1:0]    i_modALU_data_B,
    input   wire        [NB_MODALU_OP-1:0]      i_modALU_OP,
    output  wire signed [NB_MODALU_DATA-1:0]    o_modALU_data_RES
);

reg signed [NB_MODALU_DATA-1:0] tmp;

always @(*)
    begin: case_alu
        case(i_modALU_OP)
            6'b100000: tmp = i_modALU_data_A + i_modALU_data_B;     // Add
            6'b100010: tmp = i_modALU_data_A - i_modALU_data_B;     // Sub
            6'b100100: tmp = i_modALU_data_A & i_modALU_data_B;     // And
            6'b100101: tmp = i_modALU_data_A | i_modALU_data_B;     // Or
            6'b100110: tmp = i_modALU_data_A ^ i_modALU_data_B;     // Xor
            6'b000011: tmp = i_modALU_data_A >>> i_modALU_data_B;   // Sra
            6'b000010: tmp = i_modALU_data_A >> i_modALU_data_B;    // Srl
            6'b100111: tmp = ~(i_modALU_data_A | i_modALU_data_B);  // Nor
        default: tmp = {NB_MODALU_DATA{1'b0}};                      // 00000000... 
        
        endcase
    end

assign o_modALU_data_RES = tmp;
endmodule