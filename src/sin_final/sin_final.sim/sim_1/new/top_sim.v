`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/08/2018 08:45:33 PM
// Design Name: 
// Module Name: top_sim
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


module top_sim();
    reg   [7:0] buttons;
    reg         CLK,Reset;
    wire [7:0] LED_ENCODE1,LED_ENCODE2, LED_SELECT;
    Top top(
        .buttons(buttons),
        .CLK(CLK),
        .Reset(Reset),
        .LED_ENCODE1(LED_ENCODE1),
        .LED_ENCODE2(LED_ENCODE2),
        .LED_SELECT(LED_SELECT)
    );
    // reset processor
    initial
        begin
            buttons <= 8'h3c;
            #10 Reset <= 1; # 22; Reset <= 0;
            #7000 Reset <= 1; # 10; Reset <= 0;
        end
    // generate clock
    always
        begin
            CLK <= 1; #0.5; CLK <= 0; #0.5;
        end 

endmodule
