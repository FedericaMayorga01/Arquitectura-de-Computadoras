# Trabajo Practico #2 - UART
<p align="center">
    <img src=".\imgs\image_tp2.webp"><br>
</p>

## Objetivo
El objetivo es implementar un módulo transmisor-receptor del tipo UART en una FPGA. Para lograrlo, se desarrollarán módulos auxiliares como un generador de velocidad en baudios (Baud Rate Generator), interfaces y demas. El módulo UART desempeña un papel fundamental, su función consiste en tomar bytes de datos y transmitir los bits individualmente de forma secuencial. En el extremo receptor, otro UART reensambla los bits en bytes completos.


### Componentes
Consta de cinco modulos principales:
  - **Un generador de velocidad en baudios:** el circuito para generar los ticks de muestreo.
  - **Un receptor UART:** el circuito para obtener la palabra de datos mediante sobremuestreo, con una fifo.
  - **Un tranmisor UART:** el encargado de enviar datos en serie desde la placa hacia la pc, con una fifo.
  - **Un circuito de interfaz:** Contiene una maquina de estados para poder administrar los datos que llegan desde el receptor uart, enviarlos a la alu, recibir el resultado de la alu, y enviarlo al transmisor uart.
  - **Una unidad aritmetica logica:** es la encargada de realizar las operaciones con los datos que recibe, y enviar el resultado de ella.


## Baud Rate Generator
Para una velocidad de 19200 baudios, la frecuencia de muestreo debe ser de 307200 ticks por segundo (es decir, 19200 * 16). Dado que la frecuencia de reloj del sistema es de 50 MHz, el generador de velocidad de baudios necesita un contador mod-163[(50 * 10^6)/(307200) = 162.76], en el que se activa un tick de un ciclo de reloj una vez cada 163 ciclos de reloj.
Se utiliza esta velocidad ya que permite una comunicación más rápida y reduce el tiempo necesario para transmitir grandes cantidades de datos. Ademas reduce la congestión en los buffers.


Este módulo genera un pulso de “tick” a intervalos específicos que determinan la tasa de baudios, esencial para sincronizar la transmisión y recepción de datos en UART.

**Parámetros**
- `NB_BAUDRGMODULE_COUNTER`: ancho del contador en bits.
- `MOD_BAUDRGMODULE_M`: valor máximo al que cuenta el contador antes de reiniciarse (en este caso, 163).


**Funcionalidad**
- Contador (`baudrgmodule_contreg`): aumenta en cada ciclo de reloj (i_clk) hasta alcanzar el valor MOD_BAUDRGMODULE_M-1. Al llegar a este valor, el contador se reinicia.
- `o_baudrgmodule_MAXTICK`: se activa cuando el contador alcanza su valor máximo, generando el “tick” de sincronización.  
Este “tick” se usa para indicar el momento de muestreo en los módulos de recepción y transmisión UART.


## Rx - UART
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


**Estados:**
El módulo usa una máquina de estados con los siguientes estados:
  - `RXM_IDLE_STATE` **(00)**: Estado de espera, esperando el bit de inicio de la trama (que es un 0 en UART).
  - `RXM_START_STATE` **(01)**: Estado que verifica la duración del bit de inicio.
  - `RXM_DATA_STATE` **(10)**: Estado de lectura de los bits de datos.
  - `RXM_STOP_STATE` **(11)**: Estado que verifica el bit de stop (un solo bit de stop).


**Registros:**
  - `rxmodule_regstate` y `rxmodule_nextstate`: Mantienen el estado actual y el próximo estado de la máquina de estados. Esto a traves de los dos bits que identifican a cada uno de los 4 estados. 
  - `rxmodule_samptickreg` y `rxmodule_sampticknextreg`: Contadores de ticks para medir el tiempo de cada bit.
  - `rxmodule_nbrecreg` y `rxmodule_nbrecnextreg`: Contador de bits recibidos.
  - `rxmodule_bitsreasreg` y `rxmodule_bitsreasnextreg`: Almacenan los bits recibidos y los van desplazando para reconstruir el byte (ya que los bits llegan de a uno). Es decir, ahi observamos cuales son los bits actuales que fueron llegando. Para hacer el desplazamiento se realiza lo siguiente:
    - Toma el valor actual de la entrada `i_rxmodule_RX`, que es el bit de datos que está llegando en el momento.
    - Toma el valor actual del registro `rxmodule_bitsreasreg` (que contiene los bits ya recibidos hasta ahora) y lo desplaza hacia la derecha una posición, descartando el bit menos significativo ([7:1] significa que se toman los bits del 7 al 1, excluyendo el bit 0).
    - Coloca el nuevo bit recibido (`i_rxmodule_RX`) en el bit más significativo de `rxmodule_bitsreasnextreg`.
  

**Funcionamiento:**
  - **Estado `RXM_IDLE_STATE`**: El módulo permanece en este estado hasta que se detecta un 0 en `i_rxmodule_RX`, lo que indica el bit de inicio de una trama UART. Si se detecta un 0, pasa al estado `RXM_START_STATE`.
  - **Estado `RXM_START_STATE`**: Este estado espera que el contador de ticks llegue a 7 (para sincronizarse con el centro del bit de inicio/start (que es un 0)). Una vez alcanzado el tick 7 (es decir, pasaron 8 ticks), pasa al estado `RXM_DATA_STATE` para empezar a recibir los bits de datos.
  - **Estado `RXM_DATA_STATE`**: Este estado espera que el contador de ticks llegue a 15 (16 ticks) (para sincronizarse con el centro del primer data bit, y de los demas), y luego lee los bits de datos uno por uno en los bordes de `i_rxmodule_BRGTICKS`. Se construye el byte desplazando los bits hacia la derecha (`rxmodule_bitsreasnextreg = {i_rxmodule_RX, rxmodule_bitsreasreg[7:1]}`) y se incrementa el contador de bits `rxmodule_nbrecreg`. Una vez recibidos todos los bits (`NB_RXMODULE_DATA`) (8 bits), pasa al estado `RXM_STOP_STATE`.
  - **Estado `RXM_STOP_STATE`**: Este estado verifica que se ha recibido correctamente el bit de stop (que debería ser un 1). Cuando se completa el bit de stop (después de `SB_RXMODULE_TICKS` ticks (en este caso, son 16 ticks)), el módulo vuelve al estado `RXM_IDLE_STATE` y activa `o_rxmodule_RXDONE` para indicar que se ha recibido un byte completo.


**Salida de Datos:**
  - La salida `o_rxmodule_DOUT` contiene el byte completo que ha sido recibido en serie.
  - La señal `o_rxmodule_RXDONE` indica que la recepción ha terminado.


**Resumen:**

Este módulo implementa la recepción de datos en serie (UART) mediante una máquina de estados que detecta el bit de inicio, lee los bits de datos y finaliza con el bit de stop. Los datos recibidos se almacenan en `o_rxmodule_DOUT`, y una señal `o_rxmodule_RXDONE` indica cuando se ha recibido un byte completo.


## Tx - UART
Este código implementa un módulo de transmisión en serie (de forma similar al **receptor Rx - UART**), diseñado para enviar datos a través de una línea de transmisión de salida `o_txmodule_TX`. Este módulo recibe un dato de entrada paralelo, el cual se envía bit a bit, comenzando con un bit de inicio y terminando con un bit de parada. Este proceso está dividido en varios estados manejados por una máquina de estados finita (FSM) que controla la secuencia de transmisión.

*(Note que la implementacion de este modulo de transmision será de una estructura muy similar al anterior módulo).*

**Parámetros:**
`NB_TXMODULE_DATA`: Define el tamaño del dato a transmitir en bits, (en este caso, 8 bits por ser de formato byte).
`SB_TXMODULE_TICKS`: Define la cantidad de ticks de reloj necesarios para cada bit de parada.


**Entradas:**
`i_clk` y `i_reset`: De la misma forma, ya presentada anterioremente.
`i_txmodule_TXSTART`: Señal que indica el inicio de la transmisión.
`i_txmodule_BRGTICKS`: De la misma forma, ya presentada anterioremente, sirve para mantener el tiempo de cada bit transmitido.
`i_txmodule_DIN`: Dato paralelo de entrada a ser transmitido.


**Salidas:**
`o_txmodule_TXDONE`: Señal que indica la finalización de la transmisión.
`o_txmodule_TX`: Salida de datos en serie, donde se envían los bits uno a uno.


### Máquina de Estados (FSM)
Los estados son definidos como parámetros locales de 2 bits (`localparam`) y son:
`TXM_IDLE_STATE` **(00)**: Estado inicial en espera de la señal de inicio (`i_txmodule_TXSTART`).
`TXM_START_STATE` **(01)**: Estado que envía el bit de inicio.
`TXM_DATA_STATE` **(10)**: Estado que envía cada bit de datos en secuencia.
`TXM_STOP_STATE` **(11)**: Estado que envía el bit de parada y luego retorna al estado de espera.


**Registros de Estado y Variables de Control**
- `txmodule_statereg` y `txmodule_nextstatereg`: Mantienen y determinan el estado actual y el siguiente de la FSM.
- `txmodule_samptickreg` y `txmodule_nextsamptickreg`: Contadores para sincronizar los bits de datos con los ticks de baud rate.
- `txmodule_nbrecreg` y `txmodule_nextnbrecreg`: Contadores de bits transmitidos.
- `txmodule_bitsreasreg` y `txmodule_nextbitsreasreg`: Registros de desplazamiento que contienen el dato a enviar.
- `txmodule_reg` y `txmodule_nextreg`: Registros que mantienen el bit actual que se está transmitiendo.


En el Bloque Secuencial (*`always @(posedge i_clk)`*) se encuentra que esta controlado por el reloj `i_clk`, este bloque actualiza el estado del módulo y los registros cuando `i_reset` no está activado.

En el Bloque Combinacional (*`always @(*)`*) se calcula el siguiente estado (`txmodule_nextstatereg`) y las actualizaciones de los registros de acuerdo con el estado actual.


### Funcionamiento
1. En `TXM_IDLE_STATE`: La línea de transmisión (o_txmodule_TX) permanece en alto. Si i_txmodule_TXSTART es alta, el estado cambia a TXM_START_STATE para comenzar la transmisión y carga el dato de entrada (i_txmodule_DIN) en txmodule_bitsreasreg.

2. En `TXM_START_STATE`: Se envía un bit de inicio (bajo) en o_txmodule_TX. Se incrementa txmodule_samptickreg con cada tick de baud rate (i_txmodule_BRGTICKS). Una vez que txmodule_samptickreg alcanza 15 ticks, el estado cambia a TXM_DATA_STATE y se reinicia txmodule_samptickreg.

3. En `TXM_DATA_STATE`: Envía los bits de datos uno a uno desde txmodule_bitsreasreg. Con cada tick de baud rate (i_txmodule_BRGTICKS), txmodule_samptickreg se incrementa. Después de 15 ticks, el siguiente bit de txmodule_bitsreasreg se desplaza a o_txmodule_TX. Cuando todos los bits se han transmitido, el estado cambia a TXM_STOP_STATE.

4. En `TXM_STOP_STATE`: Envía un bit de parada (alto) en o_txmodule_TX. Incrementa txmodule_samptickreg en cada tick de baud rate. Cuando txmodule_samptickreg alcanza SB_TXMODULE_TICKS - 1, se genera o_txmodule_TXDONE, indicando que la transmisión ha finalizado, y se retorna a TXM_IDLE_STATE.


**Salida de Datos**
- `o_txmodule_TX` se asigna a `txmodule_reg`, que contiene el bit actual en transmisión.


## FIFO
Este módulo fifo_module es una implementación de una FIFO (First In, First Out) en Verilog, la cual gestiona el almacenamiento y acceso secuencial de datos, entre dos sistemas que trabajan a diferentes velocidades. Es utilizada para almacenar temporalmente datos entre la escritura y la lectura, con base en una maquina de estados, permitiendo que los datos se lean en el mismo orden en que se escribieron.


**Parámetros:**
- `NB_FIFOMODULE_DATA`: Tamaño de las palabras que se almacenan en la FIFO, es decir, el número de bits por dato.
- `NB_FIFOMODULE_ADDR`: Cantidad de bits en las direcciones, define el tamaño de la FIFO. Por ejemplo, con 4 bits de dirección, se puede tener hasta 2^4=16 posiciones.


**Entradas:**
- `i_clk` y `i_reset`: De la misma forma, ya presentada anterioremente.
- `i_fifomodule_READ`:  Señal que indica cuando se debe leer un dato del FIFO.
- `i_fifomodule_WRITE`: Señal que indica cuando se debe escribir un dato en el FIFO.
- `i_fifomodule_WRITEDATA`: El dato que se escribe en la FIFO, cuando se active la señal de escritura.


**Salidas:**
- `o_fifomodule_EMPTY`: Indica si la FIFO está vacía.
- `o_fifomodule_FULL`: Indica si la FIFO está llena.
- `o_fifomodule_READATA`: El dato leído de la FIFO.

  
**Registros de Estado y Variables de Control**
- `fifomodule_arrayreg`: Es el registro donde se almacenan los datos. Tiene un tamaño de 2^(`NB_FIFOMODULE_ADDR`) palabras de `NB_FIFOMODULE_DATA` bits.
- `fifomodule_writeptrreg` y `fifomodule_readptrreg`: Son los punteros de escritura y lectura. Se utilizan para rastrear las posiciones de escritura y lectura dentro de la FIFO.
- `fifomodule_fullreg` y `fifomodule_emptyreg`: Flags para indicar si la FIFO está llena o vacía.


En el Bloque Secuencial (*`always @(posedge i_clk)`*) se implementa de forma similar al `rx_module.v`, ya planteado.


En el Bloque Combinacional (*`always @(*)`*) se evalúa el siguiente estado en función de las señales de escritura y lectura.
- Si solo se realiza una operación de lectura (`2'b01`), se incrementa el puntero de lectura y se ajustan las banderas de `fifomodule_fullreg` y `fifomodule_emptyreg`.
- Si solo se realiza una operación de escritura (`2'b10`), se incrementa el puntero de escritura y se ajustan las banderas de `fifomodule_fullreg` y `fifomodule_emptyreg`.
- Si se realizan ambas operaciones simultáneamente (`2'b11`), se incrementan ambos punteros de lectura y escritura.


**Condiciones de FIFO llena o vacía:**
- El FIFO se considera lleno (fifomodule_fullreg = 1) cuando el puntero de escritura es igual al siguiente puntero de lectura.

- El FIFO se considera vacío (fifomodule_emptyreg = 1) cuando el puntero de lectura alcanza el puntero de escritura.


### Funcionamiento
El módulo FIFO funciona en tres estados principales: lectura, escritura, o ambas (lectura y escritura simultáneas). Los punteros de lectura y escritura permiten gestionar el flujo de datos secuencialmente. Durante una operación de escritura, el dato se almacena en la posición indicada por el puntero de escritura y luego se incrementa dicho puntero. Similarmente, en una operación de lectura, el puntero de lectura se incrementa después de acceder al dato. Las señales de control (`o_fifomodule_FULL` y `o_fifomodule_EMPTY`) se actualizan para reflejar el estado del FIFO, protegiendo el almacenamiento de condiciones de sobreescritura y sublectura.





