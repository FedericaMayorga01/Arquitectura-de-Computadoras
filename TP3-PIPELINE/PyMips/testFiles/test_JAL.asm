ADDI r5, r0, 10       # r5 = 10 (0xa)
JAL FUNCION           # Guarda PC+8 en r31 y salta a FUNCION
ADDI r6, r0, 1        # r6 = 1 (0x1)Instruccion en delay slot (se ejecuta antes del salto)
ADDI r4, r0, 2        # r4 = 2 (0x2)
HALT                  # Se debe retornar aqui después de JR

FUNCION: ADDI r7, r0, 20   # r7 = 20 (0x14)
    JR r31            # Retorna a la direccion guardada en r31 (después de JAL)
    ADDI r8, r0, 3    # r8 = 3 (0x3)Instruccion en delay slot (se ejecuta antes del salto)
