`timescale 1ns / 1ps

module uart_module
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
    input  wire    i_uartmodule_RX,

    // transmitter port
    output wire    o_uartmodule_TX,

    // FIFO RX ports
    input  wire i_uartmodule_fiforx_READ,
    output wire i_uartmodule_fiforx_READDATA,
    output wire o_uartmodule_fiforx_fifo_EMPTY,

    // FIFO TX ports
    input  wire i_uartmodule_fifotx_WRITEDATA,
    input  wire i_uartmodule_fifotx_WRITE,
    output wire o_uartmodule_fifotx_fifo_FULL

);

// Señal interna para el baud rate generator
wire uartmodule_maxtick;
// Señal interna para el UART Rx
wire  o_uartmodule_rxdone;
wire  [7:0] o_uartmodule_dout;
// Señal interna para el UART Tx
wire  o_uartmodule_txdone;
// Señal interna para el FIFO TX
wire  o_uartmodule_readdata;
wire  o_uartmodule_fifo_empty;

//--------------- INICIALIZACION DE MODULOS --- start

baudrg_module #(
    .NB_BAUDRGMODULE_COUNTER(NB_UARTMODULE_COUNTER),
    .MOD_BAUDRGMODULE_M(MOD_UARTMODULE_M)
) baudrg_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .o_baudrgmodule_MAXTICK(uartmodule_maxtick),
    .o_baudrgmodule_RATE()                        // No se usa momentaneamente
);

rx_module #(
    .NB_RXMODULE_DATA(NB_UARTMODULE_DATA),
    .SB_RXMODULE_TICKS(SB_UARTMODULE_TICKS)
) rx_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_rxmodule_RX(i_uartmodule_RX),
    .i_rxmodule_BRGTICKS(uartmodule_maxtick),
    .o_rxmodule_RXDONE(o_uartmodule_rxdone),
    .o_rxmodule_DOUT(o_uartmodule_dout)
);

fifo_rx_module #(
    .NB_FIFOMODULE_DATA(NB_UARTMODULE_DATA),
    .NB_FIFOMODULE_ADDR(NB_UARTMODULE_ADDR)
) fifo_rx_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_fiforxmodule_read(i_uartmodule_fiforx_READ),
    .i_fiforxmodule_write(o_uartmodule_rxdone),
    .i_fiforxmodule_writedata(o_uartmodule_dout),
    .o_fiforxmodule_fifo_empty(o_uartmodule_fiforx_fifo_EMPTY),
    .o_fiforxmodule_fifo_full(),
    .o_fiforxmodule_readdata(i_uartmodule_fiforx_READDATA)
);

tx_module #(
    .NB_TXMODULE_DATA(NB_UARTMODULE_DATA),
    .SB_TXMODULE_TICKS(SB_UARTMODULE_TICKS)
) tx_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_txmodule_TXSTART(~o_uartmodule_fifo_empty),
    .i_txmodule_BRGTICKS(uartmodule_maxtick),
    .i_txmodule_DIN(o_uartmodule_readdata),
    .o_txmodule_TXDONE(o_uartmodule_txdone),
    .o_txmodule_TX(o_uartmodule_TX)
);

fifo_tx_module #(
    .NB_FIFOMODULE_DATA(NB_UARTMODULE_DATA),
    .NB_FIFOMODULE_ADDR(NB_UARTMODULE_ADDR)
) fifo_tx_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_fifotxmodule_read(o_uartmodule_txdone),
    .i_fifotxmodule_write(i_uartmodule_fifotx_WRITE),
    .i_fifotxmodule_writedata(i_uartmodule_fifotx_WRITEDATA),
    .o_fifotxmodule_fifo_empty(o_uartmodule_fifo_empty),
    .o_fifotxmodule_fifo_full(o_uartmodule_fifotx_fifo_FULL),
    .o_fifotxmodule_readdata(o_uartmodule_readdata)
);

//--------------- INICIALIZACION DE MODULOS --- end

endmodule