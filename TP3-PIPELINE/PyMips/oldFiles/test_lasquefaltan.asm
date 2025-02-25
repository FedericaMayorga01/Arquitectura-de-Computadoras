ADDIU r1, r0, -5    # r1 = 0xFFFFFFFB (-5 en complemento a dos)
ADDIU r2, r1, 10    # r2 = r1 + 10 = (-5) + 10 = 5
ADDI r3, r0, 3    # 
ADDI r4, r0, 4    #
ADDI r5, r0, 5    # 
SLTIU r6, r3, 10           # r6 = (r3 < 10) en sin signo -> r6 = (3 < 10) ? 1 : 0 -> 0x1  
SLTU r7, r3, r4            # r7 = (r3 < r4) en sin signo -> r7 = (3 < 4) ? 1 : 0 -> 0x1  
SLT r8, r3, r4             # r8 = (r3 < r4) ? 1 : 0 = 0x1

HALT