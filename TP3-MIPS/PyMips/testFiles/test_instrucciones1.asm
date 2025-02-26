ADDI r1, r0, 5              # r1 = 0x5
ADDI r2, r0, 10             # r2 = 0xA
ADDI r3, r0, 15             # r3 = 0xF
ADDI r4, r0, 20             # r4 = 0x14
ADDI r5, r0, 25             # r5 = 0x19
ADDI r7, r0, 4369         # r7 = 0x1111
ADDI r8, r0, 30             # r8 = 0x1E
ADDI r9, r0, 35             # r9 = 0x23
ADDI r10, r0, 40            # r10 = 0x28

SLL r6, r4, 5               # r6 = r4 << 5 = 0x280
SRL r2, r4, 3               # r2 = r4 >> 3 = 0x2
SW   r7, r0, 12              # MEM[3]  = 0x1111 (Palabra completa de r7)
SRA r5, r1, 2               # r5 = r1 >>> 2 = 0x1

SLLV r10, r3, r5            # r10 = r3 << r5 = 0x1E
SRLV r10, r3, r5            # r10 = r3 >> r5 = 0x7
SRAV r10, r3, r5            # r10 = r3 >>> r5 = 0x7
SB   r7, r0, 4              # MEM[0x1]  = 0x11 (Byte menos significativo de r7)(0x0011)
ADDU r15, r2, r9            # r15 = r2 + r9 = 0x25
SUBU r15, r2, r9            # r15 = r2 - r9 = 0xFFFFFFDF
AND r10, r5, r8             # r10 = r5 AND r8 = 0x0
OR  r10, r5, r8             # r10 = r5 OR r8 = 0x1F
XOR r10, r5, r8             # r10 = r5 XOR r8 = 0x1F
NOR r10, r5, r8             # r10 = ~(r5 OR r8) = 0xFFFFFFE0
SLT r10, r5, r8             # r10 = (r5 < r8) ? 1 : 0 = 0x1

HALT