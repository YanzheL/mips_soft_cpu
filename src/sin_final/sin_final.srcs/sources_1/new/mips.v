`timescale 1ns / 1ps

module Top #(parameter WIDTH = 32, REGBITS = 5, MEMUNITS = 4096)(
        input [7:0] buttons,
        input CLK,
        (* clock_buffer_type="none" *) input Reset, //positive active
        output [7:0] LED_ENCODE1,
        output [7:0] LED_ENCODE2,
        output [7:0] LED_SELECT
    );
//    reg    [7:0]       buttons;
//    reg                CLK, Reset;
    wire    [2:0]       MemWrite, MemRead;
    wire    [WIDTH-1:0] Addr, ReadData;
    wire    [WIDTH-1:0] WriteData;
    wire    [7:0]       LED_ENCODE;
//    assign LED_ENCODE1 = 8'b11111111;
//    assign LED_ENCODE2 = 8'b11111111;
//    assign LED_SELECT = 8'b00000010;
    
    assign LED_ENCODE1 = LED_ENCODE;
    assign LED_ENCODE2 = LED_ENCODE;
    MIPS #(WIDTH, REGBITS, MEMUNITS) Processor(CLK, Reset, Addr, MemWrite, MemRead, WriteData, ReadData);
    wire [7:0] deg_value;
    wire [31:0] result_data;
//    assign result_data = 32'h12345678;
    wire deg_sign;
    DataInput data_input (
        .m(buttons),
        .mid_button_signal(~Reset),
        .current_value(deg_value),
        .SIGN(deg_sign)
    );
    
    wire display_clock;
    
    ClockTransformer clk_transformer(
       .CLK_IN(CLK),
       .CLK_OUT(display_clock),
       .RST(~Reset),
       .FACTOR(3'b101)
    );
    
    DataOutput data_output (
        .CLK(display_clock),
        .RST(~Reset),
        .DATA(result_data),
//        .DATA(32'h12345678),
        .SIGN(deg_sign),
        .LED_SELECT(LED_SELECT),
        .LED_ENCODE(LED_ENCODE)
    );
    // external memory for instruction and data
    MemoryController #(WIDTH, MEMUNITS) Memory(
        .CLK(CLK),
        .Reset(Reset),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .Addr(Addr),
        .WriteData(WriteData),
        .ReadData(ReadData),
        .IO_IN(deg_value),
        .IO_OUT(result_data)
    );
//    initial
//        begin
//            buttons <=8'h3c;
//            #10 Reset <= 0; # 22; Reset <= 1;
//            #7000 Reset <= 0; # 10; Reset <= 1;
//        end
//    always
//        begin
//            CLK <= 1; #0.5; CLK <= 0; #0.5;
//        end 
endmodule

// our lovely MIPS processor
module MIPS #(parameter WIDTH = 32, REGBITS = 5, MEMUNITS = 4096)(
        CLK, Reset, Addr, MemWrite, MemRead, WriteData, ReadData
    );
    input                CLK, Reset;
    input    [WIDTH-1:0] ReadData;
    output         [2:0] MemWrite, MemRead;
    output   [WIDTH-1:0] Addr, WriteData;

    // PC/IR
    wire [31:0] Instr;
    wire        InstrOrData, PCEn, IREn, PCSrc,RegTransferEn,ConditionWrite;

    // Register
    wire        RegWrite,FMODE;
    wire [1:0]  RegDst,RSAddr_Pos,RTAddr_Pos,cc_pos;
    
    // MainController
    wire [4:0]  CurrentState;
    wire [2:0]  ALUSignCond,RegDTSource; // Condition for EQ/LT/GT/NE/GE/LE
    wire [3:0]  FLUCompare;

    // ALU
    wire        ALU_IS_ZERO, ALUSign, ALUOverflow; // ALU Flag
    wire        ALUCompare; // Compare result for specific condition
    wire        FLUPrepared;
    wire [2:0]  ALUSrcA;
    wire [3:0]  ALUSrcB;
    wire [10:0] FLUControl;
    wire [4:0]  ALUControl;
    wire [1:0]  MLUControl;

    DataPath  #(WIDTH, REGBITS, MEMUNITS) Path(
        .CLK(CLK),
        .Reset(Reset), 
        .Addr(Addr),
        .WriteData(WriteData),
        .ReadData(ReadData),
        .Instr(Instr),
        .InstrOrData(InstrOrData),
        .PCEn(PCEn),
        .IREn(IREn),
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .RegDst(RegDst),
        .RegDTSource(RegDTSource),
        .ALU_IS_ZERO(ALU_IS_ZERO),
        .ALUSign(ALUSign),
        .ALUOverflow(ALUOverflow),
        .ALUCompare(ALUCompare),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .ALUControl(ALUControl),
        .MLUControl(MLUControl),
        .FLUControl(FLUControl),
        .RSAddr_Pos(RSAddr_Pos),
        .RTAddr_Pos(RTAddr_Pos),
        .ALUSignCond(ALUSignCond),
        .FMODE(FMODE),
        .FLUPREPARED(FLUPrepared),
        .RegTransferEn(RegTransferEn),
        .ConditionWrite(ConditionWrite),
        .CC_POS(cc_pos),
        .FLUCompare(FLUCompare)
    );

    MainController  Control(
        .CLK(CLK),
        .Reset(Reset),
        .Instr(Instr),
        .ALU_IS_ZERO(ALU_IS_ZERO),
        .ALUSign(ALUSign),
        .ALUOverflow(ALUOverflow),
        .ALUCompare(ALUCompare),
        .InstrOrData(InstrOrData),
        .IREn(IREn),
        .PCSrc(PCSrc),
        .PCEn(PCEn),
        .MemWrite(MemWrite),
        .MemRead(MemRead),
        .RegWrite(RegWrite),
        .RegDst(RegDst),
        .RegDTSource(RegDTSource),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .ALUSignCond(ALUSignCond),
        .CurrentState(CurrentState),
        .RSAddr_Pos(RSAddr_Pos),
        .RTAddr_Pos(RTAddr_Pos),
        .FMODE(FMODE),
        .FLUPrepared(FLUPrepared),
        .RegTransferEn(RegTransferEn),
        .ConditionWrite(ConditionWrite),
        .CC_POS(cc_pos),
        .FLUCompare(FLUCompare)
    );
    ALUDecoder      alu_decoder(CurrentState, Instr, ALUControl);
    MLUDecoder      mlu_decoder(Instr, MLUControl);
    FLUDecoder      flu_decoder(Instr, FLUControl);
endmodule
