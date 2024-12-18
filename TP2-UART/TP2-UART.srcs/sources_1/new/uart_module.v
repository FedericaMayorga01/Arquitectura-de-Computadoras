module uart_module #
(
    parameter NB_UARTMODULE_DATA    = 8,
    parameter SB_UARTMODULE_TICKS   = 16,
    parameter MOD_UARTMODULE_M      = 163,
    parameter NB_UARTMODULE_COUNTER = 9,
    parameter NB_UARTMODULE_ADDR    = 4
)(
    input  wire                            i_clk,
    input  wire                            i_reset,
    input  wire                            i_uartmodule_fiforx_READ,
    input  wire                            i_uartmodule_fifotx_WRITE,
    input  wire                            i_uartmodule_RX,
    input  wire [NB_UARTMODULE_DATA-1 : 0] i_uartmodule_fifotx_WRITEDATA,

    output wire                            o_uartmodule_fifotx_FULL,
    output wire                            o_uartmodule_fiforx_EMPTY,
    output wire                            o_uartmodule_TX,
    output wire [NB_UARTMODULE_DATA-1 : 0] o_uartmodule_fiforx_READDATA
);

wire                            uartmodule_maxtickwire;
wire                            uartmodule_txdonewire;
wire                            uartmodule_emptywire;
wire                            uartmodule_rxdonewire;
wire [NB_UARTMODULE_DATA-1 : 0] uartmodule_readdatawire;
wire [NB_UARTMODULE_DATA-1 : 0] uartmodule_doutwire;


baudrg_module#
(
    .MOD_BAUDRGMODULE_M(MOD_UARTMODULE_M),
    .NB_BAUDRGMODULE_COUNTER(NB_UARTMODULE_COUNTER)
) baudrg_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .o_baudrgmodule_MAXTICK(uartmodule_maxtickwire)
);

rx_module #
(
    .NB_RXMODULE_DATA(NB_UARTMODULE_DATA),
    .SB_RXMODULE_TICKS(SB_UARTMODULE_TICKS)
) rx_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_rxmodule_RX(i_uartmodule_RX),
    .i_rxmodule_BRGTICKS(uartmodule_maxtickwire),
    .o_rxmodule_RXDONE(uartmodule_rxdonewire),
    .o_rxmodule_DOUT(uartmodule_doutwire)
);

fifo_module #
(
    .NB_FIFOMODULE_DATA(NB_UARTMODULE_DATA),
    .NB_FIFOMODULE_ADDR(NB_UARTMODULE_ADDR)
) fiforx_module (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_fifomodule_READ(i_uartmodule_fiforx_READ),
    .i_fifomodule_WRITE(uartmodule_rxdonewire),
    .i_fifomodule_WRITEDATA(uartmodule_doutwire),
    .o_fifomodule_EMPTY(o_uartmodule_fiforx_EMPTY),
    .o_fifomodule_FULL(),
    .o_fifomodule_READATA(o_uartmodule_fiforx_READDATA)
);

fifo_module #
(
    .NB_FIFOMODULE_DATA(NB_UARTMODULE_DATA),
    .NB_FIFOMODULE_ADDR(NB_UARTMODULE_ADDR)
) fifotx_module (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_fifomodule_READ(uartmodule_txdonewire),
    .i_fifomodule_WRITE(i_uartmodule_fifotx_WRITE),
    .i_fifomodule_WRITEDATA(i_uartmodule_fifotx_WRITEDATA),
    .o_fifomodule_EMPTY(uartmodule_emptywire),
    .o_fifomodule_FULL(o_uartmodule_fifotx_FULL),
    .o_fifomodule_READATA(uartmodule_readdatawire)
);

tx_module #
(
    .NB_TXMODULE_DATA(NB_UARTMODULE_DATA),
    .SB_TXMODULE_TICKS(SB_UARTMODULE_TICKS)
) tx_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_txmodule_TXSTART(~uartmodule_emptywire),
    .i_txmodule_BRGTICKS(uartmodule_maxtickwire),
    .i_txmodule_DIN(uartmodule_readdatawire),
    .o_txmodule_TXDONE(uartmodule_txdonewire),
    .o_txmodule_TX(o_uartmodule_TX)
);

endmodule
