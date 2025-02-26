ADDI r1, r0, 1     # r1 = 0x1
ADDI r2, r0, 1     # r2 = 0x1
ADDI r3, r0, 5     # r3 = 0x5
ADDI r4, r0, 6     # r4 = 0x6

BNE r1, r2, SALTO  # No salta (r1 == r2)
ADDI r9, r0, 2     # r9 = 0x2
BEQ r1, r2, SALTO  # si salta porque r1 == r2
NOP                
ADDI r9, r0, 4     

SALTO: ADDI r9, r0, 3     # r9 = 0x3

BEQ r3, r4, NUEVOSALTO  # no salta (r3 != r4)
ADDI r8, r0, 2          # r8 = 0x2
BNE r3, r4, NUEVOSALTO  # Si salta porque r3 != r4
NOP     
ADDI r8, r0, 4

NUEVOSALTO: ADDI r8, r0, 3     # r8 = 0x3

HALT
