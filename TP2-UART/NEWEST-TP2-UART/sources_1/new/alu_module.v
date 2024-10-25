`timescale 1ns / 1ps

module alu_module #(
    parameter NB_ALUMODULE_DATA = 8,
    parameter NB_ALUMODULE_OP   = 6
)(
    input wire signed [NB_ALUMODULE_DATA-1:0] i_alumodule_data_A,
    input wire signed [NB_ALUMODULE_DATA-1:0] i_alumodule_data_B,
    input wire        [NB_ALUMODULE_OP-1:0]   i_alumodule_OP,

    output wire signed [NB_ALUMODULE_DATA-1:0] o_alumodule_data_RES
);

//operations opcodes
localparam  ALUM_ADD = 6'b100000;
localparam  ALUM_SUB = 6'b100010;
localparam  ALUM_AND = 6'b100100;
localparam  ALUM_OR  = 6'b100101;
localparam  ALUM_XOR = 6'b100110;
localparam  ALUM_SRA = 6'b000011;
localparam  ALUM_SRL = 6'b000010;
localparam  ALUM_NOR = 6'b100111;

reg signed [NB_ALUMODULE_DATA-1 : 0] alumodule_tmpreg; //register for storing alumodule_tmpreg
//assign o_alumodule_data_RES = alumodule_tmpreg; // Posicion original del assign


//combinational logic bock
always @(*)
begin
    case (i_alumodule_OP)
        ALUM_ADD : alumodule_tmpreg = i_alumodule_data_A + i_alumodule_data_B;
        ALUM_SUB : alumodule_tmpreg = i_alumodule_data_A - i_alumodule_data_B;
        ALUM_AND : alumodule_tmpreg = i_alumodule_data_A & i_alumodule_data_B;
        ALUM_OR  : alumodule_tmpreg = i_alumodule_data_A | i_alumodule_data_B;
        ALUM_XOR : alumodule_tmpreg = i_alumodule_data_A ^ i_alumodule_data_B;
        ALUM_SRA : alumodule_tmpreg = i_alumodule_data_A >>> i_alumodule_data_B;
        ALUM_SRL : alumodule_tmpreg = i_alumodule_data_A >> i_alumodule_data_B;
        ALUM_NOR : alumodule_tmpreg = ~(i_alumodule_data_A | i_alumodule_data_B);
    default : alumodule_tmpreg = {NB_ALUMODULE_DATA {1'b0}}; //non valid opcode -> output = 0
    endcase
end

// Movi el assign aca para que no haya problemas con el bloque combinacional
assign o_alumodule_data_RES = alumodule_tmpreg;

endmodule
