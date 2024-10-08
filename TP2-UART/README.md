# Trabajo Practico #2 - UART

## Objetivo
El objetivo es implementar un módulo transmisor-receptor del tipo UART en una FPGA. Para lograrlo, se desarrollarán módulos auxiliares como un generador de velocidad en baudios (Baud Rate Generator), interfaces y demas. El módulo UART desempeña un papel fundamental, su función consiste en tomar bytes de datos y transmitir los bits individualmente de forma secuencial. En el extremo receptor, otro UART reensambla los bits en bytes completos. La transmisión serial de información digital a través de un único cable o medio es más eficiente en términos de costo de transmisión. En resumen, el UART convierte la información entre su forma secuencial a paralela, y viceversa en cada punto de enlace.


### Componentes
Consta de cuatro componentes principales:
  - **Un receptor UART:** el circuito para obtener la palabra de datos mediante sobremuestreo.
  - **Un tranmisor UART:** el encargado de enviar datos en serie desde la placa hacia otro dispositvo.
  - **Un generador de velocidad en baudios:** el circuito para generar los ticks de muestreo.
  - **Un circuito de interfaz:** el circuito que proporciona un búfer y un estado entre el receptor UART y el sistema que utiliza el UART, y lo mismo para el trasmisor UART.
  - **Una unidad aritmetica logica:** es la encargada de realizar las operaciones con los datos que recibe, y enviar el resultado de ella.

### Baud Rate Generator
Para una velocidad de 9600 baudios, la frecuencia de muestreo debe ser de 153600  ticks por segundo (es decir, 9600*16). Dado que la frecuencia de reloj del sistema es de 50 MHz, el generador de velocidad de baudios necesita un contador mod-325[(50*10^6)/(153600) = 325.52], en el que se activa un tick de un ciclo de reloj una vez cada 325 ciclos de reloj.


Este código en Verilog implementa un contador parametrizado que cuenta hasta un valor máximo determinado por el parámetro `MOD_BAUDRGMODULE_M`, y luego se reinicia a cero. El contador genera dos salidas:
  - `o_baudrgmodule_MAXTICK`: Una señal que indica cuándo el contador ha alcanzado su valor máximo (cuando ha contado hasta `MOD_BAUDRGMODULE_M` - 1).
  - `o_baudrgmodule_RATE`: El valor actual del contador.

**Desglose del código:**
**Parámetros:**
  - `NB_BAUDRGMODULE_COUNTER`: Especifica el número de bits del contador. En este caso, está definido como 9, ya que necesitamos contar hasta 325, algo que no nos permitirian 8 bits ya que su maximo es 256 [log2(9)=8.34], como el resultado es mayor a 8, entonces pasa a ser 9.
  - `MOD_BAUDRGMODULE_M`: El valor máximo hasta el cual el contador cuenta antes de reiniciarse. En este caso, está definido como 325, que representa un divisor de reloj para generar una tasa de 9600 baudios.
  

**Entradas:**
  - `i_clk`: Señal de reloj. El contador se actualiza en cada flanco positivo de esta señal.
  - `i_reset`: Señal de reinicio que pone el contador a 0 cuando se activa.
  

**Salidas:**
  - `o_baudrgmodule_MAXTICK`: Indica cuándo el contador ha alcanzado su valor máximo (cuando el contador es igual a [`MOD_BAUDRGMODULE_M` - 1] (324 en este caso)).
  - `o_baudrgmodule_RATE`: Muestra el valor actual del contador.
  

**Registros**:
  - `baudrgmodule_cont`: Es el registro que almacena el valor actual del contador. Este registro tiene un tamaño de `NB_BAUDRGMODULE_COUNTER` bits (en este caso, 9 bits).


**Lógica principal:**
  - Si `i_reset` está activo (1), el contador `baudrgmodule_cont` se reinicia a 0.
  - En cada flanco positivo de `i_clk` (ciclo de reloj), el contador se incrementa en 1 hasta alcanzar el valor `MOD_BAUDRGMODULE_M` (en este caso, 325).
  - Cuando el contador llega a [`MOD_BAUDRGMODULE_M` - 1], se reinicia a 0, lo que genera un ciclo repetitivo.


**Lógica de salida:**
  - `o_baudrgmodule_RATE` siempre refleja el valor actual del contador.
  - `o_baudrgmodule_MAXTICK` se activa (1) cuando el contador alcanza [`MOD_BAUDRGMODULE_M` - 1], indicando que el contador ha completado un ciclo completo.


**Resumen:**
Este módulo actúa como un divisor de frecuencia. Toma una señal de reloj de entrada `i_clk` (que es mucho más rápida) y la divide por un valor específico (`MOD_BAUDRGMODULE_M` = 325). Esto genera un tick o pulso de salida (`o_baudrgmodule_MAXTICK`) que es utilizado para sincronizar la transmisión y recepcion de datos a la velocidad de 9600 baudios.

### Rx - UART
Este código en Verilog implementa un receptor de datos en serie (modulación UART), donde se recibe un bit a la vez desde la entrada `i_rxmodule_RX` y se reconstruye el byte completo. Está estructurado como una máquina de estados finitos (FSM), que cambia de estado a medida que avanza el proceso de recepción de un byte.


**Parámetros:**
  - `NB_RXMODULE_DATA = 8`: Define el número de bits de datos que se van a recibir (en este caso, 8 bits).
  - `SB_RXMODULE_TICKS = 16`: Define la cantidad de ticks que debe durar el bit de stop. Como se utiliza un solo bit de stop, la cantidad de tick es solamente 16.


**Entradas:**
  - `i_clk`: Señal de reloj del sistema.
  - `i_reset`: Señal de reinicio que restablece los registros y estados del módulo(a estado idle/inactivo).
  - `i_rxmodule_RX`: Señal de recepción de datos en serie (UART RX).
  - `i_rxmodule_BRGTICKS`: Señal de los "baud rate generator ticks", recibe un 1 cuando se ha completado un tick desde el generador del baud rate.


**Salidas:**
  - `o_rxmodule_RXDONE`: Señal que indica cuando se ha recibido un byte completo.
  - `o_rxmodule_DOUT`: El byte recibido en paralelo.


/////////////////////// Ver si se modifica a One hot o One Cold (o a Gray??)

**Estados:**
El módulo usa una máquina de estados con los siguientes estados:
  - `rxmodule_idlestate` **(00)**: Estado de espera, esperando el bit de inicio de la trama (que es un 0 en UART).
  - `rxmodule_startstate` **(01)**: Estado que verifica la duración del bit de inicio.
  - `rxmodule_datastate` **(10)**: Estado de lectura de los bits de datos.
  - `rxmodule_stopstate` **(11)**: Estado que verifica el bit de stop (un solo bit de stop).


/////////////////////////////// Modificar bits de estado?????

**Registros:**
  - `rxmodule_regstate` y `rxmodule_nextstate`: Mantienen el estado actual y el próximo estado de la máquina de estados. Esto a traves de los dos bits que identifican a cada uno de los 4 estados. 
  - `rxmodule_samptickreg` y `rxmodule_sampticknextreg`: Contadores de ticks para medir el tiempo de cada bit.
  - `rxmodule_nbrecreg` y `rxmodule_nbrecnextreg`: Contador de bits recibidos.
  - `rxmodule_bitsreasreg` y `rxmodule_bitsreasnextreg`: Almacenan los bits recibidos y los van desplazando para reconstruir el byte (ya que los bits llegan de a uno). Es decir, ahi observamos cuales son los bits actuales que fueron llegando. Para hacer el desplazamiento se realiza lo siguiente:
    - Toma el valor actual de la entrada `i_rxmodule_RX`, que es el bit de datos que está llegando en el momento.
    - Toma el valor actual del registro `rxmodule_bitsreasreg` (que contiene los bits ya recibidos hasta ahora) y lo desplaza hacia la derecha una posición, descartando el bit menos significativo ([7:1] significa que se toman los bits del 7 al 1, excluyendo el bit 0).
    - Coloca el nuevo bit recibido (`i_rxmodule_RX`) en el bit más significativo de `rxmodule_bitsreasnextreg`.
  

**Funcionamiento:**
  - **Estado `rxmodule_idlestate`**: El módulo permanece en este estado hasta que se detecta un 0 en `i_rxmodule_RX`, lo que indica el bit de inicio de una trama UART. Si se detecta un 0, pasa al estado `rxmodule_startstate`.
  - **Estado `rxmodule_startstate`**: Este estado espera que el contador de ticks llegue a 7 (para sincronizarse con el centro del bit de inicio/start (que es un 0)). Una vez alcanzado el tick 7 (es decir, pasaron 8 ticks), pasa al estado `rxmodule_datastate` para empezar a recibir los bits de datos.
  - **Estado `rxmodule_datastate`**: Este estado espera que el contador de ticks llegue a 15 (16 ticks) (para sincronizarse con el centro del primer data bit, y de los demas), y luego lee los bits de datos uno por uno en los bordes de `i_rxmodule_BRGTICKS`. Se construye el byte desplazando los bits hacia la derecha (`rxmodule_bitsreasnextreg = {i_rxmodule_RX, rxmodule_bitsreasreg[7:1]}`) y se incrementa el contador de bits `rxmodule_nbrecreg`. Una vez recibidos todos los bits (`NB_RXMODULE_DATA`) (8 bits), pasa al estado `rxmodule_stopstate`.
  **- Estado `rxmodule_stopstate`**: Este estado verifica que se ha recibido correctamente el bit de stop (que debería ser un 1). Cuando se completa el bit de stop (después de `SB_RXMODULE_TICKS` ticks (en este caso, son 16 ticks)), el módulo vuelve al estado `rxmodule_idlestate` y activa `o_rxmodule_RXDONE` para indicar que se ha recibido un byte completo.


**Salida de Datos:**
  - La salida `o_rxmodule_DOUT` contiene el byte completo que ha sido recibido en serie.
  - La señal `o_rxmodule_RXDONE` indica que la recepción ha terminado.


**Resumen:**
Este módulo implementa la recepción de datos en serie (UART) mediante una máquina de estados que detecta el bit de inicio, lee los bits de datos y finaliza con el bit de stop. Los datos recibidos se almacenan en `o_rxmodule_DOUT`, y una señal `o_rxmodule_RXDONE` indica cuando se ha recibido un byte completo.

### FIFO
Este módulo fifo_module es una implementación de una FIFO (First In, First Out) en Verilog, la cual gestiona el almacenamiento y acceso secuencial de datos. La FIFO es utilizada para almacenar temporalmente datos entre la escritura y la lectura, permitiendo que los datos se lean en el mismo orden en que se escribieron.

**Parámetros:**
- NB_FIFOMODULE_DATA: Tamaño de las palabras que se almacenan en la FIFO, es decir, el número de bits por dato.
- NB_FIFOMODULE_ADDR: Cantidad de bits en las direcciones, define el tamaño de la FIFO. Por ejemplo, con 4 bits de dirección, se puede tener hasta 2^4=16 posiciones.

**Entradas y salidas:**
Entradas:  
- i_clk: Señal de reloj.
- i_reset: Señal de reset para inicializar la FIFO.
- i_fifomodule_READ: Señal para indicar una operación de lectura.
- i_fifomodule_WRITE: Señal para indicar una operación de escritura.
- i_fifomodule_WRITEDATA: El dato que se escribe en la FIFO.
Salidas:  
- o_fifomodule_READATA: El dato leído de la FIFO.
- o_fifomodule_EMPTY: Indica si la FIFO está vacía.
- o_fifomodule_FULL: Indica si la FIFO está llena.
  
**Señales internas:**
- fifomodule_arrayreg: Es el registro donde se almacenan los datos. Tiene un tamaño de 2^(NB_FIFOMODULE_ADDR) palabras de NB_FIFOMODULE_DATA bits.
- fifomodule_writeptrreg y fifomodule_readptrreg: Son los punteros de escritura y lectura. Se utilizan para rastrear las posiciones de escritura y lectura dentro de la FIFO.
- fifomodule_fullreg y fifomodule_emptyreg: Bandera para indicar si la FIFO está llena o vacía.
**Funcionalidad del módulo:**
1. Escritura en la FIFO:
La operación de escritura solo ocurre si la FIFO no está llena, controlada por la señal fifomodule_writeenablewire, que es el resultado de la operación i_fifomodule_WRITE & (~fifomodule_fullreg). Si la FIFO no está llena y se recibe una señal de escritura (i_fifomodule_WRITE), el dato de i_fifomodule_WRITEDATA se almacena en la posición señalada por el puntero de escritura fifomodule_writeptrreg.
2. Lectura desde la FIFO:
El dato que se lee de la FIFO se encuentra en la posición indicada por el puntero de lectura fifomodule_readptrreg. Este dato se asigna a o_fifomodule_READATA.
La lectura solo ocurre si la FIFO no está vacía, y el puntero de lectura se incrementa después de cada operación de lectura.
3. Lógica de control:
Los punteros de escritura y lectura (fifomodule_writeptrreg y fifomodule_readptrreg) son actualizados en cada ciclo de reloj en función de las señales de lectura (i_fifomodule_READ) y escritura (i_fifomodule_WRITE).
Cada puntero se incrementa por separado utilizando las variables fifomodule_succwriteptrreg (para escritura) y fifomodule_succreadptrreg (para lectura), las cuales calculan la siguiente posición para las operaciones de lectura y escritura.
**Condiciones de FIFO llena o vacía:**
La FIFO se considera llena cuando el siguiente puntero de escritura coincide con el puntero de lectura (fifomodule_succwriteptrreg == fifomodule_readptrreg).
La FIFO se considera vacía cuando el siguiente puntero de lectura coincide con el puntero de escritura (fifomodule_succreadptrreg == fifomodule_writeptrreg).
4. Máquina de estados combinacional:
La lógica combinacional que se encuentra dentro de always @(*) evalúa el siguiente estado en función de las señales de escritura y lectura.
Si solo se realiza una operación de lectura (2'b01), se incrementa el puntero de lectura y se ajustan las banderas de vacío y lleno.
Si solo se realiza una operación de escritura (2'b10), se incrementa el puntero de escritura y se ajustan las banderas de vacío y lleno.
Si se realizan ambas operaciones simultáneamente (2'b11), se incrementan ambos punteros de lectura y escritura.
5. Banderas de estado:
- o_fifomodule_EMPTY: Indica si la FIFO está vacía, basada en el registro fifomodule_emptyreg.
- o_fifomodule_FULL: Indica si la FIFO está llena, basada en el registro fifomodule_fullreg.
**Comportamiento general:**
Cuando se escribe un dato en la FIFO (si no está llena), el puntero de escritura avanza y la FIFO se llena progresivamente.
Cuando se lee un dato (si no está vacía), el puntero de lectura avanza y los datos se extraen en el mismo orden en el que fueron insertados (primero en entrar, primero en salir).
La FIFO utiliza las banderas full y empty para gestionar adecuadamente las condiciones límite, asegurando que no se escriban datos si está llena y no se lean datos si está vacía.