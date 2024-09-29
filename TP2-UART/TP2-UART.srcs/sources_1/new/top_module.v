`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.09.2024 18:58:14
// Design Name: 
// Module Name: top_module
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


module top_module
#(
    parameter NB_TOPMODULE_DATA = 8,
              NB_TOPMODULE_OP = 6
)
(    
    input wire i_clk,
    input wire i_modtop_reset,
    input wire i_topmodule_RX,
    output wire i_topmodule_TX

);

//--------------- INICIALIZACION DE MODULOS --- start
alu_module #(
    .NB_ALUMODULE_DATA(NB_TOPMODULE_DATA),
    .NB_ALUMODULE_OP(NB_TOPMODULE_OP)
) alu_module_1 (
    .i_alumodule_data_A(),
    .i_alumodule_data_B(),
    .i_alumodule_OP(),
    .o_alumodule_data_RES()
    // VER SI AGREGAR LOS DEMAS PUERTOS QUE FALTAN
);

// ACA INICIALIZAR UART

// ACA INICIALIZAR INTERFACE

//--------------- INICIALIZACION DE MODULOS --- end



endmodule
