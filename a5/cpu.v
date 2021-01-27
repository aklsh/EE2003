//**************************************************************
// Assignment 5
// File name: cpu.v
// Last modified: 2020-09-30 12:07
// Created by: Akilesh Kannan EE18B122
// Description: CPU Module
//              - 32 bit CPU
//              - Supports Branch, Jump, PC Modification,
//                Arithmetic and Logical Instructions specified
//                in RV32I base instruction set
// TODO: create a separate module for calculating the
//       dwe and drdata_RF fields
//**************************************************************

module cpu ( input clk,             // clock signal
             input reset,           // reset signal (synchronous)
             output [31:0] iaddr,   // PC value
             input [31:0] idata,    // instruction
             output [31:0] daddr,   // dMEM address bus
             input [31:0] drdata,   // dMEM read value
             output [31:0] dwdata,  // dMEM write value
             output [3:0] dwe       // dMEM write enable signals
           );

    reg [31:0] iaddr; // iMEM address address in current clock cycle

    // MUX Select signals
    wire dMEMMuxSel, immMuxSel;

    // RegFile ports
    wire we_RF;
    wire [4:0] rs1_RF, rs2_RF, rd_RF;
    wire [31:0] wdata_RF, rv1_RF, rv2_RF;
    reg [31:0] drdata_RF;

    // ALU ports
    wire [5:0] op_ALU;
    wire [31:0] rv1_ALU, rv2_ALU, out_ALU;

    // Immediate Generator ports
    wire [31:0] immediate;

    // dMEM-related ports
    reg [3:0] dwe_r;
    reg [31:0] maskedDWData_r;

    // localparam statements for opcodes
    localparam LUI = 7'b0110111;
    localparam AUIPC = 7'b0010111;
    localparam LXX = 7'b0000011;
    localparam SXX = 7'b0100011;
    localparam IXX = 7'b0010011;
    localparam RXX = 7'b0110011;

    // PC calculations
    always @(posedge clk) begin
        // if reset, set to -4, so that at next clock,
        // instruction 0 gets executed
        if (reset) begin
            iaddr <= -4;
        end
        else begin
            // PC -> PC+4, as word size = 32bits
            // i.e., 4 bytes (and 1 byte is convention)
            iaddr <= iaddr + 32'd4;
        end
    end

    // Instantiate CPU Control module
    control cntrl(
        .idata(idata),
        .reset(reset),
        .dMEMToReg(dMEMMuxSel),
        .aluOp(op_ALU),
        .rs1(rs1_RF),
        .rs2(rs2_RF),
        .rd(rd_RF),
        .regOrImm(immMuxSel),
        .regWrite(we_RF)
    );

    // Instantiate Immediate Generator module
    immGen ig(
        .idata(idata),
        .imm(immediate)
    );

    // Instantiate ALU
    alu32 alu(
        .op(op_ALU),
        .rv1(rv1_ALU),
        .rv2(rv2_ALU),
        .rvout(out_ALU)
    );

    // Instantiate Register File
    regfile rf(
        .clk(clk),
        .rs1(rs1_RF),
        .rs2(rs2_RF),
        .rd(rd_RF),
        .we(we_RF),
        .wdata(wdata_RF),
        .rv1(rv1_RF),
        .rv2(rv2_RF)
    );

    assign rv1_ALU = (idata[6:0] == AUIPC) ? iaddr : rv1_RF;
    assign rv2_ALU = (immMuxSel) ? immediate : rv2_RF;
    assign wdata_RF = (dMEMMuxSel) ? drdata_RF : out_ALU;
    assign dwe = ~reset & dwe_r;
    assign daddr = out_ALU;
    assign dwdata = maskedDWData_r;

    always @(idata, daddr) begin
        // STORE Instructions
        if (idata[6:0] === SXX) begin
            case(idata[14:12])
                // SB
                3'b000: begin
                    maskedDWData_r = {4{rv2_RF[7:0]}};     // repeat the last byte 4 times as write data
                    // set write enable accordingly
                    case(daddr[1:0])
                        2'b00:
                            dwe_r = 4'b0001;
                        2'b01:
                            dwe_r = 4'b0010;
                        2'b10:
                            dwe_r = 4'b0100;
                        2'b11:
                            dwe_r = 4'b1000;
                    endcase
                end
                // SH
                3'b001: begin
                    maskedDWData_r = {2{rv2_RF[15:0]}};     // repeat last half-word 2 times as write data
                    // set write enable accordingly
                    case(daddr[1:0])
                        2'b00:
                            dwe_r = 4'b0011;
                        2'b10:
                            dwe_r = 4'b1100;
                        default:
                            dwe_r = 4'b0000;
                    endcase
                end
                // SW
                3'b010: begin
                    maskedDWData_r = rv2_RF;
                    // set write enable accordingly
                    case(daddr[1:0])
                        2'b00:
                            dwe_r = 4'b1111;
                        default:
                            dwe_r = 4'b0000;
                    endcase
                end
                default:
                    dwe_r = 4'b0000;
            endcase
        end
        else
            dwe_r = 4'b0000;

        // LOAD Instructions
        if (idata[6:0] === LXX) begin
            case(idata[14:12])
                // LB
                3'b000: begin
                    // read the byte accordingly depending on daddr
                    case(daddr[1:0])
                        2'b00:
                            drdata_RF = $signed(drdata[7:0]);
                        2'b01:
                            drdata_RF = $signed(drdata[15:8]);
                        2'b10:
                            drdata_RF = $signed(drdata[23:16]);
                        2'b11:
                            drdata_RF = $signed(drdata[31:24]);
                    endcase
                end
                // LH
                3'b001: begin
                    // read the half-word accordingly depending on daddr
                    case(daddr[1:0])
                        2'b00:
                            drdata_RF = $signed(drdata[15:0]);
                        2'b10:
                            drdata_RF = $signed(drdata[31:16]);
                        default:
                            drdata_RF = 32'b0;
                    endcase
                end
                // LW
                3'b010: begin
                    drdata_RF = drdata;
                end
                // LBU
                3'b100: begin
                    // read the byte accordingly depending on daddr
                    case(daddr[1:0])
                        2'b00:
                            drdata_RF = drdata[7:0];
                        2'b01:
                            drdata_RF = drdata[15:8];
                        2'b10:
                            drdata_RF = drdata[23:16];
                        2'b11:
                            drdata_RF = drdata[31:24];
                    endcase
                end
                // LHU
                3'b101: begin
                    // read the half-word accordingly depending on daddr
                    case(daddr[1:0])
                        2'b00:
                            drdata_RF = drdata[15:0];
                        2'b10:
                            drdata_RF = drdata[31:16];
                        default:
                            drdata_RF = 32'b0;
                    endcase
                end
                default: begin
                    drdata_RF = 32'b0;
                end
            endcase
        end
        else
            drdata_RF = 32'b0;
    end

endmodule
