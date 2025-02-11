# Trabajo Practico #3 - PIPELINE

## Objetivo

---

El objetivo principal de este trabajo práctico final es implementar el pipeline de un procesador DLX (familia MIPS). Esto implica diseñar y construir un modelo que simule el funcionamiento de un procesador MIPS con segmentación.

Para implementar el pipeline, hay que dividir la ejecución de las instrucciones en etapas secuenciales (IF, ID, EX, MEM, WB) y permitir que múltiples instrucciones se encuentren en diferentes etapas de ejecución al mismo tiempo. Se debe implementar un subconjunto específico de instrucciones MIPS, incluyendo instrucciones de tipo R, tipo I y tipo J, que se muestran a continuación:

- **R-Type:**
  - SLL, SRL, SRA, SLLV, SRLV, SRAV, ADDU, SUBU, AND, OR, XOR, NOR, SLT, SLTU

- **I-Type:**
  - LB, LH, LW, LWU, LBU, LHU, SB, SH, SW, ADDI, ADDIU, ANDI, ORI, XORI, LUI, SLTI, SLTIU, BEQ, BNE, J, JAL

- **J-Type:**
  - JR, JALR

Una parte crucial del trabajo es implementar mecanismos para detectar y resolver los diferentes tipos de riesgos que surgen en un pipeline:

- **Riesgos Estructurales:** Resolver conflictos cuando dos instrucciones necesitan el mismo recurso al mismo tiempo.

- **Riesgos de Datos:** Implementar cortocircuitos (forwarding) y detección de riesgos (stalling) para asegurar que los datos estén disponibles cuando se necesiten, evitando el uso de datos incorrectos.

- **Riesgos de Control:** Manejar los saltos condicionales (BEQ, BNE) y saltos incondicionales (J, JR) para evitar ejecutar instrucciones incorrectas después de un salto.

La memoria de instrucciones y la memoria de datos deben ser implementadas como bloques de memoria (IP Cores) separados.

Tambien, contar con una unidad de depuración, la cual debe enviar información a la PC a través de la UART. Esta información incluye el contenido de los registros, los latches intermedios del pipeline y la memoria de datos utilizada.

Finalmente, el procesador debe tener dos modos de operación:
- **Continuo:** Ejecuta el programa completo hasta el final y muestra los resultados finales.
- **Paso a Paso:** Ejecuta un ciclo de reloj por comando y muestra el estado del procesador en cada paso.