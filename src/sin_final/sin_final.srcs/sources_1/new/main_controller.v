`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2018 04:13:45 PM
// Design Name: 
// Module Name: MainController
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

module MainController (
    input             CLK, Reset,FLUPrepared,
    input      [31:0] Instr,
    input             ALU_IS_ZERO, ALUSign, ALUOverflow, ALUCompare,
    input      [3:0]  FLUCompare,
    output reg        InstrOrData, IREn, PCSrc,FMODE,RegTransferEn,ConditionWrite,
    output            PCEn,RegWrite,
    output reg [2:0]  MemWrite, MemRead,ALUSignCond,RegDTSource,ALUSrcA,
    output reg [3:0]  ALUSrcB,
    output reg [1:0]  RegDst, RSAddr_Pos, RTAddr_Pos,CC_POS,
    output     [4:0]  CurrentState
  );
  
  wire [5:0] OpCode, Func;
  wire [4:0] Fmt, RegImmType;

  reg  [4:0] State, NextState;
  reg        PCWrite, Branch;
  reg        RegSet, RegCondSet;
  
  assign OpCode     = Instr[31:26];
  assign Fmt        = Instr[25:21];
  assign RegImmType = Instr[20:16];
  assign Func       = Instr[5:0];
  
  // state register
  assign CurrentState = State;
  always @(posedge CLK)
    if (Reset) begin
      State <= `FETCH;
//      FMODE <= 0;
    end
    else State <= NextState;
    
  // next state logic
  always @(*)
    case (State)
      // Period 1
      `FETCH: NextState <= `DECODE;
      // Period 2
      `DECODE:
        case (OpCode)
          // R-Type
          `SPECIAL:  NextState <= `EXECUTE;
          `SPECIAL2: NextState <= `EXECUTE;
          `FLOATOP:  NextState <= `EXECUTE;
          // J-Type
          `J:        NextState <= `JUMP;  // `J
          `JAL:      NextState <= `JUMPLINK;// `JAL
          // I-Type
          `REGIMM:   NextState <= `EXECUTE; // `BGEZ, `BGEZAL, BLTZ, `BLTZAL
          `BEQ:      NextState <= `EXECUTE; // `BEQ
          `BNE:      NextState <= `EXECUTE; // `BNE
          `BLEZ:     NextState <= `EXECUTE; // `BLEZ
          `BGTZ:     NextState <= `EXECUTE; // `BGTZ
          `ADDI:     NextState <= `EXECUTE; // `ADDI
          `ADDIU:    NextState <= `EXECUTE; // `ADDIU
          `SLTI:     NextState <= `EXECUTE; // `SLTI
          `SLTIU:    NextState <= `EXECUTE; // `SLTIU
          `ANDI:     NextState <= `EXECUTE; // `ANDI
          `XORI:     NextState <= `EXECUTE; // `XORI
          `ORI:      NextState <= `EXECUTE; // `ORI
          `LUI:      NextState <= `EXECUTE; // `LUI
          `LB:       NextState <= `MEMADDR; // `LB
          `LH:       NextState <= `MEMADDR; // `LH
          `LBU:      NextState <= `MEMADDR; // `LBU
          `LHU:      NextState <= `MEMADDR; // `LHU
          `LWL:      NextState <= `MEMADDR; // `LWL
          `LW:       NextState <= `MEMADDR; // `LW
          `LWC1:     NextState <= `MEMADDR;
          `LWR:      NextState <= `MEMADDR; // `LWR
          `SB:       NextState <= `MEMADDR; // `SB
          `SH:       NextState <= `MEMADDR; // `SH
          `SWL:      NextState <= `MEMADDR; // `SWL
          `SW:       NextState <= `MEMADDR; // `SW
          `SWC1:     NextState <= `MEMADDR; // `SWC1
          `SWR:      NextState <= `MEMADDR; // `SWR
          default:   NextState <= `FETCH;   // should never happen
        endcase
      // Period 3
      `JUMPLINK: NextState <= `JUMP;
      `MEMADDR:
        case (OpCode)
          `LB:       NextState <= `MEMREAD;  // `LB
          `LH:       NextState <= `MEMREAD;  // `LH
          `LBU:      NextState <= `MEMREAD;  // `LBU
          `LHU:      NextState <= `MEMREAD;  // `LHU
          `LWL:      NextState <= `MEMREAD;  // `LWL
          `LW:       NextState <= `MEMREAD;  // `LW
          `LWC1:     NextState <= `MEMREAD;  // `LWC1
          `LWR:      NextState <= `MEMREAD;  // `LWR
          `SB:       NextState <= `MEMWRITE; // `SB
          `SH:       NextState <= `MEMWRITE; // `SH
          `SWL:      NextState <= `MEMWRITE; // `SWL
          `SW:       NextState <= `MEMWRITE; // `SW
          `SWC1:     NextState <= `MEMWRITE; // `SWC1
          `SWR:      NextState <= `MEMWRITE; // `SWR
          default:   NextState <= `FETCH;  // should never happen
        endcase
      `JUMP: NextState <= `FETCH;
      `EXECUTE:
        case (OpCode)
          // R-Type
          `SPECIAL:
            case (Func)
              `JR:      NextState <= `JUMP;      // `JR
              `JALR:    NextState <= `JUMPLINK;   // `JALR
              `MULT:    NextState <= `FETCH;
              `DIV:     NextState <= `FETCH;
              default:  NextState <= `ALUTOREG;    // other R-Type instr
            endcase
          `SPECIAL2:NextState <= `ALUTOREG;
          `FLOATOP:
            case (Fmt)
              `MTC1_FMT:   NextState <= `FETCH;
              `MFC1_FMT:   NextState <= `FETCH;
              `BRANCH_FMT: NextState <= `BRANCH;
              `FLOAT_FMT: 
                case (Func)
                  `FLU_CMP_EQ_FUNC: NextState <= FLUPrepared ? `CONFLAGSET : `EXECUTE;
                  `FLU_CMP_LE_FUNC: NextState <= FLUPrepared ? `CONFLAGSET : `EXECUTE;
                  `FLU_CMP_LT_FUNC: NextState <= FLUPrepared ? `CONFLAGSET : `EXECUTE;
                  default: NextState <= FLUPrepared ? `FLUTOREG : `EXECUTE;
                endcase
              default:     NextState <= FLUPrepared? `FLUTOREG : `EXECUTE;
            endcase
          // I-Type
          `REGIMM:
            case (RegImmType)
              `BLTZ:       NextState <= `BRANCH; // `BLTZ
              `BGEZ:       NextState <= `BRANCH; // `BGEZ
              `BLTZAL:     NextState <= `BRLINK; // `BLTZAL
              `BGEZAL:     NextState <= `BRLINK; // `BGEZAL
              default:     NextState <= `FETCH;  // should never happen
            endcase
          `BEQ:      NextState <= `BRANCH;   // `BEQ
          `BNE:      NextState <= `BRANCH;  // `BNE
          `BLEZ:     NextState <= `BRANCH;  // `BLEZ
          `BGTZ:     NextState <= `BRANCH;   // `BGTZ
          `ADDI:     NextState <= `ALUTOREG; // `ADDI
          `ADDIU:    NextState <= `ALUTOREG; // `ADDIU
          `SLTI:     NextState <= `ALUTOREG; // `SLTI
          `SLTIU:    NextState <= `ALUTOREG; // `SLTIU
          `ANDI:     NextState <= `ALUTOREG; // `ANDI
          `XORI:     NextState <= `ALUTOREG; // `XORI
          `ORI:      NextState <= `ALUTOREG; // `ORI
          `LUI:      NextState <= `ALUTOREG; // `LUI
//              default: NextState <= `FETCH;  // should never happen
        endcase
      // Period 4
      `MEMWRITE:   NextState <= `FETCH;
      `MEMREAD:    NextState <= `MEMTOREG;
      `ALUTOREG:   NextState <= `FETCH;
      `FLUTOREG:   NextState <= `FETCH;
      `CONFLAGSET: NextState <= `FETCH;
      `BRLINK:     NextState <= `BRANCH;
      `BRANCH:     NextState <= `FETCH;
      // Period 5
      `MEMTOREG:   NextState <= `FETCH;
      // Should never happen
      default:     NextState <= `FETCH;
    endcase
    
  // current state execution
  always @(*)
    begin
      PCWrite <= 0; Branch <= 0;
      InstrOrData <= 0; IREn <= 0; PCSrc <= 0;
      MemWrite <= 3'b0; MemRead <= 3'b0;
      RegSet <= 0; RegCondSet <= 0; RegDst <= 2'b00; 
      RegDTSource <= 3'b00;
      ALUSrcA <= 3'b0; ALUSrcB <= 4'b0; ALUSignCond <= 3'b111;
      RegTransferEn <= 0;
      CC_POS<=2'b10;
      if (Reset)
        FMODE <= 0;
//      else FMODE<=FMODE;
//      RSAddr_Pos<=2'b00;
//      RTAddr_Pos<=2'b01;
      
      case (State)
        // Period 1
        `FETCH:
          begin
            MemRead <= `MEMWORD; // an instruction is 4-byte (a word)
            IREn    <= 1;
            PCWrite <= 1;
            ALUSrcB <= 4'b0001;
          end
        // Period 2
        `DECODE: begin
          case (OpCode)
            `J:      ALUSrcB <= 4'b0100; // calc jump address, when `J, we can directly `JUMP when Period 3.
            `JAL:    ALUSrcB <= 4'b0111; // return address should have be PC+4, but we've done it at `FETCH,
                        // so just add 0 to current PC, and when `JAL, 
                        // we can directly `JUMPLINK when Period 3
            `FLOATOP:
              case (Fmt)
                `MTC1_FMT: begin
                  FMODE         <= 0;
                  RegTransferEn <= 1;
                  RSAddr_Pos    <= 2'b01;
                  RTAddr_Pos    <= 2'b01;
                end
                `MFC1_FMT: begin
                  FMODE         <= 1;
                  RegTransferEn <= 1;
                  RSAddr_Pos    <= 2'b10;
                  RTAddr_Pos    <= 2'b01;
                end
                `FLOAT_FMT: begin
                  FMODE         <= 1;
                  RSAddr_Pos    <= 2'b10;
                  RTAddr_Pos    <= 2'b01;
                  case (Func)
                    `FLU_CMP_EQ_FUNC: CC_POS <= 2'b10;
                    `FLU_CMP_LE_FUNC: CC_POS <= 2'b10;
                    `FLU_CMP_LT_FUNC: CC_POS <= 2'b10;
                  endcase
                end
                `BRANCH_FMT: begin
                  CC_POS        <= 2'b00;
                end
                default: begin 
                    FMODE       <= 1;
                    RSAddr_Pos  <= 2'b10;
                    RTAddr_Pos  <= 2'b01;
                end
              endcase
            default:  begin
              FMODE         <= 0;
              RSAddr_Pos    <=2'b00;
              RTAddr_Pos    <=2'b01;
            end
          endcase 
        end
        // Period 3
        `JUMPLINK:
          begin
            RegSet <= 1;
            case (OpCode)
              // Func should be `JALR
              `SPECIAL:begin
                    RegDst <= 2'b01;   // RD
                    ALUSrcA <= 3'b001;  // jump address at RS, no need to set ALUSrcB,
                               // since RT = 0 in `JALR
                  end
              `JAL:  begin
                    RegDst <= 2'b11;   // $31($ra)
                    ALUSrcB <= 4'b0100; // calc jump address
                  end
            endcase
          end
        `MEMADDR:
          begin
            ALUSrcA <= 3'b001;
            ALUSrcB <= 4'b0010; // calc memory address
          end
        `JUMP:
          begin
            PCWrite <= 1;
            PCSrc <= 1;
          end
        `EXECUTE:
          begin
            case (OpCode)
              // R-Type
              `SPECIAL:
                case (Func)
                  `SLL:   begin ALUSrcA <= 3'b010; ALUSrcB <= 4'b0110; end  // instr[10:6] - SA
                  `SLLV:  begin ALUSrcA <= 3'b010; ALUSrcB <= 4'b1000; end  // instr[10:6] - SA
                  `SRA:   begin ALUSrcA <= 3'b010; ALUSrcB <= 4'b0110; end  // instr[10:6] - SA
                  `SRAV:  begin ALUSrcA <= 3'b010; ALUSrcB <= 4'b1000; end  // instr[10:6] - SA
                  `SRL:   begin ALUSrcA <= 3'b010; ALUSrcB <= 4'b0110; end  // instr[10:6] - SA
                  `SRLV:  begin ALUSrcA <= 3'b010; ALUSrcB <= 4'b1000; end  // instr[10:6] - SA
                  `JALR:  ALUSrcB <= 4'b0111; // return address should have be PC+4, but we've done it at `FETCH,
                                // so just add 0 to current PC
                  `MOVZ:  begin        // RS+0
                      ALUSrcA <= 3'b001; 
                      ALUSrcB <= 4'b0111; 
                    end
                  `MOVN:  begin        // RS+0
                      ALUSrcA <= 3'b001; 
                      ALUSrcB <= 4'b0111; 
                    end
                  default: ALUSrcA <= 3'b001;  // instr[25:21] - RS
                endcase
              `SPECIAL2:ALUSrcA <= 3'b001;         // insrt[25:21] - RS
              `FLOATOP:
                case (Fmt)
                  `MTC1_FMT: begin
                      FMODE <= 1;
                      RegTransferEn <= 0;
                      RegSet <= 1;
                      RegDst <= 2'b01;
                      RegDTSource <= 3'b101;
                    end
                  `MFC1_FMT: begin
                      FMODE <= 0;
                      RegTransferEn <= 0;
                      RegSet <= 1;
                      RegDst <= 2'b00;
                      RegDTSource <= 3'b101;
                    end
                  `BRANCH_FMT: begin
                      ALUSrcB <= 4'b0011;
                    end
                endcase
              // I-Type
              `REGIMM:
                case (RegImmType)
                  `BLTZ:    ALUSrcB <= 4'b0011; // `BLTZ, calc jump address
                  `BGEZ:   ALUSrcB <= 4'b0011; // `BGEZ, calc jump address
                  `BLTZAL: ALUSrcB <= 4'b0111; // return address should have be PC+4, but we've done it at `FETCH,
                                  // so just add 0 to current PC
                  `BGEZAL: ALUSrcB <= 4'b0111; // return address should have be PC+4, but we've done it at `FETCH,
                                  // so just add 0 to current PC
                endcase
              `BEQ:    ALUSrcB <= 4'b0011; // `BEQ, calc jump address
              `BNE:    ALUSrcB <= 4'b0011; // `BNE, calc jump address
              `BLEZ:   ALUSrcB <= 4'b0011; // `BLEZ, calc jump address
              `BGTZ:   ALUSrcB <= 4'b0011; // `BGTZ, calc jump address
              `ADDI:   begin ALUSrcA <= 3'b001; ALUSrcB <= 4'b0010; end // `ADDI
              `ADDIU:  begin ALUSrcA <= 3'b001; ALUSrcB <= 4'b0010; end // `ADDIU
              `SLTI:   begin ALUSrcA <= 3'b001; ALUSrcB <= 4'b0010; end // `SLTI
              `SLTIU:  begin ALUSrcA <= 3'b001; ALUSrcB <= 4'b0010; end // `SLTIU
              `ANDI:   begin ALUSrcA <= 3'b001; ALUSrcB <= 4'b0101; end // `ANDI
              `XORI:   begin ALUSrcA <= 3'b001; ALUSrcB <= 4'b0101; end // `XORI
              `ORI:    begin ALUSrcA <= 3'b001; ALUSrcB <= 4'b0101; end // `ORI
              `LUI:    begin ALUSrcA <= 3'b001; ALUSrcB <= 4'b0010; end // `LUI
            endcase
          end
        // Period 4
        `MEMWRITE:
          begin
            InstrOrData <= 1;
            case (OpCode)
              `SB:  MemWrite <= `MEMBYTE;    // SB
              `SH:  MemWrite <= `MEMHALFWORD; // SH
              `SWL:   MemWrite <= `MEMWORDLEFT; // SWL
              `SW:  MemWrite <= `MEMWORD;     // SW
              `SWC1:  begin FMODE <= 1;MemWrite <= `MEMWORD; end     // SWC1
              `SWR:   MemWrite <= `MEMWORDRIGHT;// SWR
            endcase
          end
        `MEMREAD:
          begin
            InstrOrData <= 1;
            case (OpCode)
              `LB:  MemRead <= `MEMBYTE;      // `LB
              `LH:  MemRead <= `MEMHALFWORD;  // `LH
              `LBU:   MemRead <= `MEMBYTEU;      // `LBU
              `LHU:   MemRead <= `MEMHALFWORDU; // `LHU
              `LWL:   MemRead <= `MEMWORDLEFT;  // `LWL
              `LW:  MemRead <= `MEMWORD;       // `LW
              `LWC1:  begin FMODE <= 1; MemRead <= `MEMWORD; end       // `LWC1
              `LWR:   MemRead <= `MEMWORDRIGHT; // `LWR
            endcase
          end
        `CONFLAGSET:
           begin
           case (Func)
             `FLU_CMP_LE_FUNC: ConditionWrite <= FLUCompare == 4'b0001 |FLUCompare == 4'b0010;
             `FLU_CMP_LT_FUNC: ConditionWrite <= FLUCompare == 4'b0010;
             `FLU_CMP_EQ_FUNC: ConditionWrite <= FLUCompare == 4'b0001;
           endcase
           end
        `FLUTOREG:
            begin
              case (Fmt)
                `FLOAT_FMT: begin
                    RegSet <= 1;
                    RegDst <= 2'b10;
                    RegDTSource <= 3'b100;
                  end
                `FIXED_FMT: begin
                    RegSet <= 1;
                    RegDst <= 2'b10;
                    RegDTSource <= 3'b100;
                  end
              endcase
            end
        `ALUTOREG:
          begin
            case (OpCode)
              // R-Type Instructions
              `SPECIAL:
                case (Func)  
                  `MOVZ: begin
                      ALUSrcA <= 3'b011; // 0+RT
                      RegCondSet <= 1; ALUSignCond <= 3'b010; 
                      RegDst <= 2'b01; 
                    end
                  `MOVN: begin 
                      ALUSrcA <= 3'b011; // 0+RT
                      RegCondSet <= 1; ALUSignCond <= 3'b100; 
                      RegDst <= 2'b01; 
                    end
                  `MFHI:  begin
                      RegSet <= 1;
                      RegDst <= 2'b01;
                      RegDTSource <= 3'b10;
                    end
                  `MFLO:  begin
                      RegSet <= 1;
                      RegDst <= 2'b01;
                      RegDTSource <= 3'b11;
                    end
                  default: begin RegSet <= 1; RegDst <= 2'b01; end
                endcase
              `SPECIAL2: begin RegSet <= 1; RegDst <= 2'b01; end
              // I-Type Instructions
              default:  RegSet <= 1;
            endcase
          end
        `BRLINK:
          begin
            RegSet <= 1;
            RegDst <= 2'b11;   // $31($ra)
            ALUSrcB <= 4'b0011;  // calc jump address
          end
        `BRANCH:
          begin
            Branch <= 1; 
            PCSrc <= 1;
            case (OpCode)
              `FLOATOP:
                case (Fmt)
                  `BRANCH_FMT: begin
                      ALUSrcA <= 3'b100;           // CC
                      ALUSrcB <= 4'b0111;          // 0
                      ALUSignCond <= RegImmType[0] ? `ALU_POSITIVE : `ALU_ZERO;
                    end
                endcase
              `REGIMM: begin
                  ALUSrcA <= 3'b001;
                  ALUSrcB <= 4'b0111;           // `REGIMM's instr[20:16] is type
                  case (RegImmType)
                    `BLTZ:   ALUSignCond <= `ALU_OVERFLOW;    // `BLTZ
                    `BGEZ:   ALUSignCond <= `ALU_NO_OVERFLOW; // `BGEZ
                    `BLTZAL: ALUSignCond <= `ALU_OVERFLOW;    // `BLTZAL
                    `BGEZAL: ALUSignCond <= `ALU_NO_OVERFLOW; // `BGEZAL
                  endcase
                end
              `BEQ:  begin ALUSrcA <= 3'b001;ALUSignCond <= `ALU_ZERO;end             // `BEQ
              `BNE:  begin ALUSrcA <= 3'b001;ALUSignCond <= `ALU_POSITIVE;end         // `BNE
              `BLEZ: begin ALUSrcA <= 3'b001;ALUSignCond <= `ALU_ZERO_OR_OVERFLOW;end // `BLEZ
              `BGTZ: begin ALUSrcA <= 3'b001;ALUSignCond <= `ALU_TRUE_POSITIVE;end    // `BGTZ
            endcase
          end
        // Period 5
        `MEMTOREG:
          begin
            RegSet <= 1;
            RegDTSource <= 3'b01;
          end
      endcase
    end
  
  assign PCEn   = PCWrite | (Branch & ALUCompare);
  assign RegWrite = RegSet  | (RegCondSet & ALUCompare);
endmodule
