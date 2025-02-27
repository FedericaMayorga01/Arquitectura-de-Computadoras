module registers
#(
    parameter DATA_LEN = 32,
    parameter REGISTER_BITS = 5
)
(
    //Inputs
    input wire i_reset,
    input wire i_clk,
    input wire [REGISTER_BITS-1:0] i_readRegister1,
    input wire [REGISTER_BITS-1:0] i_readRegister2,
    input wire [REGISTER_BITS-1:0] i_writeRegister,
    input wire [DATA_LEN-1:0] i_writeData,
    input wire i_regWrite,
    input wire [REGISTER_BITS-1:0] i_registerAddress,

    //Outputs
    output wire [DATA_LEN-1:0] o_readData1,
    output wire [DATA_LEN-1:0] o_readData2,
    output wire [DATA_LEN-1:0] o_registerValue

);

reg [DATA_LEN-1:0] r_registers [(2**REGISTER_BITS)-1:0];

initial begin
    r_registers[0] = 0;
end

always @(negedge i_clk) begin
    if(i_reset)
        r_registers[0] <= 0;
    else if(i_regWrite)
        r_registers[i_writeRegister] <= i_writeData;
end


assign o_readData1 = r_registers[i_readRegister1];
assign o_readData2 = r_registers[i_readRegister2];
assign o_registerValue = r_registers[i_registerAddress];

endmodule
