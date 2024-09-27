`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2024 18:05:56
// Design Name: 
// Module Name: alu_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_module
#(
    parameter NB_ALUMODULE_DATA=8,
    parameter NB_ALUMODULE_OP=6
)
(
    input wire signed [NB_ALUMODULE_DATA-1:0] i_alumodule_data_A,
    input wire signed [NB_ALUMODULE_DATA-1:0] i_alumodule_data_B,
    input wire [NB_ALUMODULE_OP-1:0] i_alumodule_OP,
    output wire signed [NB_ALUMODULE_DATA-1:0] o_alumodule_data_RES
);
reg signed [NB_ALUMODULE_DATA-1:0] tmp;
always @(*)
    begin: case_alu
        case(i_alumodule_OP)
            6'b100000: tmp = i_alumodule_data_A + i_alumodule_data_B;//add
            6'b100010: tmp = i_alumodule_data_A - i_alumodule_data_B;//sub
            6'b100100: tmp = i_alumodule_data_A & i_alumodule_data_B;//and
            6'b100101: tmp = i_alumodule_data_A | i_alumodule_data_B;//or
            6'b100110: tmp = i_alumodule_data_A ^ i_alumodule_data_B;//xor
            6'b000011: tmp = i_alumodule_data_A >>> i_alumodule_data_B;//sra
            6'b000010: tmp = i_alumodule_data_A >> i_alumodule_data_B;//srl
            6'b100111: tmp = ~(i_alumodule_data_A | i_alumodule_data_B);//nor
        default: tmp = {NB_ALUMODULE_DATA{1'b0}}; // 00000000... 
        
        endcase
    end
assign o_alumodule_data_RES = tmp;
endmodule

