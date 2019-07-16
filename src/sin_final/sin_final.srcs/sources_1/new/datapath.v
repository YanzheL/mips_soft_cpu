`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2018 04:23:33 PM
// Design Name: 
// Module Name: datapath
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


module DataPath #(parameter WIDTH = 32, REGBITS = 4, MEMUNITS = 4096, CONBITS = 3) (
  input              CLK, Reset,InstrOrData, PCEn, IREn, PCSrc, RegWrite,FMODE, RegTransferEn, ConditionWrite,
  input  [WIDTH-1:0] ReadData,
//      input   [REGBITS-1:0]   RSAddr, RTAddr,
  input  [1:0]       RegDst, MLUControl,RSAddr_Pos,RTAddr_Pos,CC_POS,
  input  [2:0]       ALUSignCond,RegDTSource,ALUSrcA,
  input  [3:0]       ALUSrcB,
  input  [4:0]       ALUControl,
  input  [10:0]      FLUControl,
  output [WIDTH-1:0] Addr, WriteData,
  output [31:0]      Instr,
  output             ALU_IS_ZERO, ALUSign, ALUOverflow, ALUCompare, FLUPREPARED,
  output [3:0]       FLUCompare
);
  
  // Consts
  localparam CONST_0 = 32'b0;
  localparam CONST_1 = 32'b1;
  wire       IsConditionTrue;

  wire [WIDTH-1:0]   PC, NextPC;
  wire [WIDTH-1:0]   Data;
  wire [REGBITS-1:0] R5_OP_0, R5_OP_1, R5_OP_2,R5_OP_3, RegWriteAddr,RSAddr, RTAddr;

  wire [WIDTH-1:0]   RegWriteData, RS, RT, RS1,RS2,RT1,RT2, TransferData;
//  wire   [WIDTH-1:0]     RD1, RD2;
  wire [WIDTH-1:0]   ZeroExtSA, SignExtImm, ZeroExtIndex, ZeroExtImm;
  wire [WIDTH-1:0]   SrcA, SrcB, ALUResult, ALUOut;
  wire [WIDTH-1:0]   MLUHiOut, MLULoOut,FLUOut;
  wire [2:0]         CC_POSSIBLE_POS_0,CC_POSSIBLE_POS_1,CC_POSSIBLE_POS_2,CC;

  assign FLUCompare = FLUOut[3:0];
    // Register Address
  assign R5_OP_0    = Instr[25:21];
  assign R5_OP_1    = Instr[20:16];
  assign R5_OP_2    = Instr[15:11];
  assign R5_OP_3    = Instr[10:6];
  // Data
  assign WriteData  = RT;
  // CC Code Possible Position
  assign CC_POSSIBLE_POS_0 = Instr[20:18];
  assign CC_POSSIBLE_POS_1 = Instr[15:13];
  assign CC_POSSIBLE_POS_2 = Instr[10:8];
  // Imm Extend
  assign ZeroExtSA    = {27'b0, R5_OP_3};       // Zero Extend SA
  assign SignExtImm   = {{16{Instr[15]}}, Instr[15:0]}; // Sign Extend Imm
  assign ZeroExtIndex = {4'b0, Instr[25:0], 2'b0};   // InstrIndex << 2, then Zero Extend 
  assign ZeroExtImm   = {16'b0, Instr[15:0]};       // Zero Extend Imm


  Mux2 #(WIDTH)   addr_mux(PC, ALUOut, InstrOrData, Addr);
  Mux4 #(REGBITS) rs_addr_mux(R5_OP_0,R5_OP_1,R5_OP_2,R5_OP_3,RSAddr_Pos,RSAddr);
  Mux4 #(REGBITS) rt_addr_mux(R5_OP_0,R5_OP_1,R5_OP_2,R5_OP_3,RTAddr_Pos,RTAddr);
  Mux4 #(REGBITS) reg_write_addr_mux(R5_OP_1, R5_OP_2,R5_OP_3,5'b11111,RegDst, RegWriteAddr);
  Mux4 #(CONBITS) cc_pos_select(CC_POSSIBLE_POS_0,CC_POSSIBLE_POS_1,CC_POSSIBLE_POS_2, 3'b111, CC_POS, CC);
  Mux8 #(WIDTH)   reg_write_data_mux(ALUOut, Data, MLUHiOut, MLULoOut,FLUOut,TransferData,0,0, RegDTSource, RegWriteData);

  // Registers
  FlopEn             #(WIDTH)                    reg_transfer_data(CLK,RegTransferEn,RS,TransferData);
  FlopEn             #(WIDTH)                    ir_reg(CLK, IREn, ReadData, Instr);
  Flop               #(WIDTH)                    data_reg(CLK, ReadData, Data);
  FlopEnReset        #(WIDTH)                    pc_reg(CLK, PCEn, Reset, NextPC, PC);
  GeneralRegisters   #(WIDTH, REGBITS, MEMUNITS) general_registers(CLK, Reset,RegWrite & ~FMODE,1'b0, RSAddr, RTAddr, RegWriteAddr, RegWriteData,RS1, RT1);
  GeneralRegisters   #(WIDTH, REGBITS, MEMUNITS) float_registers(CLK, Reset,RegWrite & FMODE,1'b1, RSAddr, RTAddr, RegWriteAddr, RegWriteData,RS2, RT2);
  ConditionRegisters #(CONBITS)                  condition_registers(CLK,Reset,ConditionWrite, CC,1'b1,IsConditionTrue);
  
  assign  RS = FMODE ? RS2 : RS1;
  assign  RT = FMODE ? RT2 : RT1;
  // LU
  ALU            #(WIDTH) ALUnit(SrcA, SrcB, ALUControl, ALUResult);
  MLU            #(WIDTH) MLUnit(CLK,Reset,RS, RT, MLUControl, MLUHiOut, MLULoOut);
  FLU            #(WIDTH) FLUnit(CLK,Reset,RS,RT,FLUControl,FLUOut,FLUPREPARED);
  ZeroDetect     #(WIDTH) ZeroFlag(ALUResult, ALU_IS_ZERO);
  SignDetect     #(WIDTH) SignFlag(ALUResult, ALUSign);
  OverflowDetect #(WIDTH) OverflowFlag(ALUResult, SrcA, SrcB, ALUControl, ALUOverflow);
  SignedCompare           CompareDecode(ALU_IS_ZERO, ALUSign, ALUOverflow, ALUSignCond, ALUCompare);
  Flop           #(WIDTH) ALUResultReg(CLK, ALUResult, ALUOut);
  Mux8           #(WIDTH) ALUSrcA_Select(PC, RS, RT, CONST_0, {31'b0,IsConditionTrue},CONST_0,CONST_0,CONST_0,ALUSrcA, SrcA);
  Mux16          #(WIDTH) ALUSrcB_Select(
                            .D0(RT),
                            .D1(32'b100),
                            .D2(SignExtImm),
                            .D3(SignExtImm << 2),
                            .D4(ZeroExtIndex),
                            .D5(ZeroExtImm),
                            .D6(ZeroExtSA),
                            .D7(CONST_0),
                            .D8(RS),
                            .D9(0),
                            .D10(0),
                            .D11(0),
                            .D12(0),
                            .D13(0),
                            .D14(0),
                            .D15(0),
                            .Cond(ALUSrcB),
                            .Result(SrcB)
                          );
  // Next PC
  Mux2           #(WIDTH) NextPC_Select(ALUResult, ALUOut, PCSrc, NextPC);
endmodule
