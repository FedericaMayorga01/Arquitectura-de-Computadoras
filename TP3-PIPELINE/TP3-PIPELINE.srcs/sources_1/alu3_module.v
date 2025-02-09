`timescale 1ns / 1ps

module alu_module
#(
    parameter NB_ALUMODULE_DATA   = 32,
    parameter NB_ALUMODULE_OP     = 6
)
(
    input   wire    signed [NB_ALUMODULE_DATA-1:0]  i_alumodule_data_A,
    input   wire    signed [NB_ALUMODULE_DATA-1:0]  i_alumodule_data_B,
    input   wire           [NB_ALUMODULE_OP - 1:0]  i_alumodule_OP,
    input   wire    signed [ 4       :0]            i_alumodule_SHIFT,
    output  wire    signed [NB_ALUMODULE_DATA-1:0]  o_alumodule_data_RES
);

    reg signed [NB_ALUMODULE_DATA-1:0]  alumodule_resreg;
    reg        [NB_ALUMODULE_DATA-1:0]  alumodule_resunsreg;
    wire                                alumodule_isunswire;
    wire       [NB_ALUMODULE_DATA-1:0]  alumodule_dataAunswire = i_alumodule_data_A;
    wire       [NB_ALUMODULE_DATA-1:0]  alumodule_dataBunswire = i_alumodule_data_B;

    localparam [NB_ALUMODULE_OP-1:0] ALUM_IDLE_STATE = 6'b111111;
    localparam [NB_ALUMODULE_OP-1:0] ALUM_ADD_STATE  = 6'b100000; // R-type add operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_SUB_STATE  = 6'b100010; // R-type sub operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_SLL_STATE  = 6'b000000; // R-type sll operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_SRL_STATE  = 6'b000010; // R-type srl operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_SRA_STATE  = 6'b000011; // R-type sra operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_SLLV_STATE = 6'b000100; // R-type sllv operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_SRLV_STATE = 6'b000110; // R-type srlv operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_SRAV_STATE = 6'b000111; // R-type srav operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_ADDU_STATE = 6'b100001; // R-type addu operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_SUBU_STATE = 6'b100011; // R-type subu operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_AND_STATE  = 6'b100100; // R-type and operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_OR_STATE   = 6'b100101; // R-type or operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_XOR_STATE  = 6'b100110; // R-type xor operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_NOR_STATE  = 6'b100111; // R-type nor operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_SLT_STATE  = 6'b101010; // R-type slt operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_SLTU_STATE = 6'b101011; // R-type sltu operation

    localparam [NB_ALUMODULE_OP-1:0] ALUM_ADDI_STATE  = 6'b001000; // I-type add operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_ADDIU_STATE = 6'b001001; // I-type addiu operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_ANDI_STATE  = 6'b001100; // I-type and operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_ORI_STATE   = 6'b001101; // I-type or operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_XORI_STATE  = 6'b001110; // I-type xor operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_LUI_STATE   = 6'b001111; // I-type lui operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_SLTI_STATE  = 6'b001010; // I-type slti operation
    localparam [NB_ALUMODULE_OP-1:0] ALUM_SLTIU_STATE = 6'b001011; // I-type sltiu operation


    always @(*) begin
        alumodule_resreg = 0;
        alumodule_resunsreg = 0;
        case(i_alumodule_OP)
            ALUM_ADD_STATE:   alumodule_resreg    = i_alumodule_data_A + i_alumodule_data_B;
            ALUM_SUB_STATE:   alumodule_resreg    = i_alumodule_data_A - i_alumodule_data_B;
            ALUM_SLL_STATE:   alumodule_resreg    = i_alumodule_data_B << i_alumodule_SHIFT;
            ALUM_SRL_STATE:   alumodule_resreg    = i_alumodule_data_B >> i_alumodule_SHIFT;
            ALUM_SRA_STATE:   alumodule_resreg    = i_alumodule_data_B >>> i_alumodule_SHIFT;
            ALUM_SLLV_STATE:  alumodule_resreg    = i_alumodule_data_B << i_alumodule_data_A;
            ALUM_SRLV_STATE:  alumodule_resreg    = i_alumodule_data_B >> i_alumodule_data_A;
            ALUM_SRAV_STATE:  alumodule_resreg    = i_alumodule_data_B >>> i_alumodule_data_A;
            ALUM_ADDU_STATE:  alumodule_resunsreg = alumodule_dataAunswire + alumodule_dataBunswire;
            ALUM_SUBU_STATE:  alumodule_resunsreg = alumodule_dataAunswire - alumodule_dataBunswire;
            ALUM_AND_STATE:   alumodule_resreg    = i_alumodule_data_A & i_alumodule_data_B;
            ALUM_OR_STATE:    alumodule_resreg    = i_alumodule_data_A | i_alumodule_data_B;
            ALUM_XOR_STATE:   alumodule_resreg    = i_alumodule_data_A ^ i_alumodule_data_B;
            ALUM_NOR_STATE:   alumodule_resreg    = ~(i_alumodule_data_A | i_alumodule_data_B);
            ALUM_SLT_STATE:   alumodule_resreg    = (i_alumodule_data_A < i_alumodule_data_B) ? 1 : 0;
            ALUM_SLTU_STATE:  alumodule_resunsreg = (alumodule_dataAunswire < alumodule_dataBunswire) ? 1 : 0;
            ALUM_ADDI_STATE:  alumodule_resreg    = i_alumodule_data_A + i_alumodule_data_B;
            ALUM_ADDIU_STATE: alumodule_resunsreg = alumodule_dataAunswire + alumodule_dataBunswire;
            ALUM_ANDI_STATE:  alumodule_resreg    = i_alumodule_data_A & i_alumodule_data_B;
            ALUM_ORI_STATE:   alumodule_resreg    = i_alumodule_data_A | i_alumodule_data_B;
            ALUM_XORI_STATE:  alumodule_resreg    = i_alumodule_data_A ^ i_alumodule_data_B;
            ALUM_LUI_STATE:   alumodule_resreg    = i_alumodule_data_B << 16;
            ALUM_SLTI_STATE:  alumodule_resreg    = (i_alumodule_data_A < i_alumodule_data_B) ? 1 : 0;
            ALUM_SLTIU_STATE: alumodule_resunsreg = (alumodule_dataAunswire < alumodule_dataBunswire) ? 1 : 0;
            default: begin
                alumodule_resreg    = alumodule_resreg;
                alumodule_resunsreg = alumodule_resunsreg;
            end
        endcase
    end

    assign alumodule_isunswire = (i_alumodule_OP == ALUM_ADDU_STATE) || (i_alumodule_OP == ALUM_SUBU_STATE) || (i_alumodule_OP == ALUM_SLTU_STATE)
    || (i_alumodule_OP == ALUM_SLTIU_STATE) || (i_alumodule_OP == ALUM_ADDIU_STATE);
    assign o_alumodule_data_RES = alumodule_isunswire ? alumodule_resunsreg : alumodule_resreg;


endmodule