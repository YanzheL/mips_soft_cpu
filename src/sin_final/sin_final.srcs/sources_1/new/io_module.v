`timescale 1ns / 1ps

module DataInput(
        input [7:0] m,
        input mid_button_signal,
        output reg [7:0] current_value,
        output reg SIGN
    );
    always @(negedge mid_button_signal) begin
        current_value<=m;
        if(m % 360 < 180)
            SIGN=0;
        else
            SIGN=1;
    end    
endmodule


module DataOutput(
        input CLK,RST,
        input SIGN,
        input [31:0] DATA,
        output [7:0] LED_ENCODE,
        output [7:0] LED_SELECT
    );

    wire [3:0] count;
    //assign LED_ENCODE[0] = (~SIGN & (count == 3'b000) ) | SIGN & count == 3'b001;
    assign LED_SELECT = 1<<count;
//    wire [31:0] DATA;
//    assign DATA = 32'h12345678;

    Counter #(4) counter(
        .CLK(CLK),
        .MIN(4'b0),
        .MAX(4'b1000),
        .CT(count),
        .RST(RST)
    );
    reg [31:0] NEW_DATA;
    wire [3:0] with_dot;
    assign with_dot = DATA[31:28] + 4'b1011;
    always@(posedge CLK) begin
            if(~RST)
                NEW_DATA <= 32'b0;
            else if(SIGN)
                NEW_DATA <= {4'b1010, with_dot, DATA[27:4]};
            else
                NEW_DATA <= {with_dot, DATA[27:0]};
    end
    reg [3:0] data;

    always@(*)
        case(count)
            4'b0000:data=NEW_DATA[3:0];
            4'b0001:data=NEW_DATA[7:4];
            4'b0010:data=NEW_DATA[11:8];
            4'b0011:data=NEW_DATA[15:12];
            4'b0100:data=NEW_DATA[19:16];
            4'b0101:data=NEW_DATA[23:20];
            4'b0110:data=NEW_DATA[27:24];
            4'b0111:data=NEW_DATA[31:28];
            default: data = 4'b0000;
        endcase            
    DECL7S display_decoder(
        .A(data[3:0]),
        .LED7S(LED_ENCODE[7:0])
    );

endmodule

module Counter #(CTBITS = 32)(
        input wire      CLK,
                        RST,
        input wire[CTBITS-1:0]
                        MIN,
                        MAX,
        output reg[CTBITS-1:0]
                        CT
    );

    always @(posedge CLK or negedge RST) 
        if(~RST)
            CT=0;
        else if((MIN!=MAX)&&(CT==MAX-1))
            CT=MIN;
        else
            CT=CT+1;    
endmodule
