`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2018 04:03:13 PM
// Design Name: 
// Module Name: 
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


// Period 1
`define FETCH        5'b00001
//`define FETCHDONE    5'b00001
// Period 2
`define DECODE       5'b00010
// Period 3
`define JUMPLINK     5'b00011
`define MEMADDR      5'b00100
`define JUMP         5'b00101
`define EXECUTE      5'b00110

// Period 4
`define MEMWRITE     5'b01000
`define MEMREAD      5'b01001
`define ALUTOREG     5'b01010
`define BRLINK       5'b01011
`define BRANCH       5'b01100
`define FLUTOREG     5'b01110
`define CONFLAGSET   5'b01111
// Period 5
`define MEMTOREG     5'b10000


// Memory Operations
`define MEMWORD         3'b001    // word
`define MEMWORDLEFT     3'b010    // word (left)
`define MEMWORDRIGHT    3'b011    // word (right)
`define MEMHALFWORD     3'b100    // half-word
`define MEMHALFWORDU    3'b101    // half-word (unsigned)
`define MEMBYTE         3'b110    // byte
`define MEMBYTEU        3'b111    // byte (unsigned)

// R-Type OpCodes
`define SPECIAL     6'b000000
`define SPECIAL2    6'b011100

// FR-Type OpCodes
`define FLOATOP    6'b010001
// FP-Type Fmt
`define FLOAT_FMT     5'b10000
`define FIXED_FMT     5'b10100
`define BRANCH_FMT    5'B01000
`define MTC1_FMT      5'b00100
`define MFC1_FMT      5'b00000
//---------- Funcs ----------
// SPECIAL Funcs
`define SLL             6'b000000
`define SRL             6'b000010
`define SRA             6'b000011
`define SLLV            6'b000100
`define SRLV            6'b000110
`define SRAV            6'b000111
`define JR              6'b001000
`define JALR            6'b001001
`define MOVZ            6'b001010
`define MOVN            6'b001011
`define MFHI            6'b010000
`define MFLO            6'b010010
`define MULT            6'b011000
`define MULTU           6'b011001
`define DIV             6'b011010
`define ADD             6'b100000
`define ADDU            6'b100001
`define SUB             6'b100010
`define SUBU            6'b100011
`define AND             6'b100100
`define OR              6'b100101
`define XOR             6'b100110
`define NOR             6'b100111
`define SLT             6'b101010
`define SLTU            6'b101011
// `SPECIAL2 Funcs
`define CLZ             6'b100000
`define CLO             6'b100001
// SPECIAL FLOAT Funcs
`define FLU_ADD_S_FUNC  6'b000000
`define FLU_SUB_S_FUNC  6'b000001
`define FLU_MUL_S_FUNC  6'b000010
`define FLU_DIV_S_FUNC  6'b000011
`define FLU_CMP_EQ_FUNC 6'b110010
`define FLU_CMP_LT_FUNC 6'b111100
`define FLU_CMP_LE_FUNC 6'b111110
`define FLU_CVT_SW_FUNC 6'b100000
`define FLU_CVT_WS_FUNC 6'b100100
`define FLU_DISABLE     6'b111111
//---------------------------

// J-Type Instructions
`define J               6'b000010
`define JAL             6'b000011

// I-Type Instructions
`define REGIMM          6'b000001
// REGIMM Types Start
`define BLTZ        5'b00000 
`define BGEZ        5'b00001
`define BLTZAL        5'b10000
`define BGEZAL        5'b10001
// REGIMM Types End
`define BEQ            6'b000100
`define BNE            6'b000101
`define BLEZ        6'b000110
`define BGTZ        6'b000111
`define ADDI        6'b001000
`define ADDIU        6'b001001
`define SLTI        6'b001010
`define SLTIU        6'b001011
`define ANDI        6'b001100
`define XORI        6'b001110
`define ORI            6'b001101
`define LUI            6'b001111
`define LB            6'b100000
`define LH            6'b100001
`define LBU            6'b100100
`define LHU            6'b100101
`define LWL            6'b100010
`define LW            6'b100011
`define LWR            6'b100110
`define SB            6'b101000
`define SH            6'b101001
`define SWL            6'b101010
`define SW            6'b101011
`define SWC1        6'b111001
`define SWR            6'b101110
`define LWC1       6'b110001
//----- Custom Defined Code -----
// ALU Control Code
`define ALUADD     5'b00000
`define ALUADDU    5'b00001
`define ALUSUB     5'b00010
`define ALUSUBU    5'b00011
`define ALUAND     5'b00100
`define ALUOR      5'b00101
`define ALUNOR     5'b00110
`define ALUXOR     5'b00111
`define ALULT      5'b01000
`define ALULTU     5'b01001
`define ALUSLL     5'b01010
`define ALUSRL     5'b01011
`define ALUSRA     5'b01100
`define ALULUI     5'b01101
`define ALUJ       5'b01110
`define ALUCLO     5'b01111
`define ALUCLZ     5'b10000
`define ALUNOP     5'b11111
//MLU Control Code
`define MLUMULT    5'b00
`define MLUMULTU   5'b01
`define MLUDIV     5'b10
`define MLUNOP     5'b11
//ALU Compare Code
`define ALU_TRUE_POSITIVE    3'b000
`define ALU_OVERFLOW         3'b001
`define ALU_ZERO             3'b010
`define ALU_X                3'b011
`define ALU_POSITIVE         3'b100
`define ALU_NO_OVERFLOW      3'b101
`define ALU_ZERO_OR_OVERFLOW 3'b110
