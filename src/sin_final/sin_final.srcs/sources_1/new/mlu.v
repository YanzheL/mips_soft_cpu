`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2018 04:19:17 PM
// Design Name: 
// Module Name: MLU
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

module MLU #(parameter WIDTH = 32) (
        input                       CLK,Reset,
        input         [WIDTH-1:0]        A,B,
        input         [1:0]            ControlCode,
        output        [WIDTH-1:0]        Hi,Lo
    );

    reg            [2*WIDTH-1:0]    Result;
    assign    Hi = Result[2*WIDTH-1:WIDTH];
    assign  Lo = Result[WIDTH-1:0];
    wire [2*WIDTH-1:0] mul_res;
    wire sign;
    assign sign = A[WIDTH-1]^B[WIDTH-1];
    wire [WIDTH-1:0] A_Comp = A[WIDTH-1]? ~A+1:A;
    wire [WIDTH-1:0] B_Comp = B[WIDTH-1]? ~B+1:B;
    assign mul_res = A_Comp * B_Comp;
    always    @(*)
        if(Reset) begin
           Result<=0;
        end
        else begin
            case (ControlCode)
                `MLUMULT:  Result <= sign?~mul_res+1:mul_res;
                `MLUMULTU: Result <= A*B;
                `MLUDIV:
                     begin
                         Result[2*WIDTH-1:WIDTH] <= A%B;
                         Result[WIDTH-1:0] <= A/B;
                     end
                 default: Result<=Result;
            endcase
        end
endmodule
