ADDI r5, r0, 10       # r5 = 10 (0xa)
ADDI r6, r0, FUNCION  # Cargar direccion de FUNCION en r6
JR r6                 # Salta a la direccion guardada en r6
ADDI r7, r0, 1        # r7 = 1 (0x1)Instruccion en delay slot (se ejecuta antes del salto)

FUNCION:ADDI r8, r0, 20   # r8 = 20(0x14), prueba de que llegamos aquí
    HALT              # Fin del programa
