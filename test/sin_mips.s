# -------------------------------------
.globl main
main:
    addiu   $sp, $sp, -0x30
    sw      $ra, 0x2C($sp)
    sw      $fp, 0x28($sp)
    addu    $fp, $zero, $sp
    lw      $v0, 0x00002ff8($zero)
# load degree from input device
    jal     deg_range_convert
    sw      $v0, 0x1C($fp)
    lw      $a0, 0x1C($fp)
    jal     sin_mips
    nop
    swc1    $f0, 0x20($fp)
    lwc1    $f12, 0x20($fp)
    jal     convert_digits
    nop
    sw      $v0, 0x24($fp)
    sw      $v0, 0x00002ffc($zero)
# output result to output device
    addu    $sp, $zero, $fp
    lw      $ra, 0x2C($sp)
    lw      $fp, 0x28($sp)
    addiu   $sp, $sp, 0x30
wait_signal:
    lw      $t1,0x00002010($zero)
    blez    $t1,wait_signal
    jr      $ra
    nop
#--------------------------------------
    .globl sin_mips
sin_mips:
    addiu   $sp, $sp, -0x20
    sw      $fp, 0x1C($sp)
    addu    $fp, $zero, $sp
    sw      $a0, 0x20($fp)
    sw      $zero, 0x04($fp)
    lw      $v0, 0x20($fp)
    mtc1    $v0, $f0
    cvt.s.w $f2, $f0
    lui     $v0, 0x40
    lwc1    $f0, flt_400B20
    mul.s   $f2, $f2, $f0
    lui     $v0, 0x40
    lwc1    $f0, flt_400B24
    div.s   $f0, $f2, $f0
    swc1    $f0, 0x14($fp)
    addiu   $v0, $zero, 1
    sw      $v0, 0x08($fp)
    bgez    $zero,LL0C
    nop
# -------------------------------------
CC:
    lwc1    $f0, 0x14($fp)
    swc1    $f0, 0x0C($fp)
    addiu   $v0, $zero, 2
    sw      $v0, 0x10($fp)
    bgez    $zero,LLA
    nop
# -------------------------------------
LLo:
    lwc1    $f2, 0x0C($fp)
    lwc1    $f0, 0x14($fp)
    mul.s   $f0, $f2, $f0
    swc1    $f0, 0x0C($fp)
    lw      $v0, 0x10($fp)
    mtc1    $v0, $f0
    cvt.s.w $f0, $f0
    lwc1    $f2, 0x0C($fp)
    div.s   $f0, $f2, $f0
    swc1    $f0, 0x0C($fp)
    lw      $v0, 0x10($fp)
    addiu   $v0, $v0, 1
    sw      $v0, 0x10($fp)
LLA:
    lw      $v0, 0x08($fp)
    sll     $v0, $v0, 1
    addiu   $v0, $v0, -1
    lw      $v1, 0x10($fp)
    slt     $v0, $v0, $v1
    beq     $v0, $zero, LLo
    nop
    lw      $v0, 0x08($fp)
    andi    $v0, 1
    bne     $v0, $zero, LLE
    nop
    lw      $v1, 0x0C($fp)
    lui     $v0, 0x8000
    xor     $v0, $v1, $v0
    bgez    $zero,LLEC
    nop
# -------------------------------------
LLE:
    lw      $v0, 0x0C($fp)
LLEC:
    sw      $v0, 0x0C($fp)
    lwc1    $f2, 0x04($fp)
    lwc1    $f0, 0x0C($fp)
    add.s   $f0, $f2, $f0
    swc1    $f0, 0x04($fp)
    lw      $v0, 0x08($fp)
    addiu   $v0, $v0, 1
    sw      $v0, 0x08($fp)
LL0C:
    lw      $v0, 0x08($fp)
    slti    $v0, $v0,7
    bne     $v0, $zero, CC
    nop
    lwc1    $f0, 0x04($fp)
    addu    $sp, $zero, $fp
    lw      $fp, 0x1C($sp)
    addiu   $sp, $sp, 0x20
    jr      $ra
    nop
# ========= S U B R O U T I N E ========
    .globl convert_digits
convert_digits:
    addiu   $sp, $sp, -0x18
    sw      $fp, 0x14($sp)
    addu    $fp, $zero, $sp
    swc1    $f12, 0x18($fp)
    lwc1    $f2, 0x18($fp)
    lui     $v0, 0x40
    lwc1    $f0, flt_400B28
    mul.s   $f0, $f2, $f0
    lwc1    $f2, flt_400B2C
    c.le.s  $f2, $f0
    bc1t    LL8C
    nop
    cvt.w.s $f0, $f0
    mfc1    $v0, $f0
    bgez    $zero, LL88C
    nop
# -------------------------------------
LL8C:
    sub.s   $f0, $f0, $f2
    lui     $v1, 0x8000
    cvt.w.s $f0, $f0
    mfc1    $v0, $f0
    or      $v0, $v0, $v1
LL88C:
    sw      $v0, 0x04($fp)
    sw      $zero, 0x08($fp)
    sw      $zero, 0x0C($fp)
    bgez    $zero,  CB
    nop
# -------------------------------------
LL8A:
    lw      $a0, 0x04($fp)
    addiu   $v0, $zero, 0xCCCCCCCD
    multu   $a0, $v0
    mfhi    $v0
    srl     $v1, $v0, 3
    addu    $v0, $zero, $v1
    sll     $v0, $v0, 2
    addu    $v0, $v0, $v1
    sll     $v0, $v0, 1
    subu    $v1, $a0, $v0
    lw      $v0, 0x0C($fp)
    sll     $v0, $v0, 2
    sllv    $v1, $v1, $v0
    lw      $v0, 0x08($fp)
    addu    $v0, $v1, $v0
    sw      $v0, 0x08($fp)
    lw      $v1, 0x04($fp)
    addiu   $v0, $zero, 0xCCCCCCCD
    multu   $v1, $v0
    mfhi    $v0
    srl     $v0, $v0, 3
    sw      $v0, 0x04($fp)
    lw      $v0, 0x0C($fp)
    addiu   $v0, $v0, 1
    sw      $v0, 0x0C($fp)
CB:
    lw      $v1, 0x0C($fp)
    addiu   $v0, $zero, 7
    bne     $v1, $v0, LL8A
    nop
    lw      $v0, 0x08($fp)
    addu    $sp, $zero, $fp
    lw      $fp, 0x14($sp)
    addiu   $sp, $sp, 0x18
    jr      $ra
    nop
#----------convert v0 to 0-90deg-------
deg_range_convert:
    slti    $t0, $v0, 360
    bne     $t0, $zero, D1
    addi    $v0, $v0, -360
    j       deg_range_convert
# judge if v0 gt 180 and lt 360, $t9 to 1
D1:
    slti    $t0, $v0, 180
    bne     $t0, $zero, D2
    addi    $t0, $zero, 360
    sub     $v0, $t0, $v0
    addi    $t9, $zero, 1
D2:
    slti    $t0, $v0, 90
    bne     $t0, $zero, D3
    addi    $t0, $zero, 180
    sub     $v0, $t0, $v0
D3:
    jr      $ra
#--------------------------------------
             .data
flt_400B20: .float 3.1415927
flt_400B24: .float 180.0
flt_400B28: .float 1.0e7
flt_400B2C: .float 2.1474836e9
