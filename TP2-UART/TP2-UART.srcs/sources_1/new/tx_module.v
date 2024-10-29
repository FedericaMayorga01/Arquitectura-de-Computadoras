module tx_module #
(
    parameter NB_TXMODULE_DATA  = 8,
    parameter SB_TXMODULE_TICKS = 16
)(
    input wire                          i_clk,
    input wire                          i_reset,
    input wire                          i_txmodule_TXSTART,
    input wire                          i_txmodule_BRGTICKS,
    input wire [NB_TXMODULE_DATA-1 : 0] i_txmodule_DIN,

    output reg                          o_txmodule_TXDONE,
    output wire                         o_txmodule_TX
);

localparam [1:0] TXM_IDLE_STATE  = 2'b00;
localparam [1:0] TXM_START_STATE = 2'b01;
localparam [1:0] TXM_DATA_STATE  = 2'b10;
localparam [1:0] TXM_STOP_STATE  = 2'b11;

reg [1:0]                  txmodule_statereg,    txmodule_nextstatereg;
reg [3:0]                  txmodule_samptickreg, txmodule_nextsamptickreg;
reg [2:0]                  txmodule_nbrecreg,    txmodule_nextnbrecreg;
reg [NB_TXMODULE_DATA-1:0] txmodule_bitsreasreg, txmodule_nextbitsreasreg;
reg                        txmodule_reg,         txmodule_nextreg;

always @(posedge i_clk) begin
    if(i_reset) begin
        txmodule_statereg    <= TXM_IDLE_STATE;
        txmodule_samptickreg <= 0;
        txmodule_nbrecreg    <= 0;
        txmodule_bitsreasreg <= 0;
        txmodule_reg         <= 1'b1;
    end
    else begin
        txmodule_statereg    <= txmodule_nextstatereg;
        txmodule_samptickreg <= txmodule_nextsamptickreg;
        txmodule_nbrecreg    <= txmodule_nextnbrecreg;
        txmodule_bitsreasreg <= txmodule_nextbitsreasreg;
        txmodule_reg         <= txmodule_nextreg;
    end
end

always @(*) begin
    txmodule_nextstatereg    = txmodule_statereg;
    o_txmodule_TXDONE        = 1'b0;
    txmodule_nextsamptickreg = txmodule_samptickreg;
    txmodule_nextnbrecreg    = txmodule_nbrecreg;
    txmodule_nextbitsreasreg = txmodule_bitsreasreg;
    txmodule_nextreg         = txmodule_reg;

    case (txmodule_statereg)
        TXM_IDLE_STATE: begin
            txmodule_nextreg = 1'b1;
            if(i_txmodule_TXSTART) begin
                txmodule_nextstatereg    = TXM_START_STATE;
                txmodule_nextsamptickreg = 0;
                txmodule_nextbitsreasreg = i_txmodule_DIN;
            end
        end

        TXM_START_STATE: begin
            txmodule_nextreg = 1'b0;
            if (i_txmodule_BRGTICKS) begin
                if (txmodule_samptickreg == 15) begin
                    txmodule_nextstatereg    = TXM_DATA_STATE;
                    txmodule_nextsamptickreg = 0;
                    txmodule_nextnbrecreg    = 0;
                end
                else begin
                    txmodule_nextsamptickreg = txmodule_samptickreg + 1;
                end
            end
        end

        TXM_DATA_STATE: begin
            txmodule_nextreg = txmodule_bitsreasreg[0];
            if (i_txmodule_BRGTICKS) begin
                if(txmodule_samptickreg == 15) begin
                    txmodule_nextsamptickreg = 0;
                    txmodule_nextbitsreasreg = txmodule_bitsreasreg >> 1;
                    if (txmodule_nbrecreg == (NB_TXMODULE_DATA-1)) begin
                    txmodule_nextstatereg = TXM_STOP_STATE;
                    end
                    else begin
                        txmodule_nextnbrecreg = txmodule_nbrecreg + 1;
                    end
                end
                else begin
                    txmodule_nextsamptickreg = txmodule_samptickreg + 1;
                end
            end
        end

        TXM_STOP_STATE: begin
            txmodule_nextreg = 1'b1;
            if (i_txmodule_BRGTICKS) begin
                if (txmodule_samptickreg == (SB_TXMODULE_TICKS-1)) begin
                    txmodule_nextstatereg = TXM_IDLE_STATE;
                    o_txmodule_TXDONE     = 1'b1;
                end
                else begin
                    txmodule_nextsamptickreg = txmodule_samptickreg + 1;
                end
            end
        end
        default: begin
            txmodule_nextstatereg = TXM_IDLE_STATE;
        end
    endcase
end

assign o_txmodule_TX = txmodule_reg;

endmodule
