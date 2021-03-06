//**************************************************************
// Assignment 3
// File name: regfile.v
// Last modified: 2020-09-12 09:37
// Created by: Akilesh Kannan EE18B122
// Description: Register File
//              - 32, 32-bit internal registers
//              - 2 read ports, 1 write port
//              - Read ports - combinational
//              - Write port - synchronous with posedge
//
//**************************************************************

module regfile ( input [4:0] rs1,     // address of first operand to read - 5 bits
                 input [4:0] rs2,     // address of second operand
                 input [4:0] rd,      // address of value to write
                 input we,            // should write update occur
                 input [31:0] wdata,  // value to be written
                 output [31:0] rv1,   // First read value
                 output [31:0] rv2,   // Second read value
                 input clk            // Clock signal - all changes at clock posedge
               );

    // Desired function
    // rv1, rv2 are combinational outputs - they will update whenever rs1, rs2 change
    // on clock edge, if we=1, regfile entry for rd will be updated

    // 32, 32-bit internal registers
    reg [31:0] internalRegisters [0:31];
    reg [31:0] rv1_r, rv2_r;

    integer i;
    initial begin
        for (i=0;i<32;i=i+1)
            internalRegisters[i] = 32'b0;
    end

    // synchronous write operations
    always @(posedge clk) begin
        if (we == 1'b1)
            internalRegisters[rd] <= wdata;
    end

    // combinational read operations
    always @(rs1, rs2) begin
        rv1_r = internalRegisters[rs1];
        rv2_r = internalRegisters[rs2];
    end

    // assigning outputs
    assign rv1 = rv1_r;
    assign rv2 = rv2_r;

endmodule
