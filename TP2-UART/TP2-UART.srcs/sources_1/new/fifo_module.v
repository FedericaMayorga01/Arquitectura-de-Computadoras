`timescale 1ns / 1ps

module fifo_module
#(
    parameter NB_FIFOMODULE_DATA = 8,       // number of bits in a word
    parameter NB_FIFOMODULE_ADDR = 4        // number of address bits
)
(
    input wire i_clk, i_reset,
    input wire i_fifomodule_READ, i_fifomodule_WRITE,
    input wire signed [NB_FIFOMODULE_DATA - 1 : 0] i_fifomodule_WRITEDATA,
    output wire o_fifomodule_EMPTY, o_fifomodule_FULL,
    output wire signed [NB_FIFOMODULE_DATA - 1 : 0] o_fifomodule_READATA
);

// signal declaration
reg signed [NB_FIFOMODULE_DATA - 1 : 0] fifomodule_arrayreg [2**NB_FIFOMODULE_ADDR - 1 : 0];  // register array
reg [NB_FIFOMODULE_ADDR - 1 : 0] fifomodule_writeptrreg, fifomodule_nextwriteptrreg, fifomodule_succwriteptrreg;
reg [NB_FIFOMODULE_ADDR - 1 : 0] fifomodule_readptrreg, fifomodule_nextreadptrreg, fifomodule_succreadptrreg;
reg                              fifomodule_fullreg, fifomodule_emptyreg, fifomodule_nextfullreg, fifomodule_nextemptyreg;

wire fifomodule_writeenablewire;

// body
// register file write operation
always @(posedge i_clk)
    if (fifomodule_writeenablewire)
        fifomodule_arrayreg[fifomodule_writeptrreg] <= i_fifomodule_WRITEDATA;

// register file read operation
assign o_fifomodule_READATA = fifomodule_arrayreg[fifomodule_readptrreg];

// write enabled only when FIFO is not full
assign fifomodule_writeenablewire = i_fifomodule_WRITE & (~fifomodule_fullreg);

// FIFO control logic
// register for read and write pointers
always @(posedge i_clk)
    if (i_reset)
        begin
            fifomodule_writeptrreg <= 0;
            fifomodule_readptrreg  <= 0;
            fifomodule_fullreg      <= 1'b0;
            fifomodule_emptyreg     <= 1'b1;
        end
    else
        begin
            fifomodule_writeptrreg <= fifomodule_nextwriteptrreg;
            fifomodule_readptrreg  <= fifomodule_nextreadptrreg;
            fifomodule_fullreg      <= fifomodule_nextfullreg;
            fifomodule_emptyreg     <= fifomodule_nextemptyreg;
        end

// next-state logic for read and write pointers
always @(*)
    begin
        // successive pointer values
        fifomodule_succwriteptrreg = fifomodule_writeptrreg + 1;
        fifomodule_succreadptrreg  = fifomodule_readptrreg + 1;

        // default is to keep old values
        fifomodule_nextwriteptrreg = fifomodule_writeptrreg;
        fifomodule_nextreadptrreg  = fifomodule_readptrreg;
        fifomodule_nextfullreg      = fifomodule_fullreg;
        fifomodule_nextemptyreg     = fifomodule_emptyreg;

        case ({i_fifomodule_WRITE, i_fifomodule_READ})
            // 2'b00: no op
            2'b01 : // read
                if (~fifomodule_emptyreg) // not empty
                    begin
                        fifomodule_nextreadptrreg = fifomodule_succreadptrreg;
                        fifomodule_nextfullreg = 1'b0;
                        if (fifomodule_succreadptrreg == fifomodule_writeptrreg)
                            fifomodule_nextemptyreg = 1'b1;
                    end
            2'b10 : // write
                if (~fifomodule_fullreg) // not full
                    begin
                        fifomodule_nextwriteptrreg = fifomodule_succwriteptrreg;
                        fifomodule_nextemptyreg = 1'b0;
                        if (fifomodule_succwriteptrreg == fifomodule_readptrreg)
                            fifomodule_nextfullreg = 1'b1;
                    end
            2'b11 : // write and read
                begin
                    fifomodule_nextwriteptrreg = fifomodule_succwriteptrreg;
                    fifomodule_nextreadptrreg  = fifomodule_succreadptrreg;
                end
        endcase
    end

// output
assign o_fifomodule_FULL  = fifomodule_fullreg;
assign o_fifomodule_EMPTY = fifomodule_emptyreg;

endmodule
