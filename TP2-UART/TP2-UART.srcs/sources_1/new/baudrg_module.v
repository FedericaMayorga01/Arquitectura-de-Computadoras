`timescale 1ns / 1ps

module baudrg_module 
#(
    parameter NB_BAUDRGMODULE_COUNTER = 9,      // number of bits in counter
    parameter MOD_BAUDRGMODULE_M      = 325     // mod-M . 9600 Baudios
)
(
    input   wire    i_clk, i_reset,
    output  wire    o_baudrgmodule_MAXTICK,                             //indica cuando el contador ha alcanzado su valor maximo
    output  wire    [NB_BAUDRGMODULE_COUNTER - 1 : 0] o_baudrgmodule_RATE   //valor actual del contador
);

//signal declaration
reg [NB_BAUDRGMODULE_COUNTER - 1 : 0] baudrgmodule_contreg; // registro que contiene el valor actual del contador

always @ (posedge i_clk)
    if(i_reset)
        baudrgmodule_contreg <= 1'b0;
    else
    if(baudrgmodule_contreg < MOD_BAUDRGMODULE_M[NB_BAUDRGMODULE_COUNTER - 1 : 0])
        baudrgmodule_contreg <= baudrgmodule_contreg + 1'b1;
    else
        baudrgmodule_contreg <= 1'b0;

assign o_baudrgmodule_RATE = baudrgmodule_contreg;
assign o_baudrgmodule_MAXTICK = (baudrgmodule_contreg == (MOD_BAUDRGMODULE_M - 1)) ? 1'b1 : 1'b0;

endmodule


