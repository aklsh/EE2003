//**************************************************************
// Assignment 3
// File name: dummydecoder.v
// Last modified: 2020-09-12 09:44
// Created by: Akilesh Kannan EE18B122
// Description: Instruction Decoder
//              - Temporary decoder: only for ALU ops
//
//**************************************************************

module dummydecoder ( input [31:0] instr,  // Full 32-b instruction
                      output [5:0] op,     // some operation encoding of your choice
                      output [4:0] rs1,    // First operand
                      output [4:0] rs2,    // Second operand
                      output [4:0] rd,     // Output reg
                      input  [31:0] r_rv2, // From RegFile
                      output [31:0] rv2,   // To ALU
                      output we            // Write to reg
                    );

    // using intermediate registers to perform operations, for rv2, op
    reg [31:0] rv2_r;
    reg [5:0] op_r;

    // using localparam for readability
    localparam IMM_type = 1'b0;
    localparam REG_type = 1'b1;

    // funct3 field of instruction
    wire [2:0] funct3_w;
    assign funct3_w = instr[14:12];

    // imm field of instruction
    wire [31:0] immediate_w;
    assign immediate_w = {{20{instr[31]}}, instr[31:20]}; // sign-extending to 32 bits

    // shamt field of the instruction
    wire [31:0] shamt_w;
    assign shamt_w = {{27{1'b0}}, instr[24:20]}; // sign-extending to 32 bits (positive numbers only)

    ////////////////////////////////////////////////////////////////////////////////////
    // Decoder logic
    // -------------
    // *    instr[5] -> decide immediate instruction or not (0 for immediate)
    // *    funct3 -> use as opcode (T&C apply below)
    // *    if (imm_type)
    //          if (funct3 == 'b101) --> have conflict for SRLI and SRAI
    //              if (instr[30] == 1)
    //                  opcode = SRA
    //              else
    //                  opcode = SRL
    //
    // *    if (reg_type)
    //          if (funct3 == 'b000) --> have conflict for ADD, SUB
    //              if (instr[30] == 1)
    //                  opcode = ADD
    //              else
    //                  opcode = SUB
    //          else if (funct3 == 'b101) --> have conflict for SRL and SRA
    //              if (instr[30] == 1)
    //                  opcode = SRA
    //              else
    //                  opcode = SRL
    //
    // Refer to alu32.v for exact opcodes
    ////////////////////////////////////////////////////////////////////////////////////

    always @(instr, r_rv2) begin
        // classify into immediate or register type
        case (instr[5])
            // Imm type instruction
            IMM_type: begin
                case (funct3_w)
                    3'd0,
                    3'd2,
                    3'd3,
                    3'd4,
                    3'd6,
                    3'd7: begin
                        op_r = {3'd0, funct3_w};
                        rv2_r = immediate_w;
                    end
                    3'd1: begin
                        op_r = {3'd0, funct3_w};
                        rv2_r = shamt_w;
                    end
                    3'd5: begin
                        op_r = (instr[30]) ? 6'd8:6'd5;
                        rv2_r = shamt_w;
                    end
                    default: begin
                        op_r = {3'd0, funct3_w};
                        rv2_r = immediate_w;
                    end
                endcase
            end
            // Reg type instruction
            REG_type: begin
                rv2_r = r_rv2;
                case(funct3_w)
                    3'd1,
                    3'd2,
                    3'd3,
                    3'd4,
                    3'd6,
                    3'd7:
                        op_r = {3'd0, funct3_w};
                    3'd0:
                        op_r = (instr[30]) ? 6'd9:6'd0;
                    3'd5:
                        op_r = (instr[30]) ? 6'd8:6'd5;
                    default:
                        op_r = {3'd0, funct3_w};
                endcase
            end
        endcase
    end

    // assigning outputs
    assign op = op_r;
    assign rv2 = rv2_r;
    assign rs1 = instr[19:15];
    assign rs2 = instr[24:20];
    assign rd = instr[11:7];
    assign we = 1'b1;     // For only ALU ops, can always set to 1

endmodule
