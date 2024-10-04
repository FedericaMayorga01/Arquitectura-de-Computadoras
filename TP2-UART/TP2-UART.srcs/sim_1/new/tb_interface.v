`timescale 1ns/1ps

module tb_interface_module;

    // Parameters
    parameter NB_INTERFACEMODULE_DATA = 8;
    parameter NB_INTERFACEMODULE_OP   = 6;
    parameter CLK_PERIOD              = 10;  // Clock period in ns (100 MHz clock)

    // Testbench input signals
    reg i_clk;
    reg i_reset;
    reg i_interfacemodule_read;
    reg i_interfacemodule_empty;
    reg i_interfacemodule_full;
    reg [NB_INTERFACEMODULE_DATA-1:0] i_interfacemodule_data;
    reg signed [NB_INTERFACEMODULE_DATA-1:0] i_alu_result;

    // Testbench output signals
    wire signed [NB_INTERFACEMODULE_DATA-1:0] o_alu_data_A;
    wire signed [NB_INTERFACEMODULE_DATA-1:0] o_alu_data_B;
    wire [NB_INTERFACEMODULE_OP-1:0] o_alu_OP;
    wire o_interfacemodule_readdata;
    wire o_interfacemodule_write;
    wire signed [NB_INTERFACEMODULE_DATA-1:0] o_interfacemodule_writedata;
    wire signed [NB_INTERFACEMODULE_DATA-1:0] o_result_data;

    // Instantiate the Unit Under Test
    interface_module #(
        .NB_INTERFACEMODULE_DATA(NB_INTERFACEMODULE_DATA),
        .NB_INTERFACEMODULE_OP(NB_INTERFACEMODULE_OP)
    ) uut (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_interfacemodule_read(i_interfacemodule_read),
        .i_interfacemodule_empty(i_interfacemodule_empty),
        .i_interfacemodule_full(i_interfacemodule_full),
        .i_interfacemodule_data(i_interfacemodule_data),
        .i_alu_result(i_alu_result),
        .o_interfacemodule_readdata(o_interfacemodule_readdata),
        .o_interfacemodule_write(o_interfacemodule_write),
        .o_interfacemodule_writedata(o_interfacemodule_writedata),
        .o_alu_data_A(o_alu_data_A),
        .o_alu_data_B(o_alu_data_B),
        .o_alu_OP(o_alu_OP),
        .o_result_data(o_result_data)
    );

    // Clock generation
    initial begin
        i_clk = 0;
        forever #(CLK_PERIOD / 2) i_clk = ~i_clk;  // Toggle clock every 5 ns
    end

    initial begin
        // Initialize signals
        i_clk = 0;
        i_reset = 1;

        i_interfacemodule_read  = 0;
        i_interfacemodule_empty = 1;
        i_interfacemodule_full  = 0;
        i_interfacemodule_data  = 0;
        i_alu_result = 0;

        // Reset pulse
        #10 i_reset = 0;

        // Case 1: Simulate reading data A and B from FIFO and sending to ALU
        #10;
        i_interfacemodule_empty = 0;
        i_interfacemodule_read  = 1;
        i_interfacemodule_data  = 8'b0000_1010; // First data (A)
        #10;
        i_interfacemodule_data = 8'b0000_0011; // Second data (B)
        #10;
        i_interfacemodule_data = 8'b0000_0011; // Operand (ALU operation)

        // Case 2: Provide ALU result
        #10;
        i_alu_result = 8'b1111_1000;  // ALU result value (example)

        // Case 3: Write the result to FIFO Tx
        #20;
        i_interfacemodule_full = 0;

        // Check if the write output is asserted and value is correct
        #20;
        if (o_interfacemodule_write && o_interfacemodule_writedata == i_alu_result)
            $display("Test Passed!");
        else
            $display("Test Failed!");

        // End simulation
        #100;
        $finish;
    end
endmodule