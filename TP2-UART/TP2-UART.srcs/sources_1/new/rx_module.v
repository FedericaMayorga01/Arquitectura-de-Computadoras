`timescale 1ns / 1ps

module rx_module
#(
   parameter  NB_RXMODULE_DATA  = 8, // # rxmodule_datastate bits
              SB_RXMODULE_TICKS = 16 // # ticks for rxmodule_stopstate bits(1 bit rxmodule_stopstate)
)
(
   input    wire  i_clk, i_reset,
   input    wire  i_rxmodule_RX, i_rxmodule_BRGTICKS,
   output   reg   o_rxmodule_RXDONE,
   output   wire signed  [NB_RXMODULE_DATA-1:0] o_rxmodule_DOUT
);

// symbolic state declaration
localparam [1:0]
   rxmodule_idlestate  = 2'b00,
   rxmodule_startstate = 2'b01,
   rxmodule_datastate  = 2'b10,
   rxmodule_stopstate  = 2'b11;

// signal declaration
reg [1:0] rxmodule_statereg ,    rxmodule_nextstatereg ;    // 2 bits ya que hay 4 estados, de 0 a 3
reg [3:0] rxmodule_samptickreg , rxmodule_nextsamptickreg ; // 4 bits ya que hay que contar 16 bits, de 0 a 15
reg [2:0] rxmodule_nbrecreg ,    rxmodule_nextnbrecreg ;    // 3 bits ya que, son maximo 8: de 0 a 7
reg [7:0] rxmodule_bitsreasreg , rxmodule_nextbitsreasreg ; // 8 bits ya que esa es la cantidad de bits que manejamos

// body
// FSMD state & rxmodule_datastate registers
always @( posedge i_clk)
   if (i_reset)
      begin
         rxmodule_statereg    <= rxmodule_idlestate;
         rxmodule_samptickreg <= 0;
         rxmodule_nbrecreg    <= 0;
         rxmodule_bitsreasreg <= 0;
      end
   else
      begin
         rxmodule_statereg    <= rxmodule_nextstatereg ;
         rxmodule_samptickreg <= rxmodule_nextsamptickreg;
         rxmodule_nbrecreg    <= rxmodule_nextnbrecreg;
         rxmodule_bitsreasreg <= rxmodule_nextbitsreasreg;
      end

// FSMD next-state logic
always @(*)
   begin
      o_rxmodule_RXDONE        = 1'b0;                   // salida en 0
      rxmodule_nextstatereg    = rxmodule_statereg ;     // el siguiente estado sera el mismo que el actual, excepto algunos casos, que son los que cumplen la cant de ticks
      rxmodule_nextsamptickreg = rxmodule_samptickreg;
      rxmodule_nextnbrecreg    = rxmodule_nbrecreg;
      rxmodule_nextbitsreasreg = rxmodule_bitsreasreg;

      case (rxmodule_statereg) // estado actual
         rxmodule_idlestate :
            if (i_rxmodule_RX==0) // el bit de start en uart(es un 0)
               begin
                  rxmodule_nextstatereg    = rxmodule_startstate ;   // SIGUIENTE ESTADO
                  rxmodule_nextsamptickreg = 0;
               end

         rxmodule_startstate :
            if (i_rxmodule_BRGTICKS)
               if (rxmodule_samptickreg == 7)   // (8 ticks) mitad del bit start --|_+_|--
                  begin
                     rxmodule_nextstatereg    = rxmodule_datastate;  // SIGUIENTE ESTADO
                     rxmodule_nextsamptickreg = 0;
                     rxmodule_nextnbrecreg    = 0;
                  end
               else
                  rxmodule_nextsamptickreg = rxmodule_samptickreg + 1;  // seguimos sumando ticks

         rxmodule_datastate :
            if (i_rxmodule_BRGTICKS)
               if (rxmodule_samptickreg == 15)  // (16 ticks) mitad del dato.
                  begin
                     rxmodule_nextsamptickreg = 0;
                     rxmodule_nextbitsreasreg = {i_rxmodule_RX , rxmodule_bitsreasreg [7:1]};
                     if (rxmodule_nbrecreg == (NB_RXMODULE_DATA - 1))   // llegaron los 8 bits
                        rxmodule_nextstatereg = rxmodule_stopstate ;    // SIGUIENTE ESTADO
                     else
                        rxmodule_nextnbrecreg = rxmodule_nbrecreg + 1;  // seguimos sumando bits recibidos
                  end
            else
               rxmodule_nextsamptickreg = rxmodule_samptickreg + 1;     // seguimos sumando ticks

         rxmodule_stopstate:
            if (i_rxmodule_BRGTICKS)
               if (rxmodule_samptickreg == (SB_RXMODULE_TICKS - 1))     // se cumplieron los 16 ticks(un solo bit de stop)
               begin
                  rxmodule_nextstatereg = rxmodule_idlestate;           // SIGUIENTE ESTADO(el inicial)
                  o_rxmodule_RXDONE = 1'b1;                              // se pone en 1 la salida cuando los 8 bits son obtenidos,desde RX
               end
               else
                  rxmodule_nextsamptickreg = rxmodule_samptickreg + 1; // seguimos sumando ticks
      endcase
   end

// output
assign o_rxmodule_DOUT = rxmodule_bitsreasreg;

endmodule
