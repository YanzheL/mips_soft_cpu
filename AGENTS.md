# MIPS-32 SOFT-CORE CPU — PROJECT KNOWLEDGE BASE

**Generated:** 2026-02-02  
**Commit:** a30ecf4  
**Branch:** master

## OVERVIEW

Multi-cycle MIPS-32 soft-core CPU in Verilog for Xilinx Artix-7 FPGA (XC7A35T-1). HIT Machine Organization course project. Supports 36 instructions (integer + IEEE 754 floating-point via Xilinx IPs).

## STRUCTURE

```
mips_soft_cpu/
├── src/sin_final/                    # Vivado project root
│   ├── sin_final.xpr                 # Open this in Vivado
│   └── sin_final.srcs/sources_1/new/ # ALL RTL here (15 files)
│       ├── mips.v                    # Top + MIPS modules (ENTRY POINT)
│       ├── main_controller.v         # FSM control (485 lines, largest)
│       ├── datapath.v                # Registers + ALU + MUXes
│       ├── alu.v, mlu.v, flu.v       # Execution units
│       ├── memory_controller.v       # Unified instruction/data memory
│       ├── global_define.v           # ALL opcodes/constants here
│       └── etc.v                     # Utility: Flop, Mux2/4/8/16
├── test/sin_mips.s                   # Test program (sin calculation)
└── docs/project_report_cn.pdf        # Documentation (Chinese)
```

## WHERE TO LOOK

| Task | Location | Notes |
|------|----------|-------|
| Add new instruction | `global_define.v` → `main_controller.v` → decoder in `decoders.v` | Define opcode, add FSM state, add ALU/FLU op |
| Modify ALU ops | `alu.v` | Pure combinational, 17 operations |
| Add FP instruction | `flu.v` | Uses Xilinx IPs (falu/fmult/fdiv/fcompare) |
| Change register count | `registers.v` | Parameterized: REGBITS, WIDTH |
| FPGA pin mapping | `sin_final.srcs/constrs_1/imports/new/Top.xdc` | LVCMOS18, buttons/LEDs/clock |
| Run simulation | `sin_final.sim/sim_1/behav/xsim/top_sim.tcl` | XSim: 1000ns behavioral |
| Memory init data | `memory.dat` (in synth_1/) | `$readmemh()` format |

## MODULE HIERARCHY

```
Top (mips.v:3)                    # FPGA top-level
├── MIPS (mips.v:78)              # Processor core
│   ├── DataPath (datapath.v)     # Execution path
│   │   ├── GeneralRegisters ×2   # GPRs + FPRs (32 each)
│   │   ├── ALU                   # Integer ops
│   │   ├── MLU                   # Multiply/divide (HI/LO)
│   │   ├── FLU                   # Floating-point (Xilinx IPs)
│   │   └── Mux2/4/8/16, Flop*    # Utility
│   ├── MainController            # FSM: FETCH→DECODE→EXECUTE→MEM→WB
│   └── ALUDecoder, FLUDecoder, MLUDecoder
├── MemoryController              # 4KB unified memory + I/O
├── DataInput/DataOutput          # Button input, 7-seg LED output
└── ClockTransformer              # Clock divider for display
```

## PIPELINE STATES (global_define.v)

| State | Code | Description |
|-------|------|-------------|
| FETCH | 5'b00001 | Read instruction from memory |
| DECODE | 5'b00010 | Decode opcode, read registers |
| EXECUTE | 5'b00110 | ALU/FLU computation |
| MEMREAD | 5'b01001 | Load from memory |
| MEMWRITE | 5'b01000 | Store to memory |
| ALUTOREG | 5'b01010 | Write ALU result to register |
| FLUTOREG | 5'b01110 | Write FLU result to register |

## CONVENTIONS

- **Timescale**: `1ns / 1ps` everywhere
- **Parameters**: WIDTH=32, REGBITS=5, MEMUNITS=4096
- **Reset**: Positive-active (`if (Reset)`)
- **Naming**: CamelCase modules (`MainController`), lowercase files
- **Defines**: `include "global_define.v"` in modules that decode instructions

## ANTI-PATTERNS (DO NOT)

- **DO NOT** add instructions without updating ALL THREE: `global_define.v`, `main_controller.v`, appropriate decoder
- **DO NOT** modify Xilinx IP cores directly (flu.v instantiates: falu, fmult, fdiv, fcompare, float_to_fixed, fixed_to_float)
- **DO NOT** trust clock_transformer.v line 68-73 — has latch bug (`CLK_OUT=CLK_OUT`)
- **DO NOT** rely on "should never happen" default cases in main_controller.v — they mask bugs

## KNOWN ISSUES

1. **Clock Divider Bug**: `clock_transformer.v:68-73` — `CLK_OUT` assigned to itself, never toggles
2. **Incomplete Decoding**: `main_controller.v` has 5 "should never happen" defaults — unhandled opcodes silently reset to FETCH
3. **Dead Code**: `memory_controller.v:23-75` — commented-out ExternalMemory IP version
4. **Hardcoded Paths**: Vivado TCL scripts contain Windows paths (C:/Users/Trinity/...)

## COMMANDS

```bash
# Open in Vivado
vivado src/sin_final/sin_final.xpr

# Synthesis (batch mode)
cd src/sin_final/sin_final.runs/synth_1
vivado -mode batch -source Top.tcl

# Behavioral simulation
cd src/sin_final/sin_final.sim/sim_1/behav/xsim
xsim top_sim -tclbatch top_sim.tcl

# Bitstream location (after impl)
src/sin_final/sin_final.runs/impl_1/Top.bit
```

## INSTRUCTION SET

**Integer**: addiu, addu, andi, beq, bgez, blez, bne, j, jal, jr, lui, lw, mfhi, mflo, multu, sll, sllv, slt, slti, srl, srlv, subu, sw

**Floating-Point**: add.s, bc1t, c.le.s, c.lt.s, cvt.s.w, cvt.w.s, div.s, lwc1, mfc1, mtc1, mul.s, sub.s, swc1

## FPGA TARGET

- **Device**: Xilinx XC7A35T-1CSG324 (Artix-7)
- **Clock**: 100MHz (P17), 10ns period constraint
- **I/O**: 8 buttons (P5-R1), 16 LEDs (B4-G6), Reset (R15)
- **Standard**: LVCMOS18 for all I/O

## NOTES

- Memory-mapped I/O: `0x2500` = button input, `0x2504` = LED output
- Stack pointer initialized to `0x3ffc` on reset
- Little-endian memory organization
- FLU operations are pipelined (multi-cycle) — check `FLUPREPARED` signal before reading result
