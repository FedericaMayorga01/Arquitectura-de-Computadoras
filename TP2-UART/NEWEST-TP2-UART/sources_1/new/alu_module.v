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
localparam  ADD = 6'b100000;
localparam  SUB = 6'b100010;
localparam  AND = 6'b100100;
localparam  OR  = 6'b100101;
localparam  XOR = 6'b100110;
localparam  SRA = 6'b000011;
localparam  SRL = 6'b000010;
localparam  NOR = 6'b100111;

reg signed [NB_ALUMODULE_DATA-1 : 0] alumodule_tmpreg; //register for storing alumodule_tmpreg
//assign o_alumodule_data_RES = alumodule_tmpreg; // Posicion original del assign


//combinational logic bock
always @(*)
begin
    case (i_alumodule_OP)
        ADD : alumodule_tmpreg = i_alumodule_data_A + i_alumodule_data_B;
        SUB : alumodule_tmpreg = i_alumodule_data_A - i_alumodule_data_B;
        AND : alumodule_tmpreg = i_alumodule_data_A & i_alumodule_data_B;
        OR  : alumodule_tmpreg = i_alumodule_data_A | i_alumodule_data_B;
        XOR : alumodule_tmpreg = i_alumodule_data_A ^ i_alumodule_data_B;
        SRA : alumodule_tmpreg = i_alumodule_data_A >>> i_alumodule_data_B;
        SRL : alumodule_tmpreg = i_alumodule_data_A >> i_alumodule_data_B;
        NOR : alumodule_tmpreg = ~(i_alumodule_data_A | i_alumodule_data_B);
    default : alumodule_tmpreg = {NB_ALUMODULE_DATA {1'b0}}; //non valid opcode -> output = 0
    endcase
end

// Movi el assign aca para que no haya problemas con el bloque combinacional
assign o_alumodule_data_RES = alumodule_tmpreg;

endmodule