`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2018 04:16:19 PM
// Design Name: 
// Module Name: decoders
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "global_define.v"

module ALUDecoder (
        input       [4:0]  CurrentState,
        input       [31:0] Instr,
        output reg  [4:0]  ControlCode
    );
    
    wire   [5:0] OpCode, Func;
    assign       OpCode = Instr[31:26];
    assign       Func   = Instr[5:0];

    always @(*)
        case (CurrentState)
            `FETCH:   ControlCode <= `ALUADDU;
            `DECODE:
                case (OpCode)
                    `J:   ControlCode <= `ALUJ;
                    `JAL: ControlCode <= `ALUADDU;
                endcase 
            `MEMADDR: ControlCode <= `ALUADDU;
            `BRANCH:  ControlCode <= `ALUSUB;
            default:
                case (OpCode)
                    `SPECIAL:   
                        case (Func) 
                            `SLL:       ControlCode <= `ALUSLL;
                            `SRL:       ControlCode <= `ALUSRL;
                            `SRA:       ControlCode <= `ALUSRA;
                            `SLLV:      ControlCode <= `ALUSLL;
                            `SRLV:      ControlCode <= `ALUSRL;
                            `SRAV:      ControlCode <= `ALUSRA;
                            `JR:        ControlCode <= `ALUADDU;
                            `JALR:      ControlCode <= `ALUADDU;
                            `MOVZ:      ControlCode <= `ALUADDU;
                            `MOVN:      ControlCode <= `ALUADDU;
                            `ADD:       ControlCode <= `ALUADD;
                            `ADDU:      ControlCode <= `ALUADDU;
                            `SUB:       ControlCode <= `ALUSUB;
                            `SUBU:      ControlCode <= `ALUSUBU;
                            `AND:       ControlCode <= `ALUAND;
                            `OR:        ControlCode <= `ALUOR;
                            `XOR:       ControlCode <= `ALUXOR;
                            `NOR:       ControlCode <= `ALUNOR;
                            `SLT:       ControlCode <= `ALULT;
                            `SLTU:      ControlCode <= `ALULTU;
                            default:    ControlCode <= `ALUNOP;
                        endcase
                    `SPECIAL2:  
                        case (Func)
                            `CLO:       ControlCode <= `ALUCLO;
                            `CLZ:       ControlCode <= `ALUCLZ;
                            default:    ControlCode <= `ALUNOP;
                        endcase
                    `JAL:     ControlCode <= `ALUJ;
                    `REGIMM:  ControlCode <= `ALUADDU;
                    `BEQ:     ControlCode <= `ALUADDU;
                    `BNE:     ControlCode <= `ALUADDU;
                    `BLEZ:    ControlCode <= `ALUADDU;
                    `BGTZ:    ControlCode <= `ALUADDU;
                    `ADDI:    ControlCode <= `ALUADD;
                    `ADDIU:   ControlCode <= `ALUADDU;
                    `SLTI:    ControlCode <= `ALULT;
                    `SLTIU:   ControlCode <= `ALULTU;
                    `ANDI:    ControlCode <= `ALUAND;
                    `XORI:    ControlCode <= `ALUXOR;
                    `ORI:     ControlCode <= `ALUOR;
                    `LUI:     ControlCode <= `ALULUI;
                    `LB:      ControlCode <= `ALUADDU;
                    `LH:      ControlCode <= `ALUADDU;
                    `LBU:     ControlCode <= `ALUADDU;
                    `LHU:     ControlCode <= `ALUADDU;
                    `LWL:     ControlCode <= `ALUADDU;
                    `LW:      ControlCode <= `ALUADDU;
                    `LWC1:    ControlCode <= `ALUADDU;
                    `LWR:     ControlCode <= `ALUADDU;
                    `SB:      ControlCode <= `ALUADDU;
                    `SH:      ControlCode <= `ALUADDU;
                    `SWL:     ControlCode <= `ALUADDU;
                    `SW:      ControlCode <= `ALUADDU;
                    `SWC1:    ControlCode <= `ALUADDU;
                    `SWR:     ControlCode <= `ALUADDU;
                    default:  ControlCode <= `ALUNOP;
                endcase
        endcase
endmodule

module FLUDecoder (
        input       [31:0] Instr,
        output reg  [10:0] ControlCode
    );
    always @(*)
        case (Instr[31:26])
            `FLOATOP: ControlCode = {Instr[25:21],Instr[5:0]};
            default:  ControlCode = `FLU_DISABLE;
        endcase
endmodule

module MLUDecoder (
        input       [31:0] Instr,
        output reg  [1:0]  ControlCode
    );
    
    always @(*)
        case (Instr[31:26])
            `SPECIAL:
                case (Instr[6:0])
                    `MULT:   ControlCode = `MLUMULT;
                    `MULTU:  ControlCode = `MLUMULTU;
                    `DIV:    ControlCode = `MLUDIV;
                    default: ControlCode = `MLUNOP;
                endcase
            default: ControlCode = `MLUNOP;
        endcase
endmodule

module Decoder2to4 (S2, S1, D0, D1, D2, D3);
    input      S2, S1;
    output reg D0, D1, D2, D3;
    
    wire [1:0] Combine;
    assign Combine = {S2, S1};
    
    always @(*) begin
        D0 = 0; D1 = 0; D2 = 0; D3 = 0;
        case (Combine)
            2'b00: D0 = 1;
            2'b01: D1 = 1;
            2'b10: D2 = 1;
            2'b11: D3 = 1;
        endcase
    end
    
endmodule

module Decoder3to8 (S3, S2, S1, D0, D1, D2, D3, D4, D5, D6, D7);
    input        S3, S2, S1;
    output reg   D0, D1, D2, D3, D4, D5, D6, D7;
    
    wire   [2:0] Combine;
    assign       Combine = {S3, S2, S1};
    
    always @(*) begin
        D0 <= 0; D1 <= 0; D2 <= 0; D3 <= 0; 
        D4 <= 0; D5 <= 0; D6 <= 0; D7 <= 0;
        case (Combine)
            3'b000: D0 = 1;
            3'b001: D1 = 1;
            3'b010: D2 = 1;
            3'b011: D3 = 1;
            3'b100: D4 = 1;
            3'b101: D5 = 1;
            3'b110: D6 = 1;
            3'b111: D7 = 1;
        endcase
    end
endmodule
