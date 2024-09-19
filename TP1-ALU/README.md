# Trabajo Practico #1 - ALU 

## Objetivo
El objetivo es desarrollar una Unidad Lógica Aritmética (ALU) parametrizable, que pueda operar sobre un bus de datos configurable. Esta ALU se implementará en una placa NEXYS 4 con FPGA Artix-7 y se validará mediante un Test Bench (banco de pruebas). Además, simularemos el diseño utilizando las herramientas de simulación de Vivado (Version 2023.1).
A continuación, se detallan los pasos necesarios para lograrlo:

- Desarrollo de la ALU en lenguaje Verilog:
    Crearemos una ALU simple, combinacional y parametrizable que pueda adaptarse a diferentes configuraciones de bus de datos, para implementar las operaciones aritméticas y lógicas necesarias en el diseño de la ALU.

    Las operaciones de la ALU son las siguientes:
    | Operaciones | Codigo |
    |:-----:|:-----:|
    | ADD | 100000 |
    | SUB | 100010 |
    | AND | 100100 |
    | OR | 100101 |
    | XOR | 100110 |
    | SRA | 000011 |
    | SRL | 000010 |
    | NOR | 100111 |

- Implementación en FPGA:
    Utilizaremos una FPGA para implementar físicamente nuestra ALU y le configuraremos los recursos para que coincidan con las especificaciones de la ALU.

- Validación mediante Test Bench:
    Crearemos un Test Bench que genere entradas aleatorias para la ALU y verificaremos que las salidas de la ALU sean correctas según las operaciones realizadas.

- Simulación con Vivado:
    Utilizaremos las herramientas de simulación de Vivado para simular el comportamiento de la ALU.

---

