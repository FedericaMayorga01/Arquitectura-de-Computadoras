`timescale 1ns / 1ps

module baudrg_module #
(
    parameter NB_BAUDRGMODULE_COUNTER = 9,       
    parameter MOD_BAUDRGMODULE_M      = 326      
)(
    input wire i_clk,
    input wire i_reset,

    output wire o_baudrgmodule_MAXTICK
);

reg  [NB_BAUDRGMODULE_COUNTER-1 : 0] baudrgmodule_contreg;
wire [NB_BAUDRGMODULE_COUNTER-1 : 0] baudrgmodule_nextcontreg;

always @(posedge i_clk) begin
    if (i_reset) begin
        baudrgmodule_contreg <= 0;
    end
    else begin
        baudrgmodule_contreg <= baudrgmodule_nextcontreg;
    end
end

assign baudrgmodule_nextcontreg = (baudrgmodule_contreg == (MOD_BAUDRGMODULE_M-1)) ? 0 : baudrgmodule_contreg + 1;
assign o_baudrgmodule_MAXTICK   = (baudrgmodule_contreg == (MOD_BAUDRGMODULE_M-1)) ? 1'b1 : 1'b0;

endmodule
