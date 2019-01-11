`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2018 04:27:26 PM
// Design Name: 
// Module Name: registers
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

module GeneralRegisters #(parameter WIDTH = 32, REGBITS = 5, MEMUNITS = 4096) (
        input                         CLK, Reset, WE3, FMODE,
        input        [REGBITS-1:0]    A1, A2, A3,
        input        [WIDTH-1:0]      WD3,
        output       [WIDTH-1:0]      RD1, RD2
    );
    
    reg [WIDTH-1:0] GeneralRegisters [(1<<REGBITS)-1:0];
    localparam SP = 29;
    integer i;
    always @(posedge CLK)
        if (Reset) begin
            for (i = 0; i < (1<<REGBITS); i = i + 1) begin
                GeneralRegisters[i] <=  0 ;
            end
            GeneralRegisters[SP] <=  32'h00003ffc ;
        end
        else if(WE3)
            GeneralRegisters[A3] <= WD3;

    wire [WIDTH-1:0] one_or;
    assign one_or = FMODE?32'hffffffff:32'b0;
    assign RD1 = A1|one_or ? GeneralRegisters[A1] : 0;
    assign RD2 = A2|one_or ? GeneralRegisters[A2] : 0;
endmodule
