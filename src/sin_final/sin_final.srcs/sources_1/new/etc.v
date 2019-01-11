`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2018 04:22:47 PM
// Design Name: 
// Module Name: etc
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

module ZeroDetect #(parameter WIDTH = 32)
                   (A, Zero);
    
    input  [WIDTH-1:0] A;
    output reg           Zero;
    
    always @(*)
        Zero <= (A == 0) ? 1 : 0;
    
endmodule

module SignDetect #(parameter WIDTH = 32)
                   (A, Sign);
    input  [WIDTH-1:0] A;
    output Sign;
    assign   Sign = A[WIDTH-1];
endmodule

module OverflowDetect #(parameter WIDTH = 32)
                       (Result, A, B, AluControl, Overflow);
                       
    input [WIDTH-1:0] Result, A, B;
    input         [4:0] AluControl;
    output reg          Overflow;

    always @(*)
        case (AluControl)
            5'b00000: Overflow = ((A[WIDTH-1] == B[WIDTH-1]) && (A[WIDTH-1] != Result[WIDTH-1])) ? 1 : 0;
            5'b00010: Overflow = ((A[WIDTH-1] != B[WIDTH-1]) && (A[WIDTH-1] != Result[WIDTH-1])) ? 1 : 0;
            default: Overflow = 1'b0;
        endcase
        
endmodule

module Flop #(parameter WIDTH = 32)
             (CLK, D, Q);
             
    input                     CLK;
    input         [WIDTH-1:0] D;
    output reg  [WIDTH-1:0] Q;
             
    always @(posedge CLK)
        Q <= D;
    
endmodule

module FlopEn #(parameter WIDTH = 32)
               (CLK, En, D, Q);
               
    input                    CLK, En;
    input         [WIDTH-1:0] D;
    output reg  [WIDTH-1:0] Q;
    
    always @(posedge CLK)
        if (En) Q <= D;
    
endmodule

module FlopEnReset #(parameter WIDTH = 32)
                    (CLK, En, Reset, D, Q);
        
    input                    CLK, En, Reset;
    input         [WIDTH-1:0] D;
    output reg  [WIDTH-1:0] Q;
    
    always @(posedge CLK)
        if (Reset) Q <= 0;
        else if (En) Q <= D;
        
endmodule

module Mux2 #(parameter WIDTH = 32)
             (D0, D1, Cond, Result);
    
    
    input                   Cond;
    input      [WIDTH-1:0] D0, D1;
    output     [WIDTH-1:0] Result;
             
    assign Result = Cond ? D1 : D0;
             
endmodule

module Mux4 #(parameter WIDTH = 32)
             (D0, D1, D2, D3, Cond, Result);
        
    input                [1:0] Cond;
    input      [WIDTH-1:0] D0, D1, D2, D3;
    output reg [WIDTH-1:0] Result;
    
    always @(*)
        case (Cond)
            2'b00: Result <= D0;
            2'b01: Result <= D1;
            2'b10: Result <= D2;
            2'b11: Result <= D3;
        endcase
        
endmodule

module Mux8 #(parameter WIDTH = 32)
             (D0, D1, D2, D3, D4, D5, D6, D7, Cond, Result);
        
    input                [2:0] Cond;
    input         [WIDTH-1:0] D0, D1, D2, D3, D4, D5, D6, D7;
    output reg [WIDTH-1:0] Result;
    
    always @(*)
        case (Cond)
            3'b000: Result <= D0;
            3'b001: Result <= D1;
            3'b010: Result <= D2;
            3'b011: Result <= D3;
            3'b100: Result <= D4;
            3'b101: Result <= D5;
            3'b110: Result <= D6;
            3'b111: Result <= D7;
        endcase
        
endmodule

module Mux16 #(parameter WIDTH = 32)(
        input         [WIDTH-1:0] D0, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, D11, D12, D13, D14, D15,
        input         [3:0]       Cond,
        output reg    [WIDTH-1:0] Result
    );
    always @(*)
        case (Cond)
            4'b0000: Result <= D0;
            4'b0001: Result <= D1;
            4'b0010: Result <= D2;
            4'b0011: Result <= D3;
            4'b0100: Result <= D4;
            4'b0101: Result <= D5;
            4'b0110: Result <= D6;
            4'b0111: Result <= D7;
            4'b1000: Result <= D8;
            4'b1001: Result <= D9;
            4'b1010: Result <= D10;
            4'b1011: Result <= D11;
            4'b1100: Result <= D12;
            4'b1101: Result <= D13;
            4'b1110: Result <= D14;
            4'b1111: Result <= D15;
        endcase
endmodule

module SignedCompare (Zero, Sign, Overflow, ALUSignCond, ALUCompare);
    
    input        Zero, Sign, Overflow;
    input  [2:0] ALUSignCond;
    
    output reg   ALUCompare;
    
    always @(*)
        case (ALUSignCond)
            `ALU_TRUE_POSITIVE: ALUCompare <= ((~Zero) & (Sign ^~ Overflow));
            `ALU_OVERFLOW: ALUCompare <= (Sign ^ Overflow);
            `ALU_ZERO: ALUCompare <= (Zero);
            `ALU_X: ALUCompare <= 1'bx;
            `ALU_POSITIVE: ALUCompare <= (~Zero);
            `ALU_NO_OVERFLOW: ALUCompare <= (Sign ^~ Overflow);
            `ALU_ZERO_OR_OVERFLOW: ALUCompare <= (Zero | (Sign ^ Overflow));
            default: ALUCompare<=ALUCompare;
//            3'b111: ALUCompare <= 1'bx;
        endcase
endmodule

//module #(WIDTH = 32) RegTransfer(
//    input [4:0] CurrentState,
//    input [WIDTH-1:0] DATA,,
    
//    );
    
//endmodule
