# Trabajo Practico #2 - UART

## Objetivo


## COMPONENTES
Consta de cuatro componentes principales:
- un receptor UART: el circuito para obtener la palabra de datos mediante sobremuestreo
- un generador de velocidad en baudios: el circuito para generar los ticks de muestreo
- un circuito de interfaz: el circuito que proporciona un búfer y un estado entre el receptor UART y el sistema que utiliza el UART
- una unidad aritmetica logica: es la encargada de realizar las operaciones con los datos que recibe.

### Baud Rate Generator
Para una velocidad de 9600 baudios, la frecuencia de muestreo debe ser de 153600 (es decir, 9600*16) ticks por segundo. Dado que la frecuencia de reloj del sistema es de 50 MHz, el generador de velocidad de baudios necesita un contador mod-325[(50*10^6)/(153600) = 325.52], en el que se activa un tick de un ciclo de reloj una vez cada 325 ciclos de reloj.

Este código en Verilog implementa un contador parametrizado que cuenta hasta un valor máximo determinado por el parámetro MOD_BAUDRGMODULE_M, y luego se reinicia a cero. El contador genera dos salidas:
- o_baudrgmodule_MAXTICK: Una señal que indica cuándo el contador ha alcanzado su valor máximo (cuando ha contado hasta MOD_BAUDRGMODULE_M - 1).
- o_baudrgmodule_RATE: El valor actual del contador.

Desglose del código:  
Parámetros:
- NB_BAUDRGMODULE_COUNTER: Especifica el número de bits del contador. En este caso, está definido como 9, ya que necesitamos contar hasta 325, algo que no nos permitirian 8 bits ya que su maximo es 256(log2(9)=8.34, como el resultado es mayor a 8, entonces pasa a ser 9).
- MOD_BAUDRGMODULE_M: El valor máximo hasta el cual el contador cuenta antes de reiniciarse. En este caso, está definido como 325, que representa un divisor de reloj para generar una tasa de 9600 baudios.
  
Entradas:
- i_clk: La señal de reloj. El contador se actualiza en cada flanco positivo de esta señal.
- i_reset: Señal de reinicio que pone el contador a 0 cuando se activa
  
Salidas:
- o_baudrgmodule_MAXTICK: Indica cuándo el contador ha alcanzado su valor máximo (cuando el contador es igual a MOD_BAUDRGMODULE_M - 1 (324 en este caso)).
- o_baudrgmodule_RATE: Muestra el valor actual del contador.
  
Registros:
baudrgmodule_cont: Es el registro que almacena el valor actual del contador. Este registro tiene un tamaño de NB_BAUDRGMODULE_COUNTER bits (en este caso, 9 bits).

Lógica principal:  
- Si i_reset está activo (1), el contador baudrgmodule_cont se reinicia a 0.
- En cada flanco positivo de i_clk (ciclo de reloj), el contador se incrementa en 1 hasta alcanzar el valor MOD_BAUDRGMODULE_M (en este caso, 325).
- Cuando el contador llega a MOD_BAUDRGMODULE_M - 1, se reinicia a 0, lo que genera un ciclo repetitivo.

Lógica de salida:  
- o_baudrgmodule_RATE siempre refleja el valor actual del contador.
- o_baudrgmodule_MAXTICK se activa (1) cuando el contador alcanza MOD_BAUDRGMODULE_M-1, indicando que el contador ha completado un ciclo completo.
  
Resumen:
Este módulo actúa como un divisor de frecuencia. Toma una señal de reloj de entrada i_clk (que es mucho más rápida) y la divide por un valor específico (MOD_BAUDRGMODULE_M = 325). Esto genera un tick o pulso de salida (o_baudrgmodule_MAXTICK) que es utilizado para sincronizar la transmisión y recepcion de datos a la velocidad de 9600 baudios.


