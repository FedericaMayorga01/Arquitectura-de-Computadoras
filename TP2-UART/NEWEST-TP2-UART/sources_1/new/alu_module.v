`timescale 1ns / 1ps

module alu_module
#(
    parameter NB_ALUMODULE_DATA = 8,
    parameter NB_ALUMODULE_OP   = 6
)
(
    input   wire signed [NB_ALUMODULE_DATA-1:0] i_alumodule_data_A,
    input   wire signed [NB_ALUMODULE_DATA-1:0] i_alumodule_data_B,
    input   wire        [NB_ALUMODULE_OP-1:0]   i_alumodule_OP,
    output  wire signed [NB_ALUMODULE_DATA-1:0] o_alumodule_data_RES,
    output  wire                                o_alumodule_ZERO,
    output  wire                                o_alumodule_NEGATIVE,
    output  wire                                o_alumodule_CARRY
);

reg signed [NB_ALUMODULE_DATA-1:0] alumodule_tmpreg;
reg                                alumodule_carryreg;

always @(*)
    begin: case_alu
        case(i_alumodule_OP)
            // Suma con carry
            6'b100000 :
                {alumodule_carryreg, alumodule_tmpreg} = i_alumodule_data_A + i_alumodule_data_B; 

            // Resta con borrow
            6'b100010 :
                {alumodule_carryreg, alumodule_tmpreg} = i_alumodule_data_A - i_alumodule_data_B; 

            // AND
            6'b100100 :
                begin
                    alumodule_tmpreg   = i_alumodule_data_A & i_alumodule_data_B; 
                    alumodule_carryreg = 1'b0; 
                end
            
            // OR
            6'b100101 :
                begin
                    alumodule_tmpreg   = i_alumodule_data_A | i_alumodule_data_B;
                    alumodule_carryreg = 1'b0; 
                end

            // XOR
            6'b100110 :
                begin
                    alumodule_tmpreg   = i_alumodule_data_A ^ i_alumodule_data_B;
                    alumodule_carryreg = 1'b0; 
                end

            // SRA
            6'b000011 :
                begin
                    alumodule_tmpreg   = i_alumodule_data_A >>> i_alumodule_data_B;
                    alumodule_carryreg = 1'b0; 
                end

            // SRL
            6'b000010 :
                begin
                    alumodule_tmpreg   = i_alumodule_data_A >> i_alumodule_data_B;
                    alumodule_carryreg = 1'b0;
                end

            6'b100111 :
                begin
                    alumodule_tmpreg   = ~(i_alumodule_data_A | i_alumodule_data_B);
                    alumodule_carryreg = 1'b0; 
                end

            default :
                begin
                    alumodule_tmpreg   = {NB_ALUMODULE_DATA{1'b0}};
                    alumodule_carryreg = 1'b0; 
                end
        endcase
    end

assign o_alumodule_data_RES = alumodule_tmpreg;
assign o_alumodule_ZERO     = (alumodule_tmpreg == 0) ? 1'b1 : 1'b0;
assign o_alumodule_CARRY    = alumodule_carryreg;
assign o_alumodule_NEGATIVE = alumodule_tmpreg[NB_ALUMODULE_DATA - 1];

endmodule