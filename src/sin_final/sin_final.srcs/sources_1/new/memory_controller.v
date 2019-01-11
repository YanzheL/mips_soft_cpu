`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2018 04:12:32 PM
// Design Name: 
// Module Name: MemoryController
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


//module MemoryController #(parameter WIDTH = 32, MEMUNITS = 4096)(
//        input                  CLK,Reset,
//        input      [2:0]       MemWrite, MemRead,
//        input      [7:0]       IO_IN,
//        input      [WIDTH-1:0] Addr, WriteData,
//        output     [WIDTH-1:0] ReadData,
//        output reg [WIDTH-1:0] IO_OUT
//    );

////    reg            [WIDTH-1:0] RAM[MEMUNITS-1:0];
//    localparam  BYTEALIGN        = WIDTH / 8 - 1;
//    wire [WIDTH-1:0] AlignedAddr,OffsetHalfWord, OffsetByte;
//    wire [11:0] WordAddr;
//    assign AlignedAddr    = Addr & 'hFFFFFFFC;
//    assign WordAddr = AlignedAddr[13:2];
////    assign OffsetHalfWord = (Addr - AlignedAddr) & 'hFFFFFFFE;
////    assign OffsetByte     = Addr - AlignedAddr;
    
//    wire [WIDTH-1:0] ram_out;
    
//    ExternalMemory ram(
//        .addra(WordAddr),
//        .dina(WriteData),
//        .clka(CLK),
////        .ena(1),
//        .wea(MemWrite==`MEMWORD),
//        .addrb(WordAddr),
//        .doutb(ram_out),
//        .clkb(CLK),
//        .enb(MemRead==`MEMWORD)
////        .rstb(0)
//    );
//    always @(*)
//        case (MemWrite)
//            `MEMWORD: begin     
//                if(Addr=='h00002504)
//                    IO_OUT<=WriteData;
//            end
//        endcase
        
//    assign ReadData = Addr=='h00002500 ? {24'b0,IO_IN} : ram_out;
    
    
////    always @(*)
////        case (MemRead)
////            `MEMWORD: begin      
////                 if(Addr=='h00002500)
////                    ReadData <= {24'b0,IO_IN};
////                 else
////                    ReadData <= ram_out;
////             end
////        endcase
//endmodule

// memory controller accessed by MIPS,we're Little-Endian here.
module MemoryController #(parameter WIDTH = 32, MEMUNITS = 4096)(
        input                  CLK,Reset,
        input      [2:0]       MemWrite, MemRead,
        input      [7:0]       IO_IN,
        input      [WIDTH-1:0] Addr, WriteData,
        output reg [WIDTH-1:0] ReadData,IO_OUT
    );

    reg            [WIDTH-1:0] RAM[MEMUNITS-1:0];
    localparam  BYTEALIGN        = WIDTH / 8 - 1;
//    wire [WIDTH-1:0] AlignedAddr, OffsetHalfWord, OffsetByte;
//    assign AlignedAddr    = Addr & 'hFFFFFFFC;

    initial
       begin
           $readmemh("memory.dat", RAM);
       end
    always @(posedge CLK)
        if(Reset)
            IO_OUT <=32'b0;
        else
        case (MemWrite)
            `MEMWORD: begin     
                if(Addr==32'h00002504)
                    IO_OUT<=WriteData;
                else
                    RAM[Addr[13:2]][31:0] <= WriteData;
             end
        endcase
            
    
    always @(*)
        case (MemRead)
            `MEMWORD:
                 if(Addr==32'h00002500)
                    ReadData <= {24'b0,IO_IN};
                 else
                    ReadData <= RAM[Addr[13:2]][31:0];
            default: ReadData<=ReadData;
        endcase
endmodule

// memory controller accessed by MIPS,we're Little-Endian here.
//module MemoryController #(parameter WIDTH = 32, MEMUNITS = 4096)(
//        input                  CLK,Reset,
//        input      [2:0]       MemWrite, MemRead,
//        input      [7:0]       IO_IN,
//        input      [WIDTH-1:0] Addr, WriteData,
//        output reg [WIDTH-1:0] ReadData,IO_OUT
//    );

//    reg            [WIDTH-1:0] RAM[MEMUNITS-1:0];
//    localparam  BYTEALIGN        = WIDTH / 8 - 1;
//    wire [WIDTH-1:0] AlignedAddr, OffsetHalfWord, OffsetByte;
//    assign AlignedAddr    = Addr & 'hFFFFFFFC;
//    assign OffsetHalfWord = (Addr - AlignedAddr) & 'hFFFFFFFE;
//    assign OffsetByte     = Addr - AlignedAddr;

//    initial
//       begin
//           $readmemh("memory.dat", RAM);
//       end
//    always @(posedge CLK)
//        if(Reset)
//            IO_OUT <=32'b0;
//        else
//        case (MemWrite)
//            `MEMWORD: begin     
//                                if(Addr=='h00002504)
//                                    IO_OUT<=WriteData;
//                                else
//                                    RAM[AlignedAddr>>2][31:0] <= WriteData;
//                      end
//            `MEMWORDLEFT: case (OffsetByte)
//                            3: RAM[AlignedAddr>>2][31:0]  <= WriteData;
//                            2: RAM[AlignedAddr>>2][23:0]  <= WriteData[31:8];
//                            1: RAM[AlignedAddr>>2][15:0]  <= WriteData[31:16];
//                            0: RAM[AlignedAddr>>2][7:0]   <= WriteData[31:24];
//                         endcase
//            `MEMWORDRIGHT:case (OffsetByte)
//                            3: RAM[AlignedAddr>>2][31:24] <= WriteData[7:0];
//                            2: RAM[AlignedAddr>>2][31:16] <= WriteData[15:0];
//                            1: RAM[AlignedAddr>>2][31:8]  <= WriteData[23:0];
//                            0: RAM[AlignedAddr>>2][31:0]  <= WriteData;
//                         endcase
//            `MEMHALFWORD:

//                         case (OffsetHalfWord)
//                                2: RAM[AlignedAddr>>2][31:16] <= WriteData[15:0];
//                                0: RAM[AlignedAddr>>2][15:0]  <= WriteData[15:0];
//                         endcase
//            `MEMBYTE:     case (OffsetByte)
//                                3: RAM[AlignedAddr>>2][31:24] <= WriteData[7:0];
//                                2: RAM[AlignedAddr>>2][23:16] <= WriteData[7:0];
//                                1: RAM[AlignedAddr>>2][15:8]  <= WriteData[7:0];
//                                0: RAM[AlignedAddr>>2][7:0]   <= WriteData[7:0];
//                         endcase
//        endcase
            
    
//    always @(*)
//        case (MemRead)
//            `MEMWORD: begin      
//                             if(Addr=='h00002500) begin
//                                ReadData <= {24'b0,IO_IN};
//                             end
//                             else
//                                ReadData <= RAM[AlignedAddr>>2][31:0];
//                      end
//            `MEMWORDLEFT:  begin
//                            ReadData <= WriteData;
//                            case (OffsetByte)
//                                3: ReadData        <= RAM[AlignedAddr>>2][31:0]; 
//                                2: ReadData[31:8]  <= RAM[AlignedAddr>>2][23:0];
//                                1: ReadData[31:16] <= RAM[AlignedAddr>>2][15:0];
//                                0: ReadData[31:24] <= RAM[AlignedAddr>>2][7:0];
//                            endcase
//                          end
//            `MEMWORDRIGHT: begin
//                            ReadData <= WriteData;
//                            case (OffsetByte)
//                                3: ReadData[7:0]   <= RAM[AlignedAddr>>2][31:24];
//                                2: ReadData[15:0]  <= RAM[AlignedAddr>>2][31:16];
//                                1: ReadData[23:0]  <= RAM[AlignedAddr>>2][31:8];
//                                0: ReadData           <= RAM[AlignedAddr>>2][31:0];
//                            endcase
//                          end
//            `MEMHALFWORD:  case (OffsetHalfWord)
//                                2: ReadData <= {{16{RAM[AlignedAddr>>2][31]}}, 
//                                                RAM[AlignedAddr>>2][31:16]};
//                                0: ReadData <= {{16{RAM[AlignedAddr>>2][15]}}, 
//                                                RAM[AlignedAddr>>2][15:0]};
//                          endcase
//            `MEMHALFWORDU: case (OffsetHalfWord)
//                                2: ReadData <= {16'b0, 
//                                                RAM[AlignedAddr>>2][31:16]};
//                                0: ReadData <= {16'b0, 
//                                                RAM[AlignedAddr>>2][15:0]};
//                          endcase
//            `MEMBYTE:      case (OffsetByte)
//                                3: ReadData <= {{24{RAM[AlignedAddr>>2][31]}}, 
//                                                RAM[AlignedAddr>>2][31:24]};
//                                2: ReadData <= {{24{RAM[AlignedAddr>>2][23]}}, 
//                                                RAM[AlignedAddr>>2][23:16]};
//                                1: ReadData <= {{24{RAM[AlignedAddr>>2][15]}}, 
//                                                RAM[AlignedAddr>>2][15:8]};
//                                0: ReadData <= {{24{RAM[AlignedAddr>>2][7]}}, 
//                                                RAM[AlignedAddr>>2][7:0]};
//                          endcase
//            `MEMBYTEU:      case (OffsetByte)
//                                3: ReadData <= {24'b0, 
//                                                RAM[AlignedAddr>>2][31:24]};
//                                2: ReadData <= {24'b0, 
//                                                RAM[AlignedAddr>>2][23:16]};
//                                1: ReadData <= {24'b0, 
//                                                RAM[AlignedAddr>>2][15:8]};
//                                0: ReadData <= {24'b0, 
//                                                RAM[AlignedAddr>>2][7:0]};
//                          endcase
            
//        endcase
//endmodule
