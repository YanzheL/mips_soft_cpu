`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/07/2018 05:39:47 PM
// Design Name: 
// Module Name: ConditionRegisters
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


module ConditionRegisters #(CONBITS = 3)(
    input               CLK, Reset, WE,
    input [CONBITS-1:0] CC,
    input               WD,
    output              RD
);
//  reg [CONBITS-1:0] ConditionFlags;
  reg [(1<<CONBITS)-1:0] ConditionFlags;
  integer i;
  always @(posedge CLK)
    if (Reset) begin
      for (i = 0; i < (1<<CONBITS); i = i + 1) begin
        ConditionFlags[i] <=  1'b0 ;
      end
    end
    else if(WE)
      ConditionFlags[CC] <= WD;
      
  assign RD = ConditionFlags[CC];
endmodule