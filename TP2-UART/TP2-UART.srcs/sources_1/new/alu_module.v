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
    parameter NB_ALUMODULE_DATA = 8,
    parameter NB_ALUMODULE_OP   = 6
)
(
    input   wire signed [NB_ALUMODULE_DATA-1:0] i_alumodule_data_A,
    input   wire signed [NB_ALUMODULE_DATA-1:0] i_alumodule_data_B,
    input   wire [NB_ALUMODULE_OP-1:0] i_alumodule_OP,
    output  wire signed [NB_ALUMODULE_DATA-1:0] o_alumodule_data_RES,
    output  wire o_alumodule_ZERO,
    output  wire o_alumodule_NEGATIVE,
    output  wire o_alumodule_CARRY
);

reg signed [NB_ALUMODULE_DATA-1:0] alumodule_tmp;
reg alumodule_carry;

always @(*)
    begin: case_alu
        case(i_alumodule_OP)
            // Suma con alumodule_carry
            6'b100000 :
                {alumodule_carry, alumodule_tmp} = i_alumodule_data_A + i_alumodule_data_B; // alumodule_carry es el bit m�s significativo de la suma

            // Resta con borrow
            6'b100010 :
                {alumodule_carry, alumodule_tmp} = i_alumodule_data_A - i_alumodule_data_B; // alumodule_carry es 1 si hay borrow

            // Operaciones l�gicas, alumodule_carry no es relevante
            6'b100100 :
                begin
                    alumodule_tmp = i_alumodule_data_A & i_alumodule_data_B; 
                    alumodule_carry = 1'b0; // No hay alumodule_carry en AND
                end

            6'b100101 :
                begin
                    alumodule_tmp = i_alumodule_data_A | i_alumodule_data_B;
                    alumodule_carry = 1'b0; // No hay alumodule_carry en OR
                end

            6'b100110 :
                begin
                    alumodule_tmp = i_alumodule_data_A ^ i_alumodule_data_B;
                    alumodule_carry = 1'b0; // No hay alumodule_carry en XOR
                end

            // Desplazamientos, sin alumodule_carry relevante
            6'b000011 :
                begin
                    alumodule_tmp = i_alumodule_data_A >>> i_alumodule_data_B;
                    alumodule_carry = 1'b0; // No hay alumodule_carry en SRA
                end

            6'b000010 :
                begin
                    alumodule_tmp = i_alumodule_data_A >> i_alumodule_data_B;
                    alumodule_carry = 1'b0; // No hay alumodule_carry en SRL
                end

            6'b100111 :
                begin
                    alumodule_tmp = ~(i_alumodule_data_A | i_alumodule_data_B);
                    alumodule_carry = 1'b0; // No hay alumodule_carry en NOR
                end

            default :
                begin
                    alumodule_tmp = {NB_ALUMODULE_DATA{1'b0}};
                    alumodule_carry = 1'b0; // Default sin alumodule_carry
                end
        endcase
    end

assign o_alumodule_data_RES = alumodule_tmp;
assign o_alumodule_ZERO     = (alumodule_tmp == 0) ? 1'b1 : 1'b0;
assign o_alumodule_CARRY    = alumodule_carry;
assign o_alumodule_NEGATIVE = alumodule_tmp[NB_ALUMODULE_DATA - 1];
// ver si poner el de overflow

endmodule

