ADDI r5, r0, 10       # r5 = 0xA (10 en decimal)
JAL FUNCION           # Llama a FUNCION y guarda PC+4 en r31 (r31 = direccion de HALT)
NOP                   # Instruccion en delay slot (se ejecuta antes de saltar)
ADDI r4, r0, 2        # r4 = 0x2 (2 en decimal)
HALT                  # Se debe retornar aqui despues del JR en FUNCION

FUNCION: ADDI r6, r0, 20   # r6 = 0x14 (20 en decimal, indica que entramos a la función)
    J SALTO_DIRECTO        # Salta a SALTO_DIRECTO
    NOP                    # Instruccion en delay slot (se ejecuta antes del salto)

SALTO_DIRECTO: ADDI r7, r0, 30   # r7 = 0x1E (30 en decimal, prueba de que el salto funciona)
    JR r31                # Retorna a la direccion guardada en r31 (que es la direccion de HALT)
    NOP                   # Instruccion en delay slot (se ejecuta antes de saltar)