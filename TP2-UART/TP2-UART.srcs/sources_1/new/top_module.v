`timescale 1ns / 1ps

module top_module
#(
    parameter NB_UARTMODULE_DATA    = 8,    // data bits
              SB_UARTMODULE_TICKS   = 16,   // stop bits ticks
              NB_UARTMODULE_COUNTER = 9,    // counter bits
              MOD_UARTMODULE_M      = 325,  // ms counter bits
              NB_UARTMODULE_ADDR    = 4     // address bits
)
(
    input  wire    i_clk, i_reset,

    // receiver port
    input  wire    i_topmodule_RX,

    // transmitter port
    output wire    o_topmodule_TX

    // FIFO RX ports
//    input  wire i_uartmodule_fiforx_READ,
//    output wire signed [NB_UARTMODULE_DATA-1:0] o_uartmodule_fiforx_READDATA,
//    output wire o_uartmodule_fiforx_EMPTY,

    // FIFO TX ports
//    input  wire signed [NB_UARTMODULE_DATA-1:0] i_uartmodule_fifotx_WRITEDATA,
//    input  wire i_uartmodule_fifotx_WRITE,
//    output wire o_uartmodule_fifotx_FULL

);

// Señal interna para el baud rate generator
wire uartmodule_maxtickwire;
// Señal interna para el UART Rx
wire  uartmodule_rxdonewire;
wire signed [NB_UARTMODULE_DATA-1:0] uartmodule_doutwire;
// Señal interna para el UART Tx
wire  uartmodule_txdonewire;
// Señal interna para el FIFO TX
wire signed [NB_UARTMODULE_DATA-1:0] uartmodule_readdatawire;
wire  uartmodule_emptywire;

//--------------- INICIALIZACION DE MODULOS --- start

baudrg_module #(
    .NB_BAUDRGMODULE_COUNTER(NB_UARTMODULE_COUNTER),
    .MOD_BAUDRGMODULE_M(MOD_UARTMODULE_M)
) baudrg_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .o_baudrgmodule_MAXTICK(uartmodule_maxtickwire),
    .o_baudrgmodule_RATE()                        // No se usa momentaneamente
);

rx_module #(
    .NB_RXMODULE_DATA(NB_UARTMODULE_DATA),
    .SB_RXMODULE_TICKS(SB_UARTMODULE_TICKS)
) rx_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_rxmodule_RX(i_topmodule_RX),
    .i_rxmodule_BRGTICKS(uartmodule_maxtickwire),
    .o_rxmodule_RXDONE(uartmodule_rxdonewire),
    .o_rxmodule_DOUT(uartmodule_doutwire)
);

tx_module #(
    .NB_TXMODULE_DATA(NB_UARTMODULE_DATA),
    .SB_TXMODULE_TICKS(SB_UARTMODULE_TICKS)
) tx_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_txmodule_TXSTART(~uartmodule_emptywire),
    .i_txmodule_BRGTICKS(uartmodule_maxtickwire),
    .i_txmodule_DIN(uartmodule_readdatawire),
    .o_txmodule_TXDONE(uartmodule_txdonewire),
    .o_txmodule_TX(o_topmodule_TX)
);

fifo_module #(
    .NB_FIFOMODULE_DATA(NB_UARTMODULE_DATA),
    .NB_FIFOMODULE_ADDR(NB_UARTMODULE_ADDR)
) fifotx_module (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_fifomodule_READ(uartmodule_txdonewire),
    .i_fifomodule_WRITE(uartmodule_rxdonewire),
    .i_fifomodule_WRITEDATA(uartmodule_doutwire),
    .o_fifomodule_EMPTY(uartmodule_emptywire),
    .o_fifomodule_FULL(),
    .o_fifomodule_READATA(uartmodule_readdatawire)
);

//--------------- INICIALIZACION DE MODULOS --- end

endmodule
