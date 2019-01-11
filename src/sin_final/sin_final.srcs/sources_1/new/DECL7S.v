module DECL7S (A, LED7S);
    input [3:0] A;
    output reg [7:0] LED7S;
    
    always @(*)
      begin 
        case(A)
          4'b0000: LED7S <= 8'b11111100; //显示0
          4'b0001: LED7S <= 8'b01100000;//显示1 
          4'b0010: LED7S <= 8'b11011010; //显示2
          4'b0011: LED7S <= 8'b11110010; //显示3
          4'b0100: LED7S <= 8'b01100110;//显示4
          4'b0101: LED7S <= 8'b10110110; //显示5
          4'b0110: LED7S <= 8'b10111110;//显示6
          4'b0111: LED7S <= 8'b11100000;//显示7
          4'b1000: LED7S <= 8'b11111110; //显示8
          4'b1001: LED7S <= 8'b11110110; //显示9
          4'b1010: LED7S <= 8'b00000010; //显示-
          4'b1011: LED7S <= 8'b11111101; //显示0.
          4'b1100: LED7S <= 8'b01100001; //显示1.
       endcase 
      end
endmodule
