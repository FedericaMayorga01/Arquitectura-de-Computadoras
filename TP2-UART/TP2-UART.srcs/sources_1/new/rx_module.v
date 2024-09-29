`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.09.2024 17:26:26
// Design Name: 
// Module Name: rx_module
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


module rx_module 
#(
    parameter NB_RXMODULE_DATA = 8, // # rxmodule_datastate bits 
    SB_RXMODULE_TICKS = 16 // # ticks for rxmodule_stopstate bits(1 bit rxmodule_stopstate)
)
(
   input wire i_clk, i_reset, 
   input wire i_rxmodule_RX, i_rxmodule_BRGTICKS, 
   output reg o_rxmodule_RXDONE, 
   output wire [7:0] o_rxmodule_DOUT 
);

// symbolic state declaration 
localparam [1:0]
   rxmodule_idlestate = 2'b00, 
   rxmodule_startstate = 2'b01, 
   rxmodule_datastate = 2'b10, 
   rxmodule_stopstate = 2'b11; 

// signal declaration 
reg [1:0] rxmodule_regstate , rxmodule_nextstate ; 
reg [3:0] rxmodule_samptickreg , rxmodule_sampticknextreg ; 
reg [2:0] rxmodule_nbrecreg , rxmodule_nbrecnextreg ; 
reg [7:0] rxmodule_bitsreasreg , rxmodule_bitsreasnextreg ; 

// body
// FSMD state & rxmodule_datastate registers 
always @( posedge i_clk , posedge i_reset) 
   if (i_reset)
      begin 
         rxmodule_regstate <= rxmodule_idlestate; 
         rxmodule_samptickreg <= 0; 
         rxmodule_nbrecreg <= 0; 
         rxmodule_bitsreasreg <= 0; 
      end 
   else 
      begin 
         rxmodule_regstate <= rxmodule_nextstate ; 
         rxmodule_samptickreg <= rxmodule_sampticknextreg; 
         rxmodule_nbrecreg <= rxmodule_nbrecnextreg; 
         rxmodule_bitsreasreg <= rxmodule_bitsreasnextreg; 
      end 

// FSMD next-state logic 
always @(*)
   begin 
      rxmodule_nextstate = rxmodule_regstate ; 
      o_rxmodule_RXDONE = 1'b0; 
      rxmodule_sampticknextreg = rxmodule_samptickreg; 
      rxmodule_nbrecnextreg = rxmodule_nbrecreg; 
      rxmodule_bitsreasnextreg = rxmodule_bitsreasreg; 
      case (rxmodule_regstate) 
         rxmodule_idlestate : 
            if (~i_rxmodule_RX) 
               begin 
                  rxmodule_nextstate = rxmodule_startstate ; 
                  rxmodule_sampticknextreg = 0; 
               end 
         rxmodule_startstate : 
            if (i_rxmodule_BRGTICKS) 
               if (rxmodule_samptickreg==7) 
                  begin 
                     rxmodule_nextstate = rxmodule_datastate; 
                     rxmodule_sampticknextreg = 0; 
                     rxmodule_nbrecnextreg = 0; 
                  end 
               else 
                  rxmodule_sampticknextreg = rxmodule_samptickreg + 1; 
         rxmodule_datastate : 
            if (i_rxmodule_BRGTICKS) 
               if (rxmodule_samptickreg==15) 
                  begin 
                     rxmodule_sampticknextreg = 0; 
                     rxmodule_bitsreasnextreg = {i_rxmodule_RX , rxmodule_bitsreasreg [7:1]}; 
                     if (rxmodule_nbrecreg==(NB_RXMODULE_DATA-1)) 
                        rxmodule_nextstate = rxmodule_stopstate ; 
                     else 
                        rxmodule_nbrecnextreg = rxmodule_nbrecreg + 1; 
                  end 
            else 
               rxmodule_sampticknextreg = rxmodule_samptickreg + 1; 
         rxmodule_stopstate: 
            if (i_rxmodule_BRGTICKS) 
               if (rxmodule_samptickreg==(SB_RXMODULE_TICKS-1)) 
               begin 
                  rxmodule_nextstate = rxmodule_idlestate; 
                  o_rxmodule_RXDONE =1'b1; 
               end 
               else 
                  rxmodule_sampticknextreg = rxmodule_samptickreg + 1; 
      endcase 
   end 

// output 
assign o_rxmodule_DOUT = rxmodule_bitsreasreg; 

endmodule
