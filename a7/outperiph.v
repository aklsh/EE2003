//**************************************************************
// Assignment 7
// File name: outperiph.v
// Last modified: 2020-11-28 19:36
// Created by: Akilesh Kannan
// Description: Output Peripheral
//**************************************************************

`timescale 1ns/1ps
`define OUTFILE "output.txt"

module outperiph (
    input clk,
    input reset,
    input [31:0] daddr,
    input [31:0] dwdata,
    input [3:0] dwe,
    output [31:0] drdata
);

    // Implement the peripheral logic here: use $fwrite to the file output.txt
    // Use the `define above to open the file so that it can be
    // overridden later if needed

    // Return value from here (if requested based on address) should
    // be the number of values written so far

    reg [31:0] drdata_r;
    wire [31:0] writeData;
    integer outPeriph;

    // open file
    initial
        outPeriph = $fopen(`OUTFILE, "a");

    always @(posedge clk) begin
        // reset counter
        if(reset)
            drdata_r <= 0;
        else begin
            // check if address matches
            if (daddr === 1'b1 << 14) // 14'b1000...000 is location of peripheral
                if (dwe != 4'b0) begin
                    $fwrite(outPeriph, "%c", writeData);
                    drdata_r <= drdata_r + 1'b1;
                end
        end
    end

    // write only the required bytes according to dwe (although it doesn't matter as compiler chooses only 4'b1111)
    assign writeData = dwdata & {{8{dwe[3]}}, {8{dwe[2]}}, {8{dwe[1]}}, {8{dwe[0]}}};
    assign drdata = (daddr === (1'b1<<13) + 3'b100) ? drdata_r : 0;

endmodule
