`timescale 1ns / 1ps

module top_module
#(
    parameter NB_TOPMODULE_DATA    = 8,     // data bits
              NB_TOPMODULE_OP      = 6,
              SB_TOPMODULE_TICKS   = 16,   // stop bits ticks
              NB_TOPMODULE_COUNTER = 9,    // counter bits
              MOD_TOPMODULE_M      = 325,  // ms counter bits
              NB_TOPMODULE_ADDR    = 4,
              NB_TOPMODULE_DATA = 8,
              NB_TOPMODULE_OP = 6

)
(
    input wire i_clk,
    input wire i_reset,
    input wire i_topmodule_RX,
    output wire o_topmodule_TX
    //output wire [3:0] o_topmodule_leds // boton 0 para data A, boton 1 para data B, boton 2 para OP, boton 3 para reset

);

wire signed [NB_TOPMODULE_DATA-1:0] topmodule_readdatarxwire;
wire topmodule_emptyrxwire;
wire topmodule_fulltxwire;
wire topmodule_readinterfacewire;
wire signed [NB_TOPMODULE_DATA-1:0] topmodule_writedatainterfacewire;
wire topmodule_writeinterfacewire;
wire signed [NB_TOPMODULE_DATA-1:0] topmodule_dataawire;
wire signed [NB_TOPMODULE_DATA-1:0] topmodule_databwire;
wire [NB_TOPMODULE_OP-1:0] topmodule_opwire;
wire signed [NB_TOPMODULE_DATA-1:0] topmodule_datareswire;

//--------------- INICIALIZACION DE MODULOS --- start
alu_module #(
    .NB_ALUMODULE_DATA(NB_TOPMODULE_DATA),
    .NB_ALUMODULE_OP(NB_TOPMODULE_OP)
) alu_module_1 (
    .i_alumodule_data_A(topmodule_dataawire),
    .i_alumodule_data_B(topmodule_databwire),
    .i_alumodule_OP(topmodule_opwire),
    .o_alumodule_data_RES(topmodule_datareswire),
    .o_alumodule_ZERO(),                // no asignar por ahora
    .o_alumodule_NEGATIVE(),            // no asignar por ahora
    .o_alumodule_CARRY()                // no asignar por ahora
);


uart_module #(
    .NB_UARTMODULE_DATA(NB_TOPMODULE_DATA),
    .SB_UARTMODULE_TICKS(SB_TOPMODULE_TICKS),
    .NB_UARTMODULE_COUNTER(NB_TOPMODULE_COUNTER),
    .MOD_UARTMODULE_M(MOD_TOPMODULE_M),
    .NB_UARTMODULE_ADDR(NB_TOPMODULE_ADDR)
) uart_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_uartmodule_RX(i_topmodule_RX),
    .i_uartmodule_fiforx_READ(topmodule_readinterfacewire),
    .i_uartmodule_fifotx_WRITEDATA(topmodule_writedatainterfacewire),
    .i_uartmodule_fifotx_WRITE(topmodule_writeinterfacewire),
    .o_uartmodule_TX(o_topmodule_TX),
    .o_uartmodule_fiforx_READDATA(topmodule_readdatarxwire),
    .o_uartmodule_fiforx_EMPTY(topmodule_emptyrxwire),
    .o_uartmodule_fifotx_FULL(topmodule_fulltxwire)
);

interface_module #(
    .NB_INTERFACEMODULE_DATA(NB_TOPMODULE_DATA),
    .NB_INTERFACEMODULE_OP(NB_TOPMODULE_OP)
) interface_module_1(
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_interfacemodule_EMPTY(topmodule_emptyrxwire),
    .i_interfacemodule_FULL(topmodule_fulltxwire),
    .i_interfacemodule_READDATA(topmodule_readdatarxwire),
    .i_interfacemodule_DATARES(topmodule_datareswire),
    .o_interfacemodule_READ(topmodule_readinterfacewire),
    .o_interfacemodule_WRITE(topmodule_writeinterfacewire),
    .o_interfacemodule_WRITEDATA(topmodule_writedatainterfacewire),
    .o_interfacemodule_DATAA(topmodule_dataawire),
    .o_interfacemodule_DATAB(topmodule_databwire),
    .o_interfacemodule_OP(topmodule_opwire)
);

// --------------- INICIALIZACION DE MODULOS ---end

// always @(posedge i_clk)begin
//        if(i_reset)begin
//            o_topmodule_leds[0] <= 1'b1;
//        end
//        else begin
//            o_topmodule_leds[0] <= 1'b0;  // Apaga el LED 0 cuando se suelta el reset
//        end
// end

endmodule
