`timescale 1ns / 1ps

module branchControl #(
    parameter DATA_LEN = 32
)(
    //Data inputs
    input wire [DATA_LEN-1:0] i_immediateExtendValue,
    input wire [DATA_LEN-1:0] i_incrementedPC,
    input wire [DATA_LEN-1:0] i_readData1,
    input wire [DATA_LEN-1:0] i_readData2,
    input wire [25:0] i_instrIndex,
    //Control inputs
    input wire [1:0] i_branch,
    input wire i_jumpType,
    //Control outputs
    output reg o_PCSrc,
    output reg [DATA_LEN-1:0] o_pcBranch
);

wire[DATA_LEN-1:0] shiftedImmediate = {1'b0, i_immediateExtendValue[DATA_LEN-2:0] << 2};

    //Calculates branch program counter
wire[DATA_LEN-1:0] w_branchPC = i_immediateExtendValue[DATA_LEN-1]? i_incrementedPC - shiftedImmediate: i_incrementedPC + shiftedImmediate;
    
wire [DATA_LEN-1:0] literalJump = {i_incrementedPC[DATA_LEN-1:DATA_LEN-4], i_instrIndex, 2'b00};
    
    //Select jump source (rs register or literal)
wire [DATA_LEN-1:0] w_jumpPC = i_jumpType?  literalJump : i_readData1;

wire w_zero = i_readData1 == i_readData2;

always @(*) begin
    case(i_branch)
        2'b01: begin // BEQ
            o_PCSrc = w_zero;
            o_pcBranch = w_branchPC;
        end
        2'b10: begin
            if(i_jumpType) begin // JAL o J
                o_PCSrc = 1;
                o_pcBranch = w_jumpPC;
            end
            else begin // JR o JALR
                o_PCSrc = 1;
                o_pcBranch = w_jumpPC;
            end
        end
        2'b11: begin // BNE
            o_PCSrc = !w_zero;
            o_pcBranch = w_branchPC;
        end
        default: begin
            o_PCSrc = 0;
            o_pcBranch = 0;
        end
        //default: begin // BEQ, BNE
        //    //Bit bajo de branch indica si es instruccion de branch
        //    //Bit alto indica si es equal o not equal
        //    o_PCSrc = i_branch[0] & (i_branch[1] ^ w_zero);       
        //    o_pcBranch = w_branchPC;
        //end
    endcase
end

endmodule
