`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2024 17:33:56
// Design Name: 
// Module Name: tx_module
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


module tx_module
#(
    parameter   NB_TXMODULE_DATA  = 8, // txmodule_datastate bits
                SB_TXMODULE_TICKS = 16 // ticks for txmodule_stopstate bits(1 bit txmodule_stopstate)
)
(
    input   wire    i_clk, i_reset,
    input   wire    i_txmodule_TXSTART, i_txmodule_BRGTICKS,
    input   wire    [7:0] i_txmodule_DIN,
    output  reg     o_txmodule_TXDONE,
    output  wire    o_txmodule_TX
);

// symbolic state declaration
localparam [1:0]
    txmodule_idlestate  = 2'b00,
    txmodule_startstate = 2'b01,
    txmodule_datastate  = 2'b10,
    txmodule_stopstate  = 2'b11;

// signal declaration
reg [1:0] txmodule_statereg,    txmodule_nextstatereg;      // 2 bits ya que hay 4 estados, de 0 a 3
reg [3:0] txmodule_samptickreg, txmodule_sampticknextreg;   // 4 bits ya que hay que contar 16 bits, de 0 a 15
reg [2:0] txmodule_nbrecreg,    txmodule_nbrecnextreg;      // 3 bits ya que, son maximo 8: de 0 a 7
reg [7:0] txmodule_bitsreasreg, txmodule_bitsreasnextreg;   // 8 bits ya que esa es la cantidad de bits que manejamos

// body
// FSMD state & txmodule_datastate registers
always @( posedge i_clk, posedge i_reset)
    if (i_reset)
        begin
            txmodule_statereg    <= txmodule_idlestate;
            txmodule_samptickreg <= 0;
            txmodule_nbrecreg    <= 0;
            txmodule_bitsreasreg <= 0;
        end
    else
        begin
            txmodule_statereg    <= txmodule_nextstatereg;
            txmodule_samptickreg <= txmodule_sampticknextreg;
            txmodule_nbrecreg    <= txmodule_nbrecnextreg;
            txmodule_bitsreasreg <= txmodule_bitsreasnextreg;
        end

// FSMD next-state logic
always @(*)
    begin
        o_txmodule_TXDONE        = 1'b0;                    // salida en 0
        txmodule_nextstatereg    = txmodule_statereg;
        txmodule_sampticknextreg = txmodule_samptickreg;
        txmodule_nbrecnextreg    = txmodule_nbrecreg;
        txmodule_bitsreasnextreg = txmodule_bitsreasreg;

        case (txmodule_statereg)
            txmodule_idlestate :
                if (i_txmodule_TXSTART)
                    begin
                        txmodule_nextstatereg    = txmodule_startstate;
                        txmodule_sampticknextreg = 0;
                        txmodule_bitsreasnextreg = i_txmodule_DIN;
                    end

            txmodule_startstate :
                if (i_txmodule_BRGTICKS)
                    if (txmodule_samptickreg == 7) // (8 ticks)
                        begin
                            txmodule_nextstatereg    = txmodule_datastate;
                            txmodule_sampticknextreg = 0;
                            txmodule_nbrecnextreg    = 0;
                        end
                    else
                        txmodule_sampticknextreg     = txmodule_samptickreg + 1;
                    end //////////// No se si es necesario

            txmodule_datastate : 
                if (i_txmodule_BRGTICKS)
                    if (txmodule_samptickreg == 7)
                        begin
                            txmodule_sampticknextreg = 0;
                            txmodule_bitsreasnextreg = txmodule_bitsreasreg >> 1;
                            if (txmodule_nbrecreg == (NB_TXMODULE_DATA - 1))
                                txmodule_nextstatereg = txmodule_stopstate;
                            else
                                txmodule_nbrecnextreg = txmodule_nbrecreg + 1;
                        end
                    else
                        txmodule_sampticknextreg = txmodule_samptickreg + 1;
                    end //////////// No se si es necesario

            txmodule_stopstate :
                if (i_txmodule_BRGTICKS)
                    if (txmodule_samptickreg == (SB_TXMODULE_TICKS - 1))
                    begin
                        txmodule_nextstatereg = txmodule_idlestate;
                    end
                else
                    txmodule_sampticknextreg = txmodule_samptickreg + 1;
                end
        endcase
    end

// output 
assign o_txmodule_TX = ????

endmodule
