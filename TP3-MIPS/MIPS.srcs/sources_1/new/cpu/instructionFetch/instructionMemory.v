module instructionMemory 
#(
    parameter DATA_LEN = 32,
    parameter PC_LEN = 32,
    parameter MEM_SIZE_ADDRESS_BITS = 10
) 
(
    //Inputs
    input wire i_clk,
    input wire i_reset,
    input wire [PC_LEN-1:0] i_programCounter,
    input wire [DATA_LEN-1:0] i_dataToWrite,
    input wire i_write,

    //Outputs
    output wire [DATA_LEN-1:0] o_instruction
);


reg [DATA_LEN-1:0] r_memoryBlock [(2**MEM_SIZE_ADDRESS_BITS)-1: 0];

reg [MEM_SIZE_ADDRESS_BITS-1:0] r_writePtr, r_writePtrNext, r_writePtrSucc;

always @(posedge i_clk) begin
    if(i_write) begin
        r_memoryBlock[r_writePtr] <= i_dataToWrite;
    end
end


always @(posedge i_clk) begin
    if(i_reset) begin
        r_writePtr <= 0;
    end
    else begin
        r_writePtr <= r_writePtrNext;
    end
end


always @(*) begin
    r_writePtrSucc = r_writePtr + 1;
    r_writePtrNext = r_writePtr;

    if(i_write) begin
        r_writePtrNext = r_writePtrSucc;
    end

end

reg [PC_LEN-1:0] r_mask = {{(PC_LEN-MEM_SIZE_ADDRESS_BITS-2){1'b0}}, {MEM_SIZE_ADDRESS_BITS{1'b1}}, 2'b00};

//El PC se incrementa en 4, por lo que descarta los dos lsb.
assign o_instruction = r_memoryBlock[(i_programCounter & r_mask) >> 2];

endmodule