`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2018 04:17:32 PM
// Design Name: 
// Module Name: ALU
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

module ALU #(parameter WIDTH = 32)
            (A, B, ALUControl, Result);
            
    input         [WIDTH-1:0] A, B;
    input               [4:0] ALUControl;
    output reg  [WIDTH-1:0] Result;
    integer i, Count;
    reg     Flag;
    always @(*)
        case (ALUControl)
            `ALUADD:  Result <= A + B;
            `ALUADDU: Result <= A + B;
            `ALUSUB:  Result <= A - B;
            `ALUSUBU: Result <= A - B;
            `ALUAND:  Result <= A & B;
            `ALUOR:   Result <= A | B;
            `ALUNOR:  Result <= ~(A | B);
            `ALUXOR:  Result <= A ^ B;
            `ALULT:   Result <= ($signed(A) < $signed(B)) ? 1 : 0;
            `ALULTU:  Result <= ($unsigned(A) < $unsigned(B)) ? 1 : 0;
            `ALUSLL:  Result <= A << B;
            `ALUSRL:  Result <= A >> B;
            `ALUSRA:  Result <= A >>> B;
            `ALULUI:  Result <= B << 16;
            `ALUJ:    Result <= (A & 'hF0000000) | B;
            `ALUCLO:  begin
                        i = 31; Count = 32; Flag = 1;
                        while (i >= 0 && Flag) 
                        begin
                            if (~A[i]) 
                            begin
                                Count = 31 - i;
                                Flag = 0;
                            end
                            i = i - 1;
                        end
                        Result = Count;
                     end
            `ALUCLZ:  begin
                        i = 31; Count = 32; Flag = 1;
                        while (i >= 0 && Flag) 
                        begin
                            if (A[i]) 
                            begin
                                Count = 31 - i;
                                Flag = 0;
                            end
                            i = i - 1;
                        end
                        Result = Count;
                     end
            `ALUNOP:  Result <= 0;
            default: Result<=Result;
        endcase
endmodule
