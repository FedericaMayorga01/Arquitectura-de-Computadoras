module controlUnit
#(
    parameter DATA_LEN = 32,
    parameter OPCODE_LEN = 6
)
(
    // Inputs
    input wire [OPCODE_LEN-1:0] i_opCode,
    input wire [OPCODE_LEN-1:0] i_funct,

    // Outputs
    output wire o_regWrite,
    output wire [1:0] o_aluSrc,
    output wire [1:0] o_aluOp,
    output wire [2:0] o_immediateFunct,
    output wire [1:0] o_branch,
    output wire o_jumpType,
    output wire [1:0] o_regDest,
    output wire o_memRead,
    output wire o_memWrite,
    output wire [1:0] o_memToReg,
    output wire o_halt,
    output wire [1:0] o_loadStoreType,
    output wire o_unsigned
);

localparam RTYPE = 6'b000000;
localparam SLT_FUNC = 6'b101010;
localparam SLTU_FUNC = 6'b101011;
localparam BEQ = 6'b000100;
localparam ADDI = 6'b001000;
localparam ADDIU = 6'b001001;
localparam SLTI = 6'b001010;
localparam SLTIU = 6'b001011;
localparam ANDI = 6'b001100;
localparam ORI = 6'b001101;
localparam XORI = 6'b001110;
localparam LUI = 6'b001111;
localparam LW = 6'b100011;
localparam LWU = 6'b100111;
localparam LB = 6'b100000;
localparam LBU = 6'b100100;
localparam LH = 6'b100001;
localparam LHU = 6'b100101;
localparam SW = 6'b101011;
localparam SH = 6'b101001;
localparam SB = 6'b101000;
localparam NOP = 6'b111111;
localparam HALT = 6'b111000;

reg r_regWrite;
reg [1:0] r_aluSrc;
reg [1:0] r_aluOp;
reg [2:0] r_immediateFunct;
reg [1:0] r_branch;
reg r_jumpType;
reg [1:0] r_regDest;
reg r_memRead;
reg r_memWrite;
reg [1:0] r_memToReg;
reg r_halt;
reg [1:0] r_loadStoreType;
reg r_unsigned;

reg r_isShamt;
reg r_isNotJR;
reg r_isJARL;

always @(*) begin
    r_isShamt = ~(i_funct[2] || i_funct[5]);
    r_isNotJR = (i_funct != 6'b001000);
    r_isJARL = i_funct[3] & i_funct[0];

    case (i_opCode)
        RTYPE: begin
            if(i_funct == SLT_FUNC || i_funct == SLTU_FUNC) begin
                r_regDest = 2'b01;
                r_aluOp = 2'b10;
                r_immediateFunct = 3'b000;
                r_aluSrc = 2'b00;
                r_branch = 2'b00;
                r_jumpType = 1'b0;
                r_memRead = 1'b0;
                r_memWrite = 1'b0;
                r_regWrite = 1'b1;
                r_memToReg = 2'b00;
                r_halt = 1'b0;
                r_loadStoreType = 2'b11;
                r_unsigned = (i_funct == SLTU_FUNC);
            end
            else begin
                r_regDest = {i_opCode[0], 1'b1};
                r_aluSrc = (r_isShamt) ? 2'b10 : 2'b00;
                r_branch = i_opCode[1] | (!i_opCode[1] & i_funct[3]) ? 2'b10 : 2'b00;
                r_regWrite = (!(i_opCode[1] | i_opCode[0])) ? r_isNotJR : i_opCode[0];
                r_memToReg = {i_opCode[0] | r_isJARL, 1'b0};
                r_jumpType = !i_opCode[1];
                r_immediateFunct = 3'b000;
                r_aluOp = 2'b10;
                r_memRead = 1'b0;
                r_memWrite = 1'b0;
                r_halt = 1'b0;
                r_loadStoreType = 2'b11;
                r_unsigned = 1'b0;
            end
        end
        ADDI, ADDIU, SLTI, SLTIU, ANDI, ORI, XORI, LUI: begin
            r_regDest = 2'b00;
            r_aluOp = 2'b11;
            r_immediateFunct = i_opCode[2:0];
            r_aluSrc = 2'b01;
            r_branch = 2'b00;
            r_jumpType = 1'b0;
            r_memRead = 1'b0;
            r_memWrite = 1'b0;
            r_regWrite = 1'b1;
            r_memToReg = 2'b00;
            r_halt = 1'b0;
            r_loadStoreType = 2'b11;
            r_unsigned = (i_opCode == ADDIU || i_opCode == SLTIU );
        end
        LW, LWU, LB, LBU, LH, LHU: begin
            r_regDest = 2'b00;
            r_aluOp = 2'b00;
            r_immediateFunct = 3'b000;
            r_aluSrc = 2'b01;
            r_branch = 2'b00;
            r_jumpType = 1'b0;
            r_memRead = 1'b1;
            r_memWrite = 1'b0;
            r_regWrite = 1'b1;
            r_memToReg = 2'b01;
            r_halt = 1'b0;
            r_loadStoreType = i_opCode[1:0];
            r_unsigned = (i_opCode == LWU || i_opCode == LBU || i_opCode == LHU);
        end
        SW, SH, SB: begin
            r_regDest = 2'b00;
            r_aluOp = 2'b00;
            r_immediateFunct = 3'b000;
            r_aluSrc = 2'b01;
            r_branch = 2'b00;
            r_jumpType = 1'b0;
            r_memRead = 1'b0;
            r_memWrite = 1'b1;
            r_regWrite = 1'b0;
            r_memToReg = 2'b00;
            r_halt = 1'b0;
            r_loadStoreType = i_opCode[1:0];
            r_unsigned = 0;
        end
        BEQ: begin
            r_regDest = 2'b00;
            r_aluOp = 2'b01;
            r_immediateFunct = 3'b000;
            r_aluSrc = 2'b00;
            r_branch = {i_opCode[0], 1'b1};
            r_jumpType = 1'b0;
            r_memRead = 1'b0;
            r_memWrite = 1'b0;
            r_regWrite = 1'b0;
            r_memToReg = 2'b00;
            r_halt = 1'b0;
            r_loadStoreType = 2'b11;
            r_unsigned = 2'b11;
        end
        NOP, HALT: begin
            r_regDest = 2'b00;
            r_aluOp = 2'b00;
            r_immediateFunct = 3'b000;
            r_aluSrc = 2'b00;
            r_branch = 2'b00;
            r_jumpType = 1'b0;
            r_memRead = 1'b0;
            r_memWrite = 1'b0;
            r_regWrite = 1'b0;
            r_memToReg = 2'b00;
            r_halt = (i_opCode == HALT);
            r_loadStoreType = 2'b11;
            r_unsigned = 0;
        end
        default: begin
            r_regDest = 2'b00;
            r_aluOp = 2'b00;
            r_immediateFunct = 3'b000;
            r_aluSrc = 2'b00;
            r_branch = 2'b00;
            r_jumpType = 1'b0;
            r_memRead = 1'b0;
            r_memWrite = 1'b0;
            r_regWrite = 1'b0;
            r_memToReg = 2'b00;
            r_halt = 1'b0;
            r_loadStoreType = 2'b11;
            r_unsigned = 0;
        end
    endcase
end

assign o_regWrite = r_regWrite;
assign o_aluSrc = r_aluSrc;
assign o_aluOp = r_aluOp;
assign o_immediateFunct = r_immediateFunct;
assign o_branch = r_branch;
assign o_jumpType = r_jumpType;
assign o_regDest = r_regDest;
assign o_memRead = r_memRead;
assign o_memWrite = r_memWrite;
assign o_memToReg = r_memToReg;
assign o_halt = r_halt;
assign o_loadStoreType = r_loadStoreType;
assign o_unsigned = r_unsigned;

endmodule
