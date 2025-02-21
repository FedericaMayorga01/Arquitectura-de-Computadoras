ADDI r5, r0, 4              # r5 = 0x4  
ADDI r6, r0, 4              # r6 = 0x4  
ADDI r7, r0, 4369           # r7 = 0x1111  (0x00001111 en 32 bits)

SW   r7, r0, 12             # MEM[3] = r7 -> MEM[3] = 0x00001111  

ORI r10, r5, 32             # r10 = r5 OR 0x20 -> 0x4 OR 0x20 = 0x24  
XORI r11, r5, 32            # r11 = r5 XOR 0x20 -> 0x4 XOR 0x20 = 0x24  
LUI r10, 45                 # r10 = (45 << 16) -> 0x2D0000  
SLTI r10, r5, 32            # r10 = (r5 < 32) ? 1 : 0 -> 0x1  

LW  r11, 12(r0)             # r11 = MEM[3] -> r11 = 0x00001111  
LWU r15, 12(r0)             # r15 = MEM[3] (sin signo) -> r15 = 0x00001111  
LB  r12, 12(r0)             # r12 = Byte en MEM[3] -> r12 = 0x11 (ultimo byte de 0x00001111)  
LBU r16, 12(r0)             # r16 = Byte en MEM[3] (sin signo) -> r16 = 0x11  
LH  r13, 12(r0)             # r13 = Halfword en MEM[3] -> r13 = 0x1111  
LHU r17, 12(r0)             # r17 = Halfword en MEM[3] (sin signo) -> r17 = 0x1111  

ANDI r14, r7, 255           # r14 = r7 AND 255 -> 0x00001111 AND 0x000000FF = 0x00000011  

SH   r14, 8(r0)             # Guarda el halfword de r14 en MEM[2] -> MEM[2] = 0x0011  

HALT
