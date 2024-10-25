// //CLK_FREQ / (BAUD_RATE * 16);
//COUNTER_MOD = 326 for f = 100MHz and  Baudrate = 19200
//COUNTER_MOD = 651 for f = 100MHz and Baudrate = 9600

module baudrg_module #
(
    parameter NB_BAUDRGMODULE_COUNTER = 9,       // Number of bits for counter
    parameter MOD_BAUDRGMODULE_M      = 326      // Limit for counter
)(
    input wire i_clk,
    input wire i_reset,

    output wire o_baudrgmodule_MAXTICK
);

reg [NB_BAUDRGMODULE_COUNTER-1 : 0] baudrgmodule_contreg;
wire [NB_BAUDRGMODULE_COUNTER-1 : 0] baudrgmodule_nextcontreg; // <-- MODIFICAR Y TODOS DONDE DIGA

always @(posedge i_clk) begin
    if (i_reset) begin
        baudrgmodule_contreg <= 0;
    end
    else begin
        baudrgmodule_contreg <= baudrgmodule_nextcontreg;
    end
end

//Next-state control
assign baudrgmodule_nextcontreg = (baudrgmodule_contreg == (MOD_BAUDRGMODULE_M-1)) ? 0 : baudrgmodule_contreg + 1;
assign o_baudrgmodule_MAXTICK = (baudrgmodule_contreg == (MOD_BAUDRGMODULE_M - 1)) ? 1'b1 : 1'b0;

endmodule
