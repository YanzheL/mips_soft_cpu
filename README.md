## MIPS-32 Soft-Core CPU

This is my course project for ***Machine Organization*** at HIT.

It contains a Soft-Core MIPS-32 CPU written by Verilog, and tested on Xilinx XC7A35T-1 CPG236C FPGA.

An example assembly code [sin_mips](test/sin_mips.s) is provided for testing, which calculates the sin() value of the input from on-board buttons.

#### Implemented instructions

| addiu  | addu  | add.s | andi    | bc1t    | beq    |
| ------ | ----- | ----- | ------- | ------- | ------ |
| bgez   | blez  | bne   | cvt.w.s | cvt.s.w | c.le.s |
| c.lt.s | div.s | mtc1  | mfc1    | mul.s   | multu  |
| mfhi   | mflo  | lw    | lwc1    | lui     | j      |
| jal    | jr    | sll   | sllv    | slt     | slti   |
| srl    | srlv  | sw    | swc1    | sub.s   | subu   |

#### Implemented Registers

32 General Purpose Registers `$v0`-`$v31`

32 Floating Point Registers `$f0`-`$f31`

Detailed documentation (Project Report) can be found in [docs](docs) directory, but currently it is in Chinese.
