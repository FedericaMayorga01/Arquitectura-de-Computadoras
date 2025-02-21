ADDI r4, r0, 1     # r4 = 0x1
ADDI r6, r0, 2     # r6 = 0x2
ADDI r1, r0, 5     # r1 = 0x5
AND  r5, r1, r4    # r5 = r1 AND r4 = 0x5 AND 0x1 = 0x1
OR   r7, r6, r1    # r7 = r6 OR r1 = 0x2 OR 0x5 = 0x7
ADDI r8, r1, r1    # r8 = r1 + r1 = 0x5 + 0x5 = 0xA
SW   r1, r0, 4     # MEM[1] = 0x5 
HALT
