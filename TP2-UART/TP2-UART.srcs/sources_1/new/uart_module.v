`timescale 1ns / 1ps

module uart_module
#(
    parameter NB_UARTMODULE_DATA    = 8,    // data bits
              SB_UARTMODULE_TICKS   = 16,   // stop bits ticks
              NB_UARTMODULE_COUNTER = 9,    // counter bits
              MOD_UARTMODULE_M      = 325   // ms counter bits
)
(
    input   wire    i_clk, i_reset,

    // baud rate generator
    input   wire    i_uartmodule_BRGTICKS,

    // receiver port
    input   wire    i_uartmodule_RX,
    output  wire    o_uartmodule_RXDONE,
    output  wire    [7:0] o_uartmodule_DOUT,

    // transmitter port
    input   wire    i_uartmodule_TXSTART,       // ver si estan bien los bits en este
    input   wire    [7:0] i_uartmodule_DIN,     // ver si estan bien los bits en este
    output  wire    o_uartmodule_TXDONE,
    output  wire    o_uartmodule_TX
);

//--------------- INICIALIZACION DE MODULOS --- start

baudrg_module #(
    .NB_BAUDRGMODULE_COUNTER(NB_UARTMODULE_COUNTER),
    .MOD_BAUDRGMODULE_M(MOD_UARTMODULE_M)
) baudrg_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .o_baudrgmodule_MAXTICK(),// VER ESTOO
    .o_baudrgmodule_RATE() // VER ESTOO
);


rx_module
#(
    .NB_RXMODULE_DATA(NB_UARTMODULE_DATA),
    .SB_RXMODULE_TICKS(SB_UARTMODULE_TICKS)
) rx_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_rxmodule_RX(i_uartmodule_RX),
    .i_rxmodule_BRGTICKS(i_uartmodule_BRGTICKS),
    .o_rxmodule_RXDONE(o_uartmodule_RXDONE),
    .o_rxmodule_DOUT(o_uartmodule_DOUT)
);

tx_module
#(
    .NB_TXMODULE_DATA(NB_UARTMODULE_DATA),
    .SB_TXMODULE_TICKS(SB_UARTMODULE_TICKS)
) tx_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_txmodule_TXSTART(i_uartmodule_TXSTART),
    .i_txmodule_BRGTICKS(i_uartmodule_BRGTICKS),
    .i_txmodule_DIN(i_uartmodule_DIN),
    .o_txmodule_TXDONE(o_uartmodule_TXDONE),
    .o_txmodule_TX(o_uartmodule_TX)
);


//--------------- INICIALIZACION DE MODULOS --- end


endmodule 