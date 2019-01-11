# MIPS-32 Soft-Core CPU

A multi-cycle MIPS-32 soft-core CPU written in Verilog, targeting Xilinx Artix-7 FPGA. Course project for **Machine Organization** at Harbin Institute of Technology (HIT).

## Features

- **36 MIPS instructions** (integer + IEEE 754 single-precision floating-point)
- **Multi-cycle architecture** with FSM-based control
- **Hardware floating-point** via Xilinx IP cores
- **Memory-mapped I/O** for buttons and 7-segment LED display
- **4KB unified memory** for instructions and data

## Target Hardware

| Spec | Value |
|------|-------|
| FPGA | Xilinx XC7A35T-1CSG324 (Artix-7) |
| Clock | 100 MHz |
| I/O | 8 buttons, 16 LEDs (7-segment), 1 reset |
| I/O Standard | LVCMOS18 |

## Quick Start

### Prerequisites

- Xilinx Vivado 2018.2+ (tested on 2018.2)
- Artix-7 development board (or simulation only)

### Open Project

```bash
vivado src/sin_final/sin_final.xpr
```

### Run Simulation

```bash
cd src/sin_final/sin_final.sim/sim_1/behav/xsim
xsim top_sim -tclbatch top_sim.tcl
```

### Build Bitstream

1. Open `src/sin_final/sin_final.xpr` in Vivado
2. Run Synthesis → Implementation → Generate Bitstream
3. Output: `src/sin_final/sin_final.runs/impl_1/Top.bit`

## Project Structure

```
mips_soft_cpu/
├── src/sin_final/                          # Vivado project
│   ├── sin_final.xpr                       # Project file (open this)
│   ├── sin_final.srcs/
│   │   ├── sources_1/new/                  # RTL source files
│   │   │   ├── mips.v                      # Top module + MIPS core
│   │   │   ├── main_controller.v           # FSM control unit
│   │   │   ├── datapath.v                  # Data path
│   │   │   ├── alu.v                       # Integer ALU
│   │   │   ├── mlu.v                       # Multiply/divide unit
│   │   │   ├── flu.v                       # Floating-point unit
│   │   │   ├── registers.v                 # Register file
│   │   │   ├── memory_controller.v         # Memory interface
│   │   │   ├── decoders.v                  # Instruction decoders
│   │   │   ├── global_define.v             # Opcodes & constants
│   │   │   └── ...                         # Other modules
│   │   └── constrs_1/.../Top.xdc           # Pin constraints
│   └── sin_final.sim/                      # Simulation files
├── test/
│   └── sin_mips.s                          # Test program (sin calculation)
├── docs/
│   └── project_report_cn.pdf               # Documentation (Chinese)
└── README.md                               # This file
```

## Architecture

```
                    ┌─────────────────────────────────────────┐
                    │                  Top                    │
                    │  ┌───────────────────────────────────┐  │
                    │  │              MIPS                 │  │
                    │  │  ┌─────────────┐ ┌─────────────┐  │  │
                    │  │  │  DataPath   │ │    Main     │  │  │
                    │  │  │ ┌─────────┐ │ │  Controller │  │  │
                    │  │  │ │Registers│ │ │    (FSM)    │  │  │
                    │  │  │ │ GPR/FPR │ │ │             │  │  │
                    │  │  │ ├─────────┤ │ └─────────────┘  │  │
                    │  │  │ │   ALU   │ │                  │  │
                    │  │  │ │   MLU   │ │   ┌──────────┐   │  │
                    │  │  │ │   FLU   │ │   │ Decoders │   │  │
                    │  │  │ └─────────┘ │   └──────────┘   │  │
                    │  │  └─────────────┘                  │  │
                    │  └───────────────────────────────────┘  │
                    │  ┌─────────────┐  ┌─────────────────┐   │
                    │  │  Memory     │  │    I/O          │   │
                    │  │  Controller │  │  (Buttons/LEDs) │   │
                    │  └─────────────┘  └─────────────────┘   │
                    └─────────────────────────────────────────┘
```

### Pipeline Stages (Multi-cycle)

| Stage | Description |
|-------|-------------|
| FETCH | Read instruction from memory |
| DECODE | Decode opcode, read registers |
| EXECUTE | ALU/FLU computation |
| MEMORY | Load/store memory access |
| WRITEBACK | Write result to register |

## Implemented Instructions

### Integer (23 instructions)

| Category | Instructions |
|----------|-------------|
| Arithmetic | `addiu`, `addu`, `subu`, `multu`, `mfhi`, `mflo` |
| Logical | `andi`, `sll`, `sllv`, `srl`, `srlv` |
| Comparison | `slt`, `slti` |
| Branch | `beq`, `bne`, `bgez`, `blez` |
| Jump | `j`, `jal`, `jr` |
| Memory | `lw`, `sw`, `lui` |

### Floating-Point (13 instructions)

| Category | Instructions |
|----------|-------------|
| Arithmetic | `add.s`, `sub.s`, `mul.s`, `div.s` |
| Conversion | `cvt.s.w`, `cvt.w.s` |
| Comparison | `c.le.s`, `c.lt.s` |
| Branch | `bc1t` |
| Transfer | `mtc1`, `mfc1` |
| Memory | `lwc1`, `swc1` |

## Registers

- **32 General Purpose Registers**: `$zero`, `$at`, `$v0-$v1`, `$a0-$a3`, `$t0-$t9`, `$s0-$s7`, `$k0-$k1`, `$gp`, `$sp`, `$fp`, `$ra`
- **32 Floating Point Registers**: `$f0`-`$f31`
- **Special**: `HI`, `LO` (multiply/divide results)

## Memory Map

| Address | Description |
|---------|-------------|
| `0x0000` - `0x3FFF` | Instruction/Data Memory (4KB) |
| `0x2500` | Button Input (read) |
| `0x2504` | LED Output (write) |
| `0x3FFC` | Initial Stack Pointer |

## Test Program

The included test program (`test/sin_mips.s`) demonstrates:
- Reading input from buttons
- Computing sin(x) using Taylor series
- Displaying result on 7-segment LEDs

```bash
# To run: load memory.dat with assembled program, then simulate
```

## Documentation

- **Project Report**: [docs/project_report_cn.pdf](docs/project_report_cn.pdf) (Chinese)

## Known Limitations

1. Single testbench only (no unit tests for individual modules)
2. Clock divider has a minor bug (see `clock_transformer.v:68-73`)
3. Not all MIPS instructions are implemented
4. Vivado project contains hardcoded Windows paths in TCL scripts

## License

This is an academic course project. Use for educational purposes.
