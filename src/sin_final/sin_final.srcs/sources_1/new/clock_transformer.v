`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/09/2018 07:16:55 AM
// Design Name: 
// Module Name: ClockTransformer
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


module ClockTransformer(
  input wire  CLK_IN,  //输入时钟
              RST,     //重置计数
  input wire[2:0] 
              FACTOR,  //放大指数
  output reg  CLK_OUT  //输出时钟
);
  
reg[31:0] factor;
//  rom32x32 factor_lookup(
//  .address(FACTOR),
//  .clock(CLK_IN),
//  .q(factor)
//  );
always @(*)
  case (FACTOR)
    3'b000: factor<=32'd1;
    3'b001: factor<=32'd10;
    3'b010: factor<=32'd100;
    3'b011: factor<=32'd1000;
    3'b100: factor<=32'd10000;
    3'b101: factor<=32'd100000;
    3'b110: factor<=32'd1000000;
    3'b111: factor<=32'd10000000;
  endcase
  
//  wire[31:0] half_factor;
//  assign half_factor=factor/2;
  
//  always@(posedge CLK_IN)begin
//  if(factor>3)
//    half_factor=factor/2;
//  else
//    half_factor=2;
//  end
  
wire [31:0] total_t;
Counter #(32) clk_counter(
  .CLK(CLK_IN),
  .RST(RST),
  .MIN(0),
  .MAX(factor),
  .CT(total_t)
);

always@(total_t) begin
  if((total_t==0)||factor==1)
    CLK_OUT=CLK_IN;
  else
    CLK_OUT=CLK_OUT;
  end

endmodule
