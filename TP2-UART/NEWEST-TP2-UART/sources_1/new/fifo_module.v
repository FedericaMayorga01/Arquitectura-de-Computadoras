module fifo_module #
(
    parameter NB_FIFOMODULE_DATA = 8,
    parameter NB_FIFOMODULE_ADDR = 4
)(
    input wire                            i_clk,
    input wire                            i_reset,
    input wire                            i_fifomodule_READ,
    input wire                            i_fifomodule_WRITE,
    input wire [NB_FIFOMODULE_DATA-1 : 0] i_fifomodule_WRITEDATA,

    output wire                            o_fifomodule_EMPTY,
    output wire                            o_fifomodule_FULL,
    output wire [NB_FIFOMODULE_DATA-1 : 0] o_fifomodule_READATA
);

// FIFO operations
localparam FIFOM_READ_STATE      = 2'b01;
localparam FIFOM_WRITE_STATE     = 2'b10;
localparam FIFOM_READWRITE_STATE = 2'b11;


// Signal declaration
reg [NB_FIFOMODULE_DATA-1 : 0] fifomodule_arrayreg [(2**NB_FIFOMODULE_ADDR)-1 : 0];
reg [NB_FIFOMODULE_ADDR-1 : 0] fifomodule_writeptrreg, fifomodule_nextwriteptrreg, fifomodule_succwriteptrreg;
reg [NB_FIFOMODULE_ADDR-1 : 0] fifomodule_readptrreg,  fifomodule_nextreadptrreg,  fifomodule_succreadptrreg;

reg fifomodule_fullreg;
reg fifomodule_nextfullreg;
reg fifomodule_emptyreg;
reg fifomodule_nextemptyreg;

wire fifomodule_writeenablewire;

// Register file write operation
always @(posedge i_clk) begin
    if(fifomodule_writeenablewire) begin
        fifomodule_arrayreg[fifomodule_writeptrreg] <= i_fifomodule_WRITEDATA;
    end
end

// Register file read operation
assign o_fifomodule_READATA = fifomodule_arrayreg[fifomodule_readptrreg];

// Write enable only when FIFO is not o_fifomodule_FULL
assign fifomodule_writeenablewire = i_fifomodule_WRITE & ~fifomodule_fullreg;

// Fifo control logic
// Register for read and write pointers
always @(posedge i_clk) begin
    if(i_reset) begin
        fifomodule_writeptrreg <= 0;
        fifomodule_readptrreg  <= 0;
        fifomodule_fullreg     <= 0;
        fifomodule_emptyreg    <= 1;
    end
    else begin
        fifomodule_writeptrreg <= fifomodule_nextwriteptrreg;
        fifomodule_readptrreg  <= fifomodule_nextreadptrreg;
        fifomodule_fullreg     <= fifomodule_nextfullreg;
        fifomodule_emptyreg    <= fifomodule_nextemptyreg;
    end
end

// Next-state logic for read and write pointers
always @(*) begin
    //Successive pointer values
    fifomodule_succwriteptrreg = fifomodule_writeptrreg + 1;
    fifomodule_succreadptrreg  = fifomodule_readptrreg + 1;
    //Default: keep old values
    fifomodule_nextwriteptrreg = fifomodule_writeptrreg;
    fifomodule_nextreadptrreg  = fifomodule_readptrreg;
    fifomodule_nextfullreg     = fifomodule_fullreg;
    fifomodule_nextemptyreg    = fifomodule_emptyreg;

    case ({i_fifomodule_WRITE, i_fifomodule_READ})
        FIFOM_READ_STATE:
            if (~fifomodule_emptyreg) begin
                fifomodule_nextreadptrreg = fifomodule_succreadptrreg;   // desplazar puntero
                fifomodule_nextfullreg = 1'b0;
                if (fifomodule_succreadptrreg == fifomodule_writeptrreg) begin // fifo esta vacia
                    fifomodule_nextemptyreg = 1'b1;
                end
            end
        FIFOM_WRITE_STATE:
            if (~fifomodule_fullreg) begin
                fifomodule_nextwriteptrreg = fifomodule_succwriteptrreg;
                fifomodule_nextemptyreg = 1'b0;
                if (fifomodule_succwriteptrreg == fifomodule_readptrreg) begin // fifo esta llena
                    fifomodule_nextfullreg = 1'b1;
                end
            end
        FIFOM_READWRITE_STATE:
            begin
                fifomodule_nextwriteptrreg = fifomodule_succwriteptrreg;
                fifomodule_nextreadptrreg  = fifomodule_succreadptrreg;
            end
        default:
            begin
                fifomodule_nextwriteptrreg = fifomodule_nextwriteptrreg;
                fifomodule_nextreadptrreg  = fifomodule_nextreadptrreg;
            end

    endcase
end

// Output
assign o_fifomodule_FULL = fifomodule_fullreg;
assign o_fifomodule_EMPTY = fifomodule_emptyreg;

endmodule
