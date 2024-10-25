module interface_module #
(
    parameter NB_INTERFACEMODULE_DATA = 8,
    parameter NB_INTERFACEMODULE_OP   = 6
)(
    input wire                               i_clk,
    input wire                               i_reset,
    input wire [NB_INTERFACEMODULE_DATA-1:0] i_interfacemodule_DATARES,
    input wire [NB_INTERFACEMODULE_DATA-1:0] i_interfacemodule_READDATA,
    input wire                               i_interfacemodule_EMPTY,
    input wire                               i_interfacemodule_FULL,

    output wire                               o_interfacemodule_READ,
    output wire                               o_interfacemodule_WRITE,
    output wire [NB_INTERFACEMODULE_DATA-1:0] o_interfacemodule_WRITEDATA,
    output wire [NB_INTERFACEMODULE_OP-1:0]   o_interfacemodule_OP,
    output wire [NB_INTERFACEMODULE_DATA-1:0] o_interfacemodule_DATAA,
    output wire [NB_INTERFACEMODULE_DATA-1:0] o_interfacemodule_DATAB
);

// STM Interface
localparam [3:0] INTERM_IDLE_STATE   = 4'b0000;
localparam [3:0] INTERM_OPCODE_STATE = 4'b0001;
localparam [3:0] INTERM_DATA_A_STATE = 4'b0010;
localparam [3:0] INTERM_DATA_B_STATE = 4'b0011;
localparam [3:0] INTERM_RESULT_STATE = 4'b0100;
localparam [3:0] INTERM_WAIT_STATE   = 4'b1000;

// Registers
reg [3:0]                         interfacemodule_statereg,   interfacemodule_nextstatereg;
reg                               interfacemodule_readreg,    interfacemodule_nextreadreg;
reg                               interfacemodule_writereg,   interfacemodule_nextwritereg;
reg [NB_INTERFACEMODULE_OP-1:0]   interfacemodule_opreg,      interfacemodule_nextopreg;
reg [NB_INTERFACEMODULE_DATA-1:0] interfacemodule_dataAreg,   interfacemodule_nextdataAreg;
reg [NB_INTERFACEMODULE_DATA-1:0] interfacemodule_dataBreg,   interfacemodule_nextdataBreg;
reg [NB_INTERFACEMODULE_DATA-1:0] interfacemodule_dataresreg, interfacemodule_nextdataresreg;
reg [3:0]                         interfacemodule_waitreg,    interfacemodule_nextwaitreg;

always @(posedge i_clk) begin
    if(i_reset) begin
        interfacemodule_statereg   <= INTERM_IDLE_STATE;
        interfacemodule_readreg    <= 1'b0;
        interfacemodule_writereg   <= 1'b0;
        interfacemodule_opreg      <= {NB_INTERFACEMODULE_OP{1'b0}};
        interfacemodule_dataAreg   <= {NB_INTERFACEMODULE_DATA{1'b0}};
        interfacemodule_dataBreg   <= {NB_INTERFACEMODULE_DATA{1'b0}};
        interfacemodule_dataresreg <= {NB_INTERFACEMODULE_DATA{1'b0}};
        interfacemodule_waitreg    <= 4'b0000;
    end
    else begin
        interfacemodule_statereg   <= interfacemodule_nextstatereg;
        interfacemodule_readreg    <= interfacemodule_nextreadreg;
        interfacemodule_writereg   <= interfacemodule_nextwritereg;
        interfacemodule_opreg      <= interfacemodule_nextopreg;
        interfacemodule_dataAreg   <= interfacemodule_nextdataAreg;
        interfacemodule_dataBreg   <= interfacemodule_nextdataBreg;
        interfacemodule_dataresreg <= interfacemodule_nextdataresreg;
        interfacemodule_waitreg    <= interfacemodule_nextwaitreg;
    end
end

always @(*) begin
    interfacemodule_nextstatereg   = interfacemodule_statereg;
    interfacemodule_nextreadreg    = interfacemodule_readreg;
    interfacemodule_nextwritereg   = interfacemodule_writereg;
    interfacemodule_nextopreg      = interfacemodule_opreg;
    interfacemodule_nextdataAreg   = interfacemodule_dataAreg;
    interfacemodule_nextdataBreg   = interfacemodule_dataBreg;
    interfacemodule_nextdataresreg = interfacemodule_dataresreg;
    interfacemodule_nextwaitreg    = interfacemodule_waitreg;

    case (interfacemodule_statereg)
        INTERM_IDLE_STATE: begin
            interfacemodule_nextwritereg = 1'b0;
            if(~i_interfacemodule_EMPTY) begin
                interfacemodule_nextstatereg = INTERM_OPCODE_STATE;
                interfacemodule_nextreadreg  = 1'b1;
            end
        end

        INTERM_WAIT_STATE: begin
            if(~i_interfacemodule_EMPTY) begin
                interfacemodule_nextstatereg = interfacemodule_waitreg;
                interfacemodule_nextreadreg  = 1'b1;
            end
        end

        INTERM_OPCODE_STATE: begin
            if(i_interfacemodule_EMPTY) begin
                interfacemodule_nextreadreg  = 1'b0;
                interfacemodule_nextstatereg = INTERM_WAIT_STATE;
                interfacemodule_nextwaitreg  = INTERM_OPCODE_STATE;
            end
            else begin
                interfacemodule_nextstatereg = INTERM_DATA_A_STATE;
                interfacemodule_nextopreg    = i_interfacemodule_READDATA[NB_INTERFACEMODULE_OP-1:0];
                interfacemodule_nextreadreg  = 1'b1;
            end
        end

        INTERM_DATA_A_STATE: begin
            if(i_interfacemodule_EMPTY) begin
                interfacemodule_nextreadreg  = 1'b0;
                interfacemodule_nextstatereg = INTERM_WAIT_STATE;
                interfacemodule_nextwaitreg  = INTERM_DATA_A_STATE;
            end
            else begin
                interfacemodule_nextstatereg = INTERM_DATA_B_STATE;
                interfacemodule_nextdataAreg = i_interfacemodule_READDATA;
                interfacemodule_nextreadreg  = 1'b1;
            end
        end

        INTERM_DATA_B_STATE: begin
            if(i_interfacemodule_EMPTY) begin
                interfacemodule_nextreadreg  = 1'b0;
                interfacemodule_nextstatereg = INTERM_WAIT_STATE;
                interfacemodule_nextwaitreg  = INTERM_DATA_B_STATE;
            end
            else begin
                interfacemodule_nextstatereg = INTERM_RESULT_STATE;
                interfacemodule_nextdataBreg = i_interfacemodule_READDATA;
                interfacemodule_nextreadreg  = 1'b0;
            end
        end

        INTERM_RESULT_STATE: begin
            if(~i_interfacemodule_FULL) begin
                interfacemodule_nextstatereg   = INTERM_IDLE_STATE;
                interfacemodule_nextdataresreg = i_interfacemodule_DATARES;
                interfacemodule_nextwritereg   = 1'b1;
            end
        end

        default: begin
            interfacemodule_nextstatereg = INTERM_IDLE_STATE;
            interfacemodule_nextreadreg  = 1'b0;
            interfacemodule_nextwritereg = 1'b0;
        end

    endcase
end

// Output
assign o_interfacemodule_DATAA     = interfacemodule_dataAreg;
assign o_interfacemodule_DATAB     = interfacemodule_dataBreg;
assign o_interfacemodule_OP        = interfacemodule_opreg;
assign o_interfacemodule_WRITEDATA = interfacemodule_dataresreg;
assign o_interfacemodule_WRITE     = interfacemodule_writereg;
assign o_interfacemodule_READ      = interfacemodule_readreg;

endmodule
