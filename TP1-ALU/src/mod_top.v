`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// TP1 ALU - Modulo ALU
// Mayorga - Segura
//
// Create Date: 12.09.2024 16:36:40
// Module Name: mod_top
//////////////////////////////////////////////////////////////////////////////////


module top_module
#
(
    parameter NB_MODTOP_DATA = 8,
    parameter NB_MODTOP_OP   = 6,
    parameter NB_MODTOP_BUT  = 3
)
(
    input   wire                        i_clk,
    input   wire                        i_modtop_reset,
    input   wire [NB_MODTOP_DATA-1:0]   i_modtop_sw,
    input   wire [NB_MODTOP_BUT-1:0]    i_modtop_but,
    output  wire [NB_MODTOP_DATA-1:0]   o_modtop_leds
);

// Declaración de señales internas
    reg signed [NB_MODTOP_DATA-1:0] i_modtop_data_A;
    reg signed [NB_MODTOP_DATA-1:0] i_modtop_data_B;
    reg        [NB_MODTOP_OP-1:0]   i_modtop_OP;

// Instancia del módulo ALU
mod_ALU #(
    .NB_MODALU_DATA(NB_MODTOP_DATA),
    .NB_MODALU_OP(NB_MODTOP_OP)
) mod_ALU_1 (
    .i_modALU_data_A(i_modtop_data_A),     
    .i_modALU_data_B(i_modtop_data_B),
    .i_modALU_OP(i_modtop_OP),
    .o_modALU_data_RES(o_modtop_leds)
);

always @(posedge i_clk)begin
        if(i_modtop_reset)begin
            i_modtop_data_A <= {NB_MODTOP_DATA{1'b0}};
            i_modtop_data_B <= {NB_MODTOP_DATA{1'b0}};
            i_modtop_OP     <= {NB_MODTOP_OP{1'b0}};
        end     
        else    
        if(i_modtop_but[0])                                 // Corresponde al pulsador 1
            i_modtop_data_A <= i_modtop_sw;
        if(i_modtop_but[1])                                 // Corresponde al pulsador 2
            i_modtop_data_B <= i_modtop_sw;
        if(i_modtop_but[2])                                 // Corresponde al pulsador 3
            i_modtop_OP <= i_modtop_sw [NB_MODTOP_OP-1:0];  // Se realiza el truncamiento
end

endmodule
