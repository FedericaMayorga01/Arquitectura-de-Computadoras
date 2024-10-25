`timescale 1ns / 1ps

module rx_module #(
    parameter NB_RXMODULE_DATA = 8,
    parameter SB_RXMODULE_TICKS = 16
)(
    input wire                         i_clk,
    input wire                         i_reset,
    input wire                         i_rxmodule_RX,
    input wire                         i_rxmodule_BRGTICKS,

    output reg                         o_rxmodule_RXDONE,
    output wire [NB_RXMODULE_DATA-1:0] o_rxmodule_DOUT
);

// FSM stages
localparam [1:0] RXM_IDLE_STATE  = 2'b00;
localparam [1:0] RXM_START_STATE = 2'b01;
localparam [1:0] RXM_DATA_STATE  = 2'b10;
localparam [1:0] RXM_STOP_STATE  = 2'b11;

// Signal declaration
reg [1:0]                  rxmodule_statereg,    rxmodule_nextstatereg;
reg [3:0]                  rxmodule_samptickreg, rxmodule_nextsamptickreg;  // ticks count
reg [2:0]                  rxmodule_nbrecreg,    rxmodule_nextnbrecreg;     // bits count
reg [NB_RXMODULE_DATA-1:0] rxmodule_bitsreasreg, rxmodule_nextbitsreasreg;

// Finite State Machine with DATA (state and DATA registers)
always @(posedge i_clk) begin
    if (i_reset) begin
        rxmodule_statereg    <= RXM_IDLE_STATE;
        rxmodule_samptickreg <= 0;
        rxmodule_nbrecreg    <= 0;
        rxmodule_bitsreasreg <= 0;
    end
    else begin
        rxmodule_statereg    <= rxmodule_nextstatereg;
        rxmodule_samptickreg <= rxmodule_nextsamptickreg;
        rxmodule_nbrecreg    <= rxmodule_nextnbrecreg;
        rxmodule_bitsreasreg <= rxmodule_nextbitsreasreg;
    end
end

// Finite State Machine with DATA (next state logic)
always @(*) begin
    rxmodule_nextstatereg    = rxmodule_statereg;
    o_rxmodule_RXDONE        = 1'b0;
    rxmodule_nextsamptickreg = rxmodule_samptickreg;
    rxmodule_nextnbrecreg    = rxmodule_nbrecreg;
    rxmodule_nextbitsreasreg = rxmodule_bitsreasreg;

    case (rxmodule_statereg)
        RXM_IDLE_STATE:
            if (~i_rxmodule_RX)
            begin
               rxmodule_nextstatereg    = RXM_START_STATE;
               rxmodule_nextsamptickreg = 0;
            end

        RXM_START_STATE:
            if (i_rxmodule_BRGTICKS)
            begin
                if (rxmodule_samptickreg == 7) begin
                    rxmodule_nextstatereg    = RXM_DATA_STATE;
                    rxmodule_nextsamptickreg = 0;
                    rxmodule_nextnbrecreg    = 0;
                end
                else begin
                    rxmodule_nextsamptickreg = rxmodule_samptickreg + 1;
                end

            end

        RXM_DATA_STATE:
            if (i_rxmodule_BRGTICKS) begin
                if (rxmodule_samptickreg == 15) begin
                    rxmodule_nextsamptickreg = 0;
                    rxmodule_nextbitsreasreg = {i_rxmodule_RX, rxmodule_bitsreasreg[NB_RXMODULE_DATA-1:1]};
                    if (rxmodule_nbrecreg == (NB_RXMODULE_DATA-1)) begin
                        rxmodule_nextstatereg = RXM_STOP_STATE;
                    end
                    else begin
                        rxmodule_nextnbrecreg = rxmodule_nbrecreg + 1;
                    end

                end
                else begin
                    rxmodule_nextsamptickreg = rxmodule_samptickreg + 1;
                end

            end

        RXM_STOP_STATE:
            if (i_rxmodule_BRGTICKS) begin
                if (rxmodule_samptickreg == (SB_RXMODULE_TICKS-1)) begin
                    rxmodule_nextstatereg = RXM_IDLE_STATE;
                    if(i_rxmodule_RX) begin
                        o_rxmodule_RXDONE = 1'b1;
                    end
                end
                else begin
                    rxmodule_nextsamptickreg = rxmodule_samptickreg + 1;
                end
            end

        default:
            rxmodule_nextstatereg = RXM_IDLE_STATE;
    endcase
end

// Output
assign o_rxmodule_DOUT = rxmodule_bitsreasreg;

endmodule