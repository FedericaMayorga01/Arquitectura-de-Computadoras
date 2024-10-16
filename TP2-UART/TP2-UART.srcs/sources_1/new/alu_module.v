`timescale 1ns / 1ps

module alu_module
#(
    parameter NB_ALUMODULE_DATA = 8,
    parameter NB_ALUMODULE_OP   = 6
)
(
    input   wire signed [NB_ALUMODULE_DATA-1:0] i_alumodule_data_A,
    input   wire signed [NB_ALUMODULE_DATA-1:0] i_alumodule_data_B,
    input   wire [NB_ALUMODULE_OP-1:0] i_alumodule_OP,
//    input   wire  i_alumodule_VERIFIN,

    output  wire signed [NB_ALUMODULE_DATA-1:0] o_alumodule_data_RES,
    output  wire o_alumodule_ZERO,
    output  wire o_alumodule_NEGATIVE,
    output  wire o_alumodule_CARRY
//    output  wire o_alumodule_READY
);

reg signed [NB_ALUMODULE_DATA-1:0] alumodule_tmpreg;
reg alumodule_carryreg;
//, alumodule_readyreg;
//wire alumodule_enablewire;

//assign alumodule_enablewire = i_alumodule_VERIFIN ;

always @(*)
    begin: case_alu
        //if(alumodule_enablewire)
        //    alumodule_readyreg = 1'b0;

        case(i_alumodule_OP)
            // Suma con alumodule_carryreg
            6'b100000 :
                begin
                    {alumodule_carryreg, alumodule_tmpreg} = i_alumodule_data_A + i_alumodule_data_B; // alumodule_carryreg es el bit m�s significativo de la suma
//                    alumodule_readyreg = 1'b1;
                end

            // Resta con borrow
            6'b100010 :
                begin
                    {alumodule_carryreg, alumodule_tmpreg} = i_alumodule_data_A - i_alumodule_data_B; // alumodule_carryreg es 1 si hay borrow
//                    alumodule_readyreg = 1'b1;
                end

            // Operaciones logicas, alumodule_carryreg no es relevante
            6'b100100 :
                begin
                    alumodule_tmpreg = i_alumodule_data_A & i_alumodule_data_B; 
                    alumodule_carryreg = 1'b0; // No hay alumodule_carryreg en AND
//                    alumodule_readyreg = 1'b1;
                end

            6'b100101 :
                begin
                    alumodule_tmpreg = i_alumodule_data_A | i_alumodule_data_B;
                    alumodule_carryreg = 1'b0; // No hay alumodule_carryreg en OR
//                    alumodule_readyreg = 1'b1;
                end

            6'b100110 :
                begin
                    alumodule_tmpreg = i_alumodule_data_A ^ i_alumodule_data_B;
                    alumodule_carryreg = 1'b0; // No hay alumodule_carryreg en XOR
//                    alumodule_readyreg = 1'b1;
                end

            // Desplazamientos, sin alumodule_carryreg relevante
            6'b000011 :
                begin
                    alumodule_tmpreg = i_alumodule_data_A >>> i_alumodule_data_B;
                    alumodule_carryreg = 1'b0; // No hay alumodule_carryreg en SRA
//                    alumodule_readyreg = 1'b1;
                end

            6'b000010 :
                begin
                    alumodule_tmpreg = i_alumodule_data_A >> i_alumodule_data_B;
                    alumodule_carryreg = 1'b0; // No hay alumodule_carryreg en SRL
//                    alumodule_readyreg = 1'b1;
                end

            6'b100111 :
                begin
                    alumodule_tmpreg = ~(i_alumodule_data_A | i_alumodule_data_B);
                    alumodule_carryreg = 1'b0; // No hay alumodule_carryreg en NOR
//                    alumodule_readyreg = 1'b1;
                end

            default :
                begin
                    alumodule_tmpreg = {NB_ALUMODULE_DATA{1'b0}};
                    alumodule_carryreg = 1'b0; // Default sin alumodule_carryreg
//                    alumodule_readyreg = 1'b0;
                end
        endcase
    end

assign o_alumodule_data_RES = alumodule_tmpreg;
assign o_alumodule_ZERO     = (alumodule_tmpreg == 0) ? 1'b1 : 1'b0;
assign o_alumodule_CARRY    = alumodule_carryreg;
assign o_alumodule_NEGATIVE = alumodule_tmpreg[NB_ALUMODULE_DATA - 1];
//assign o_alumodule_READY = alumodule_readyreg;
// ver si poner el de overflow

endmodule
