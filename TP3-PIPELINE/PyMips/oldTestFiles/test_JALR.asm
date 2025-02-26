ADDI r5, r0, 10       # r5 = 10 (0xa)
ADDI r6, r0, FUNCION  # Guarda la direccion de FUNCION en r6
JALR r31, r6          # Guarda PC+4 en r31 y salta a FUNCION
ADDI r7, r0, 1        # r7 = 1 (0x1)Instruccion en delay slot (se ejecuta antes del salto)
ADDI r4, r0, 2        # r4 = 2 (0x2)
HALT                  # Se debe retornar aqui después de JR

FUNCION:ADDI r8, r0, 20   # r8 = 20 (0x14)
    JR r31            # Retorna a la direccion guardada en r31
    ADDI r9, r0, 3    # r9 = 3 (0x3)Instruccion en delay slot (se ejecuta antes del salto)
