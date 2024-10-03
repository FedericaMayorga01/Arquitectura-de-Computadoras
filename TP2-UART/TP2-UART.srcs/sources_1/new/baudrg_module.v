`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2024 17:36:05
// Design Name: 
// Module Name: baudrg_module
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

module baudrg_module 
#(
    parameter NB_BAUDRGMODULE_COUNTER = 9,      // number of bits in counter
    parameter MOD_BAUDRGMODULE_M      = 325     // mod-M . 9600 Baudios
)
(
    input   wire    i_clk, i_reset,
    output  wire    o_baudrgmodule_MAXTICK,                             //indica cu�ndo el contador ha alcanzado su valor m�ximo
    output  wire    [NB_BAUDRGMODULE_COUNTER - 1 : 0] o_baudrgmodule_RATE   //valor actual del contador
);

//signal declaration
reg [NB_BAUDRGMODULE_COUNTER - 1 : 0] baudrgmodule_cont; // registro que contiene el valor actual del contador

always @ (posedge i_clk, posedge i_reset)
    if(i_reset)
        baudrgmodule_cont <= 1'b0;
    else
    if(baudrgmodule_cont < MOD_BAUDRGMODULE_M[NB_BAUDRGMODULE_COUNTER - 1 : 0])
        baudrgmodule_cont <= baudrgmodule_cont + 1'b1;
    else
        baudrgmodule_cont <= 1'b0;

assign o_baudrgmodule_RATE = baudrgmodule_cont;
assign o_baudrgmodule_MAXTICK = (baudrgmodule_cont == (MOD_BAUDRGMODULE_M - 1)) ? 1'b1 : 1'b0;

endmodule


