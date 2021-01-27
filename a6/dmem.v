//**************************************************************
// Assignment 5
// File name: dmem.v
// Last modified: 2020-10-01 12:25
// Created by: Akilesh Kannan EE18B122
// Description: Data Memory
// TODO: Parameterise line numbers and (word size?)
//**************************************************************

`timescale 1ns/1ps
`define DMEM_N_FILE(x,y) {x,y,".mem"}

module dmem ( input clk,                // clock input
              input [31:0] daddr,       // start address to read/write to/from
              input [31:0] dwdata,      // write data bus
              input [3:0] dwe,          // write enable
              output [31:0] drdata      // read data bus
            );

    //////////////////////////////////////////////////////////////////
    // Data Memory is designed like this, and is byte-addressable
    // -> 4K location, 16KB total, split in 4 banks
    //
    //                Byte 0     Byte 1     Byte 2     Byte 3
    //             +----------+----------+----------+----------+
    // line x      |          |          |          |          |
    //             +----------+----------+----------+----------+
    // line x+1    |          |          |          |          |
    //             +----------+----------+----------+----------+
    // line number -> address
    //
    //////////////////////////////////////////////////////////////////

    reg [7:0] mem0[0:4095];
    reg [7:0] mem1[0:4095];
    reg [7:0] mem2[0:4095];
    reg [7:0] mem3[0:4095];

    // line number for dMEM
    wire [29:0] a;

    // initialise memory banks
    initial begin
        $readmemh({`TESTDIR,"/data0.mem"}, mem0);
        $readmemh({`TESTDIR,"/data1.mem"}, mem1);
        $readmemh({`TESTDIR,"/data2.mem"}, mem2);
        $readmemh({`TESTDIR,"/data3.mem"}, mem3);
    end

    // assigning line number
    assign a = daddr[13:2];

    // Selecting bytes to be done inside CPU
    assign drdata = { mem3[a], mem2[a], mem1[a], mem0[a]};

    // synchronous write
    always @(posedge clk) begin
        if (dwe[3]) mem3[a] <= dwdata[31:24];
        if (dwe[2]) mem2[a] <= dwdata[23:16];
        if (dwe[1]) mem1[a] <= dwdata[15: 8];
        if (dwe[0]) mem0[a] <= dwdata[ 7: 0];
    end

endmodule
