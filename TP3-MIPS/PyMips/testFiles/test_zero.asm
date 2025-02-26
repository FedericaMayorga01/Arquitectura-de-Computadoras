ADDI r1, r0, 0
ADDI r2, r0, 0
ADDI r3, r0, 0
ADDI r4, r0, 0
ADDI r5, r0, 0
ADDI r6, r0, 0
ADDI r7, r0, 0
ADDI r8, r0, 0
ADDI r9, r0, 0
ADDI r10, r0, 0
ADDI r11, r0, 0
ADDI r12, r0, 0
ADDI r13, r0, 0
ADDI r14, r0, 0
ADDI r15, r0, 0
ADDI r16, r0, 0
ADDI r17, r0, 0
ADDI r18, r0, 0
ADDI r19, r0, 0
ADDI r20, r0, 0
ADDI r21, r0, 0
ADDI r22, r0, 0
ADDI r23, r0, 0
ADDI r24, r0, 0
ADDI r25, r0, 0
ADDI r26, r0, 0
ADDI r27, r0, 0
ADDI r28, r0, 0
ADDI r29, r0, 0
ADDI r30, r0, 0
ADDI r31, r0, 0

# Inicializar las 32 posiciones de memoria en 0
ADDI r1, r0, 0   # r1 = 0, se usara para escribir en memoria

SW r1, 0(r0)    # MEM[0]  = 0
SW r1, 4(r0)    # MEM[1]  = 0
SW r1, 8(r0)    # MEM[2]  = 0
SW r1, 12(r0)   # MEM[3]  = 0
SW r1, 16(r0)   # MEM[4]  = 0
SW r1, 20(r0)   # MEM[5]  = 0
SW r1, 24(r0)   # MEM[6]  = 0
SW r1, 28(r0)   # MEM[7]  = 0
SW r1, 32(r0)   # MEM[8]  = 0
SW r1, 36(r0)   # MEM[9]  = 0
SW r1, 40(r0)   # MEM[10] = 0
SW r1, 44(r0)   # MEM[11] = 0
SW r1, 48(r0)   # MEM[12] = 0
SW r1, 52(r0)   # MEM[13] = 0
SW r1, 56(r0)   # MEM[14] = 0
SW r1, 60(r0)   # MEM[15] = 0
SW r1, 64(r0)   # MEM[16] = 0
SW r1, 68(r0)   # MEM[17] = 0
SW r1, 72(r0)   # MEM[18] = 0
SW r1, 76(r0)   # MEM[19] = 0
SW r1, 80(r0)   # MEM[20] = 0
SW r1, 84(r0)   # MEM[21] = 0
SW r1, 88(r0)   # MEM[22] = 0
SW r1, 92(r0)   # MEM[23] = 0
SW r1, 96(r0)   # MEM[24] = 0
SW r1, 100(r0)  # MEM[25] = 0
SW r1, 104(r0)  # MEM[26] = 0
SW r1, 108(r0)  # MEM[27] = 0
SW r1, 112(r0)  # MEM[28] = 0
SW r1, 116(r0)  # MEM[29] = 0
SW r1, 120(r0)  # MEM[30] = 0
SW r1, 124(r0)  # MEM[31] = 0

HALT
