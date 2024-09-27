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
     parameter STATE_RXMODULE_1 = 4'b0001,
     parameter STATE_RXMODULE_2 = 4'b0010,
     parameter STATE_RXMODULE_3 = 4'b0100,
     parameter STATE_RXMODULE_4 = 4'b1000
 );
 reg [3:0] state = STATE_RXMODULE_1;
 reg [3:0] next_state = STATE_RXMODULE_2;
 
 always @(posedge <clock>) //Memory
    if (reset) state <= <state1>;
    else state <= next_state;
    
 always @* // Next-state logic
    case (state)
    <state1>: begin 
        if (<condition>) 
            next_state = <state1>;
       else 
            next_state = <state2>;
       end
    <state2>: 

 default: next_state = <state1>; // Fault Recovery
 endcase

 always @* // Output logic
    case (state)
      <state1>: 
      <outputs> = <values>;
      <state2>: 

      default: <outputs> = <values>; // Fault Recovery
 endcase

endmodule
