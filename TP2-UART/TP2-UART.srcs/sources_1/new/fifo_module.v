`timescale 1ns / 1ps

module fifo_module
#(
    parameter NB_FIFOMODULE_DATA = 8,       // number of bits in a word
    parameter NB_FIFOMODULE_ADDR = 4        // number of address bits
)
(
    input wire i_clk, i_reset,
    input wire i_read, i_write,
    input wire [NB_FIFOMODULE_DATA - 1 : 0] i_writedata,
    output wire o_fifo_empty, o_fifo_full,
    output wire [NB_FIFOMODULE_DATA - 1 : 0] o_readdata
);

// signal declaration
reg [NB_FIFOMODULE_DATA - 1 : 0] array_reg [2**(NB_FIFOMODULE_ADDR - 1) : 0];  // register array
reg [NB_FIFOMODULE_ADDR - 1 : 0] write_ptr_reg, write_ptr_nextreg, write_ptr_succreg;
reg [NB_FIFOMODULE_ADDR - 1 : 0] read_ptr_reg, read_ptr_nextreg, read_ptr_succreg;
reg                              full_reg, empty_reg, full_nextreg, empty_nextreg;

wire write_enable;

// body
// register file write operation
always @(posedge clk)
    if (write_enable)
        array_reg[write_ptr_reg] <= i_writedata;

// register file read operation
assign o_readdata = array_reg[read_ptr_reg];

// write enabled only when FIFO is not full
assign write_enable = i_write & (~full_reg);

// FIFO control logic
// register for read and write pointers
always @(posedge i_clk, posedge i_reset)
    if (i_reset)
        begin
            write_ptr_reg <= 0;
            read_ptr_reg  <= 0;
            full_reg      <= 1'b0;
            empty_reg     <= 1'b1;
        end
    else
        begin
            write_ptr_reg <= write_ptr_nextreg;
            read_ptr_reg  <= read_ptr_nextreg;
            full_reg      <= full_nextreg;
            empty_reg     <= empty_nextreg;
        end

// next-state logic for read and write pointers
always @(*)
    begin
        // successive pointer values
        write_ptr_succreg = write_ptr_reg + 1;
        read_ptr_succreg  = read_ptr_reg + 1;

        // default is to keep old values
        write_ptr_nextreg = write_ptr_reg;
        read_ptr_nextreg  = read_ptr_reg;
        full_nextreg      = full_reg;
        empty_nextreg     = empty_reg;

        case ({i_write, i_read})
            // 2'b00: no op
            2'b01 : // read
                if (~empty_reg) // not empty
                    begin
                        read_ptr_nextreg = read_ptr_succreg;
                        full_nextreg = 1'b0;
                        if (read_ptr_succreg == write_ptr_reg)
                            empty_nextreg = 1'b1;
                    end
            2'b10 : // write
                if (~full_nextreg) // not full
                    begin
                        write_ptr_nextreg = write_ptr_succreg;
                        empty_nextreg = 1'b0;
                        if (write_ptr_succreg == read_ptr_reg)
                            full_nextreg = 1'b1;
                    end
            2'b11 : // write and read
                begin
                    write_ptr_nextreg = write_ptr_succreg;
                    read_ptr_nextreg  = read_ptr_succreg;
                end
        endcase
    end

// output
assign o_fifo_full  = full_reg;
assign o_fifo_empty = empty_reg;

endmodule