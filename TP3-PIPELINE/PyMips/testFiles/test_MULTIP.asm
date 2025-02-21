ADDI r29,r0,2       # r29 = 0x2
ADDI r30,r0,7       # r30 = 0x7

JAL MUL             # Salta a MUL, guarda la direccion de retorno en r31
NOP
HALT

MUL:ADDI r27,r0,0   # r27 = 0x0  (Resultado de la multiplicacion)
    ADDI r28,r0,0   # r28 = 0x0  (Contador)

LOOP:BEQ r28,r30,END # Si r28 == r30, salta a END
    ADDI r28,r28,1  # Incrementa el contador
    J LOOP
    ADDU r27,r27,r29 # Suma r29 a r27 en cada iteracion (multiplicacion)
END:JR r31          # Retorna a la direccion guardada en r31
    NOP
