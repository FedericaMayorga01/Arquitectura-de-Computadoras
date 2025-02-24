ADDI r5, r0, 10       # r5 = 10 (0xa)
J FUNCION             # Salta directamente a FUNCION
ADDI r6, r0, 1        # r6 = 1 (0x1) Instruccion en delay slot (se ejecuta antes del salto)

FUNCION: ADDI r7, r0, 20   # r7 = 20(0x14), prueba de que llegamos aca
    HALT              # Fin del programa
