module top_module #
(
    parameter NB_TOPMODULE_DATA    = 8,
    parameter SB_TOPMODULE_TICKS   = 16,
    parameter MOD_TOPMODULE_M      = 326,
    parameter NB_TOPMODULE_COUNTER = 9,
    parameter NB_TOPMODULE_OP      = 6,
    parameter PTR_LEN = 2 // <-- REVISAR
)(
    input wire i_clk,
    input wire i_reset,
    input wire i_topmodule_RX,

    output wire o_topmodule_TX
    //output wire [NB_DATA-1:0] result_leds
);


wire                         topmodule_fulltxwire;
wire                         topmodule_emptyrxwire;
wire [NB_TOPMODULE_DATA-1:0] topmodule_readdatarxwire;


wire topmodule_readinterfacewire;
wire topmodule_writeinterfacewire;
wire [NB_TOPMODULE_DATA-1:0] topmodule_writedatainterfacewire;
wire [NB_TOPMODULE_OP-1:0]   topmodule_opwire;
wire [NB_TOPMODULE_DATA-1:0] topmodule_dataawire;
wire [NB_TOPMODULE_DATA-1:0] topmodule_databwire;

wire [NB_TOPMODULE_DATA-1:0] topmodule_datareswire;

assign result_leds = topmodule_datareswire;

//--------------- INICIALIZACION DE MODULOS ---------------

uart_module #
(
    .NB_UARTMODULE_DATA(NB_TOPMODULE_DATA),
    .SB_UARTMODULE_TICKS(SB_TOPMODULE_TICKS),
    .MOD_UARTMODULE_M(MOD_TOPMODULE_M),
    .NNB_UARTMODULE_COUNTER(NB_TOPMODULE_COUNTER),
    .PTR_LEN(PTR_LEN) // <-- REVISAR
) uart_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_uartmodule_fiforx_READ(topmodule_readinterfacewire),
    .i_uartmodule_fifotx_WRITE(topmodule_writeinterfacewire),
    .i_uartmodule_RX(i_topmodule_RX),
    .i_uartmodule_fifotx_WRITEDATA(topmodule_writedatainterfacewire),

    .o_uartmodule_fifotx_FULL(topmodule_fulltxwire),
    .o_uartmodule_fiforx_EMPTY(topmodule_emptyrxwire),
    .o_uartmodule_TX(o_topmodule_TX),
    .o_uartmodule_fiforx_READDATA(topmodule_readdatarxwire)
);

interface_module #
(
    .NB_INTERFACEMODULE_DATA(NB_TOPMODULE_DATA),
    .NB_INTERFACEMODULE_OP(NB_TOPMODULE_OP)
) interface_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_interfacemodule_DATARES(topmodule_datareswire),
    .i_interfacemodule_READDATA(topmodule_readdatarxwire),
    .i_interfacemodule_EMPTY(topmodule_emptyrxwire),
    .i_interfacemodule_FULL(topmodule_fulltxwire),

    .o_interfacemodule_READ(topmodule_readinterfacewire),
    .o_interfacemodule_WRITE(topmodule_writeinterfacewire),
    .o_interfacemodule_WRITEDATA(topmodule_writedatainterfacewire),
    .o_interfacemodule_OP(topmodule_opwire),
    .o_interfacemodule_DATAA(topmodule_dataawire),
    .o_interfacemodule_DATAB(topmodule_databwire),
    .o_is_valid() // <-- REVISAR
);

alu_module #
(
    .NB_ALUMODULE_DATA(NB_TOPMODULE_DATA),
    .NB_ALUMODULE_OP(NB_TOPMODULE_OP)
) alu_module_1 (
    .i_alumodule_data_A(topmodule_dataawire),
    .i_alumodule_data_B(topmodule_databwire),
    .i_alumodule_OP(topmodule_opwire),
    .o_alumodule_data_RES(topmodule_datareswire)
);

endmodule
