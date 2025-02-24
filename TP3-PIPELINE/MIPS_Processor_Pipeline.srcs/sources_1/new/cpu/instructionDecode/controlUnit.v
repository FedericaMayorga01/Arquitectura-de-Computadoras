module controlUnit
#(
    parameter DATA_LEN = 32,
    parameter OPCODE_LEN = 6
)
(
    //Inputs
    input wire [OPCODE_LEN-1:0] i_opCode,
    input wire [OPCODE_LEN-1:0] i_funct,

    //Outputs
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

localparam BEQ = 6'b000100;
localparam ADDI = 6'b001000;
localparam ADDIU = 6'b001011;
localparam SLTIU = 6'b010001;
localparam ANDI = 6'b001100;
localparam LW = 6'b100011;
localparam LWU = 6'b100111;
localparam SW = 6'b101011;

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
reg [1:0]r_memToReg;
reg r_halt;
reg [1:0] r_loadStoreType;
reg r_unsigned;

reg r_isShamt;
reg r_isNotJR;
reg r_isJARL;

always @(*) begin
    r_isShamt = ~(i_funct[2] || i_funct[5]);
    r_isNotJR = (i_funct[5:0] != 6'b001000); 
    r_isJARL = i_funct[3] & i_funct[0];

    case (i_opCode[OPCODE_LEN-1:2])
        RTYPE[OPCODE_LEN-1:2]: begin
            if(i_funct == 6'b101011 || i_funct == 6'b101010) begin //SLTU || SLT
                r_regDest = 2'b01;
                r_aluSrc = 2'b00;
                r_branch = 2'b00;
                r_regWrite = 1'b1;
                r_memToReg = 2'b00;
                r_jumpType = 1'b0;
            end
            else
                r_regDest = {i_opCode[0], 1'b1};
                r_aluSrc = (r_isShamt) ? 2'b10 : 2'b00;
                r_branch = i_opCode[1] | (!i_opCode[1] & i_funct[3])? 2'b10 : 2'b00;
                r_regWrite = (!(i_opCode[1] | i_opCode[0]))? r_isNotJR : i_opCode[0]; //Si es R-TYPE escribe en registro en todos los casos menos JR, si no es R-TYPE escribe solo en JAL
                r_memToReg = {i_opCode[0] | r_isJARL, 1'b0}; //Si es JL o JARL write return address
                r_jumpType = !i_opCode[1];

            r_immediateFunct = 3'b000;
            r_aluOp = 2'b10;
            r_memRead = 1'b0;
            r_memWrite = 1'b0;
            r_halt = 1'b0;
            r_loadStoreType = 2'b11;

            if(i_funct == 6'b101011) begin //SLTU
                r_unsigned = 1;
            end
            else
                r_unsigned = 0;
        end
        ADDI[OPCODE_LEN-1:2]: begin
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
            r_unsigned = 1'b0;
        end
        ADDIU[OPCODE_LEN-1:2]: begin
            r_regDest = 2'b00;
            r_aluOp = 2'b11;
            r_immediateFunct = 3'b011;
            r_aluSrc = 2'b01;
            r_branch = 2'b00;
            r_jumpType = 1'b0;
            r_memRead = 1'b0;
            r_memWrite = 1'b0;
            r_regWrite = 1'b1;
            r_memToReg = 2'b00;
            r_halt = 1'b0;
            r_loadStoreType = 2'b11;
            r_unsigned = 1'b1;
        end
        SLTIU[OPCODE_LEN-1:2]: begin
            r_regDest = 2'b00;
            r_aluOp = 2'b11;
            r_immediateFunct = 3'b001;
            r_aluSrc = 2'b01;
            r_branch = 2'b00;
            r_jumpType = 1'b0;
            r_memRead = 1'b0;
            r_memWrite = 1'b0;
            r_regWrite = 1'b1;
            r_memToReg = 2'b00;
            r_halt = 1'b0;
            r_loadStoreType = 2'b11;
            r_unsigned = 1'b1;
        end
        ANDI[OPCODE_LEN-1:2]: begin
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
            r_unsigned = 1'b0;
        end
        LW[OPCODE_LEN-1:2]: begin
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
            r_unsigned = 1'b0;
        end
        LWU[OPCODE_LEN-1:2]: begin
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
            r_unsigned = 1'b1;
        end
        SW[OPCODE_LEN-1:2]: begin
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
        BEQ[OPCODE_LEN-1:2]: begin
            r_regDest = 2'b00;
            r_aluOp = 2'b01;
            r_immediateFunct = 3'b000;
            r_aluSrc = 2'b00;
            r_branch = {i_opCode[0],1'b1};
            r_jumpType = 1'b0;
            r_memRead = 1'b0;
            r_memWrite = 1'b0;
            r_regWrite = 1'b0;
            r_memToReg = 2'b00;
            r_halt = 1'b0;
            r_loadStoreType = 2'b11;
            r_unsigned = 0;
        end
        NOP[OPCODE_LEN-1:2]: begin
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
        HALT[OPCODE_LEN-1:2]: begin
            r_regDest = 2'b00;
            r_aluOp = 2'b00;
            r_immediateFunct = 3'b000;
            r_aluSrc = 2'b00;
            r_branch =  2'b00;
            r_jumpType = 1'b0;
            r_memRead = 1'b0;
            r_memWrite = 1'b0;
            r_regWrite = 1'b0;
            r_memToReg = 2'b00;
            r_halt = 1'b1;
            r_loadStoreType = 2'b11;
            r_unsigned = 0;
        end
        default: begin
            r_regDest = 2'b00;
            r_aluOp = 2'b00;
            r_immediateFunct = 3'b000;
            r_aluSrc = 2'b00;
            r_branch =  2'b00;
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
