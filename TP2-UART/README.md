# Trabajo Practico #2 - UART

## Objetivo


## COMPONENTES
Consta de cuatro componentes principales:
- un receptor UART: el circuito para obtener la palabra de datos mediante sobremuestreo
- un tranmisor UART:
- un generador de velocidad en baudios: el circuito para generar los ticks de muestreo
- un circuito de interfaz: el circuito que proporciona un búfer y un estado entre el receptor UART y el sistema que utiliza el UART, y lo mismo para el trasmisor UART.
- una unidad aritmetica logica: es la encargada de realizar las operaciones con los datos que recibe, y enviar el resultado de ella.

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

### rx - uart

Este código en Verilog implementa un receptor de datos en serie (modulación UART), donde se recibe un bit a la vez desde la entrada i_rxmodule_RX y se reconstruye el byte completo. Está estructurado como una máquina de estados finitos (FSM), que cambia de estado a medida que avanza el proceso de recepción de un byte.

Parámetros:
- NB_RXMODULE_DATA = 8: Define el número de bits de datos que se van a recibir (en este caso, 8 bits).
- SB_RXMODULE_TICKS = 16: Define la cantidad de ticks que debe durar el bit de stop. Como se utiliza un solo bit de stop, la cantidad de tick es solamente 16.
  
Entradas:
- i_clk: Señal de reloj del sistema.
- i_reset: Señal de reinicio que restablece los registros y estados del módulo(a estado idle).
- i_rxmodule_RX: Señal de recepción de datos en serie (UART RX).
- i_rxmodule_BRGTICKS: Señal de los "baud rate generator ticks", que indica cuándo es el momento de leer el siguiente bit.

Salidas:
- o_rxmodule_RXDONE: Señal que indica cuando se ha recibido un byte completo.
- o_rxmodule_DOUT: El byte recibido en paralelo.

Estados:
El módulo usa una máquina de estados con los siguientes estados:
- rxmodule_idlestate (00): Estado de espera, esperando el bit de inicio de la trama (que es un 0 en UART).
- rxmodule_startstate (01): Estado que verifica la duración del bit de inicio.
- rxmodule_datastate (10): Estado de lectura de los bits de datos.
- rxmodule_stopstate (11): Estado que verifica el bit de stop.
  
Registros:
- rxmodule_regstate y rxmodule_nextstate: Mantienen el estado actual y el próximo estado de la máquina de estados. Esto a traves de los dos bits que identifican a cada uno de los 4 estados.
- rxmodule_samptickreg y rxmodule_sampticknextreg: Contadores de ticks para medir el tiempo de cada bit.
- rxmodule_nbrecreg y rxmodule_nbrecnextreg: Contador de bits recibidos.
- rxmodule_bitsreasreg y rxmodule_bitsreasnextreg: Almacenan los bits recibidos y los van desplazando para reconstruir el byte(ya que los bits llegan de a uno).
  
Funcionamiento:
- Estado rxmodule_idlestate: El módulo permanece en este estado hasta que se detecta un 0 en i_rxmodule_RX, lo que indica el bit de inicio de una trama UART. Si se detecta un 0, pasa al estado rxmodule_startstate.
- Estado rxmodule_startstate: Este estado espera que el contador de ticks llegue a 7 (para sincronizarse con el centro del bit de inicio). Una vez alcanzado el tick 7, pasa al estado rxmodule_datastate para empezar a recibir los bits de datos.
- Estado rxmodule_datastate: Este estado lee los bits de datos uno por uno en los bordes de i_rxmodule_BRGTICKS. Se construye el byte desplazando los bits hacia la derecha (rxmodule_bitsreasnextreg = {i_rxmodule_RX, rxmodule_bitsreasreg[7:1]}) y se incrementa el contador de bits rxmodule_nbrecreg. Una vez recibidos todos los bits (NB_RXMODULE_DATA), pasa al estado rxmodule_stopstate.
-Estado rxmodule_stopstate: Este estado verifica que se ha recibido correctamente el bit de stop (que debería ser un 1). Cuando se completa el bit de stop (después de SB_RXMODULE_TICKS ticks), el módulo vuelve al estado rxmodule_idlestate y activa o_rxmodule_RXDONE para indicar que se ha recibido un byte completo.

Salida de Datos:
- La salida o_rxmodule_DOUT contiene el byte completo que ha sido recibido en serie.
- La señal o_rxmodule_RXDONE indica que la recepción ha terminado.

Resumen:
Este módulo implementa la recepción de datos en serie (UART) mediante una máquina de estados que detecta el bit de inicio, lee los bits de datos y finaliza con el bit de stop. Los datos recibidos se almacenan en o_rxmodule_DOUT, y una señal o_rxmodule_RXDONE indica cuando se ha recibido un byte completo.
