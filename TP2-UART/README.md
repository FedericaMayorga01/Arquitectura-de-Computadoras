# Trabajo Practico #2 - UART

## Objetivo


## Baud Rate Generator
Este código en Verilog implementa un contador parametrizado que cuenta hasta un valor máximo determinado por el parámetro MOD_BAUDRGMODULE_M, y luego se reinicia a cero. El contador genera dos salidas:
- o_baudrgmodule_MAXTICK: Una señal que indica cuándo el contador ha alcanzado su valor máximo (cuando ha contado hasta MOD_BAUDRGMODULE_M - 1).
- o_baudrgmodule_RATE: El valor actual del contador.

Desglose del código:  
Parámetros:
- NB_BAUDRGMODULE_COUNTER: Especifica el número de bits del contador. En este caso, está definido como 9, lo que significa que el contador puede representar valores de 0 a 29−1=5112^9 - 1 = 51129−1=511.
- MOD_BAUDRGMODULE_M: El valor máximo hasta el cual el contador cuenta antes de reiniciarse. En este caso, está definido como 325, que representa un divisor de reloj para generar una tasa de 9600 baudios (en un sistema UART, por ejemplo).
  
Entradas:
- i_clk: La señal de reloj. El contador se actualiza en cada flanco positivo de esta señal.
Salidas:
- o_baudrgmodule_MAXTICK: Indica cuándo el contador ha alcanzado su valor máximo (cuando el contador es igual a MOD_BAUDRGMODULE_M - 1).
- o_baudrgmodule_RATE: Muestra el valor actual del contador.
Registros:
baudrgmodule_cont: Es el registro que almacena el valor actual del contador. Este registro tiene un tamaño de NB_BAUDRGMODULE_COUNTER bits (en este caso, 9 bits).

Lógica principal:  
En cada flanco positivo del reloj:  
- Si el valor actual del contador (baudrgmodule_cont) es menor que el valor máximo (MOD_BAUDRGMODULE_M): El contador se incrementa en 1.  
- Si el contador ha alcanzado o superado el valor máximo, se reinicia a 0.

Lógica de salida:  
- o_baudrgmodule_RATE siempre refleja el valor actual del contador.
- o_baudrgmodule_MAXTICK se activa (1) cuando el contador alcanza MOD_BAUDRGMODULE_M-1, indicando que el contador ha completado un ciclo completo.
Resumen:
Este módulo implementa un contador mod-M parametrizado que cuenta desde 0 hasta MOD_BAUDRGMODULE_M-1 (324). Cuando alcanza este valor, el contador se reinicia a 0. Las salidas proporcionan el valor actual del contador y una señal de tick (o_baudrgmodule_MAXTICK) cuando se alcanza el valor máximo. Este tipo de contador se utiliza típicamente en sistemas de control de tasa, como la generación de señales de baud rate en sistemas UART.
