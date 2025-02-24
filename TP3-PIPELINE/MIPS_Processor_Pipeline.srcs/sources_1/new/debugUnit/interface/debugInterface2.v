module debugInterface
#(
    parameter UART_DATA_LEN = 8,    // Longitud de datos UART (estándar: 8 bits)
    parameter CPU_DATA_LEN  = 32,   // Longitud de datos de la CPU (32 bits)
    parameter REGISTER_BITS = 5,    // Número de bits para direccionar registros
    parameter PC_LEN        = 32    // Longitud del contador de programa
)
(
    input wire i_clk,               // Señal de reloj del sistema

    //Señales desde la UART
    input wire i_txFull,                          // Indica que el buffer de transmisión está lleno
    input wire i_rxEmpty,                         // Indica que el buffer de recepción está vacío
    input wire [UART_DATA_LEN-1:0] i_dataToRead,  // Datos recibidos desde UART

    //Señales desde la CPU
    input wire [CPU_DATA_LEN-1:0] i_regMemValue,  // Valor de registro/memoria leído desde CPU
    input wire i_halt,                            // Indica que la CPU está detenida
    input wire [PC_LEN-1:0] i_programCounter,     // Valor actual del contador de programa

    //Señales hacia la UART
    output wire o_readUart,                        // Indica lectura de un byte desde la UART
    output wire o_writeUart,                       // Indica escritura de un byte hacia la UART
    output wire [UART_DATA_LEN-1:0] o_dataToWrite, // Datos a transmitir por UART

    //Señales hacia la CPU
    output wire o_enable,                                   // Habilita la ejecución de la CPU
    output wire o_writeInstruction,                         // Habilita escritura de instrucción
    output wire [CPU_DATA_LEN-1:0] o_instructionToWrite,    // Instrucción a escribir en memoria
    output wire [REGISTER_BITS-1:0] o_regMemAddress,        // Dirección de registro/memoria
    output wire o_regMemCtrl,                               // Control para seleccionar entre registro (0) o memoria (1)
    output wire o_reset                                     // Señal de reset para la CPU
);

// Definición de estados de la máquina de estados finitos (FSM)
localparam [4:0] IDLE              = 5'b00000;  // Estado de reposo
localparam [4:0] DECODE            = 5'b00001;  // Decodificar comando recibido
localparam [4:0] FETCH_INSTRUCTION = 5'b00010;  // Obtener bytes de instrucción
localparam [4:0] WRITE_INSTRUCTION = 5'b00011;  // Escribir instrucción a memoria
localparam [4:0] STEP              = 5'b00100;  // Ejecutar un paso
localparam [4:0] RUN               = 5'b00101;  // Ejecutar hasta detención
localparam [4:0] PREPARE_SEND      = 5'b00110;  // Preparar envío de datos
localparam [4:0] SEND_VALUES       = 5'b00111;  // Enviar valores de registros
localparam [4:0] SEND_PC           = 5'b01000;  // Enviar valor del contador de programa
localparam [4:0] FINISH_SEND       = 5'b01001;  // Finalizar envío
localparam [4:0] RESET             = 5'b01010;  // Resetear CPU
// Estados de espera específicos
localparam [4:0] WAIT_RX_DECODE    = 5'b01011;  // Esperar datos para decodificación
localparam [4:0] WAIT_RX_FETCH     = 5'b01100;  // Esperar bytes de instrucción
localparam [4:0] WAIT_TX_PREPARE   = 5'b01101;  // Esperar disponibilidad TX en preparación
localparam [4:0] WAIT_TX_SEND      = 5'b01110;  // Esperar disponibilidad TX en envío de valores
localparam [4:0] WAIT_TX_PC        = 5'b01111;  // Esperar disponibilidad TX en envío de PC
localparam [4:0] WAIT_TX_FINISH    = 5'b10000;  // Esperar disponibilidad TX en finalización

// Códigos de comando recibidos por UART
localparam [UART_DATA_LEN-1:0] PROGRAM_CODE = 8'h23;  // Comando para programar instrucción
localparam [UART_DATA_LEN-1:0] STEP_CODE    = 8'h12;  // Comando para ejecutar un paso
localparam [UART_DATA_LEN-1:0] RUN_CODE     = 8'h54;  // Comando para ejecutar programa
localparam [UART_DATA_LEN-1:0] RESET_CODE   = 8'h69;  // Comando para resetear CPU

// Registros de estado de la FSM
reg [4:0] r_state, r_stateNext;     // Estado actual y próximo estado

// Registros para señales de control
reg r_readUart;                     // Control de lectura UART
reg r_writeUart;                    // Control de escritura UART
reg [UART_DATA_LEN-1:0] r_dataToWrite, r_dataToWriteNext;  // Datos a escribir por UART

reg r_enable;                       // Control de habilitación de CPU
reg r_writeInstruction;             // Control de escritura de instrucción
reg [CPU_DATA_LEN-1:0] r_instructionToWrite, r_instructionToWriteNext;  // Instrucción a escribir

// Registros auxiliares
reg [1:0] r_byteCounter, r_byteCounterNext;         // Contador de bytes procesados
reg [5:0] r_regMemAddress, r_regMemAddressNext;     // Dirección de registro/memoria (bit extra para control)

reg r_reset;                        // Señal de reset para CPU

// Inicialización
initial begin
    r_state = IDLE;                 // Comenzar en estado IDLE
end

// Registro de estados y datos en flanco positivo del reloj
always @(posedge i_clk) begin
    r_state <= r_stateNext;
    r_byteCounter <= r_byteCounterNext;
    r_regMemAddress <= r_regMemAddressNext;
    r_dataToWrite <= r_dataToWriteNext;
    r_instructionToWrite <= r_instructionToWriteNext;
end

// Lógica de próximo estado
always @(*) begin
    // Valores por defecto: mantener estado actual
    r_stateNext = r_state;
    r_byteCounterNext = r_byteCounter;
    r_regMemAddressNext = r_regMemAddress;
    r_dataToWriteNext = r_dataToWrite;
    r_instructionToWriteNext = r_instructionToWrite;

    case (r_state)
        // Estado IDLE: esperar comandos
        IDLE: begin
            r_byteCounterNext = 2'b00;  // Reiniciar contador de bytes

            if(~i_rxEmpty)              // Si hay datos disponibles en UART
                r_stateNext = DECODE;   // Pasar a decodificar comando
        end

        // Estado DECODE: interpretar comando recibido
        DECODE: begin
            r_instructionToWriteNext = {CPU_DATA_LEN{1'b0}};  // Limpiar registro de instrucción

            if(i_rxEmpty) begin         // Si no hay más datos disponibles
                r_stateNext = WAIT_RX_DECODE;  // Esperar más datos
            end
            else begin                  // Procesar comando recibido
                if(i_dataToRead == PROGRAM_CODE) begin
                    r_stateNext = FETCH_INSTRUCTION;  // Comando para programar
                end
                else if(i_dataToRead == STEP_CODE) begin
                    r_stateNext = STEP;  // Comando para dar un paso
                end
                else if(i_dataToRead == RUN_CODE) begin
                    r_stateNext = RUN;   // Comando para ejecutar continuamente
                end
                else if(i_dataToRead == RESET_CODE) begin
                    r_stateNext = RESET; // Comando para resetear CPU
                end
                else begin
                    r_stateNext = IDLE;  // Comando no reconocido, volver a IDLE
                end
            end
        end

        // Estado de espera para recepción en DECODE
        WAIT_RX_DECODE: begin
            // Este estado espera hasta que haya datos disponibles
            if(~i_rxEmpty)              // Cuando hay datos disponibles
                r_stateNext = DECODE;   // Volver a decodificar
        end

        // Estado FETCH_INSTRUCTION: recibir bytes de instrucción
        FETCH_INSTRUCTION: begin
            if(i_rxEmpty) begin         // Si no hay más datos disponibles
                r_stateNext = WAIT_RX_FETCH;  // Esperar más bytes
            end
            else begin
                // Colocar el byte recibido en la posición correcta de la instrucción
                r_instructionToWriteNext = r_instructionToWrite | ({{24{1'b0}},i_dataToRead} << (r_byteCounter * 8));

                if(r_byteCounter == 2'b11) begin  // Si recibimos el último byte (4 en total)
                    r_byteCounterNext = 2'b00;    // Reiniciar contador
                    r_stateNext = WRITE_INSTRUCTION;  // Escribir instrucción completa
                end else begin
                    r_byteCounterNext = r_byteCounter + 1;  // Incrementar contador
                    r_stateNext = FETCH_INSTRUCTION;        // Seguir recibiendo bytes
                end
            end
        end

        // Estado de espera para recepción en FETCH
        WAIT_RX_FETCH: begin
            // Este estado espera hasta que haya datos disponibles
            if(~i_rxEmpty)                  // Cuando hay datos disponibles
                r_stateNext = FETCH_INSTRUCTION;  // Volver a recibir bytes
        end

        // Estado WRITE_INSTRUCTION: escribir instrucción en memoria
        WRITE_INSTRUCTION: begin
            r_stateNext = IDLE;  // Volver a IDLE después de escribir
        end

        // Estado STEP: ejecutar un solo paso
        STEP: begin
            if(i_halt)                  // Si la CPU está detenida
                r_stateNext = IDLE;     // Volver a IDLE
            else
                r_stateNext = PREPARE_SEND;  // Preparar envío de datos de estado
        end

        // Estado RUN: ejecutar continuamente
        RUN: begin
            if(i_halt) begin            // Si la CPU está detenida
                r_stateNext = PREPARE_SEND;  // Preparar envío de datos de estado
            end
            // Si no, permanece en RUN
        end

        // Estado PREPARE_SEND: iniciar envío de datos
        PREPARE_SEND: begin
            if(i_txFull) begin          // Si buffer TX está lleno
                r_stateNext = WAIT_TX_PREPARE;  // Esperar espacio disponible
            end else begin
                // Preparar primer byte (LSB) del valor actual
                r_dataToWriteNext = i_regMemValue & 32'h000000ff;
                r_byteCounterNext = 2'b01;  // Comenzar desde el siguiente byte
                r_stateNext = SEND_VALUES;   // Ir a enviar valores
            end
        end

        // Estado de espera para transmisión en PREPARE_SEND
        WAIT_TX_PREPARE: begin
            // Este estado espera hasta que haya espacio en buffer TX
            if(~i_txFull)                   // Cuando hay espacio disponible
                r_stateNext = PREPARE_SEND;  // Volver a preparar envío
        end

        // Estado SEND_VALUES: enviar valores de registros
        SEND_VALUES: begin 
            if(i_txFull) begin          // Si buffer TX está lleno
                r_stateNext = WAIT_TX_SEND;  // Esperar espacio disponible
            end
            else begin
                // Preparar siguiente byte del valor actual
                r_dataToWriteNext = (i_regMemValue >> (r_byteCounter*8)) & 32'h000000ff;

                if(r_byteCounter == 2'b11) begin  // Si es el último byte (4 en total)
                    r_regMemAddressNext = r_regMemAddress + 1;  // Siguiente registro
                    r_byteCounterNext = 2'b00;                  // Reiniciar contador

                    if(r_regMemAddress == 6'b111111)  // Si completamos todos los registros
                       r_stateNext = SEND_PC;         // Enviar valor del PC
                    else
                       r_stateNext = SEND_VALUES;     // Seguir con siguiente registro
                end
                else begin
                    r_byteCounterNext = r_byteCounter + 1;  // Incrementar contador
                    r_stateNext = SEND_VALUES;              // Seguir enviando bytes
                end
            end
        end

        // Estado de espera para transmisión en SEND_VALUES
        WAIT_TX_SEND: begin
            // Este estado espera hasta que haya espacio en buffer TX
            if(~i_txFull)                   // Cuando hay espacio disponible
                r_stateNext = SEND_VALUES;  // Volver a enviar valores
        end

        // Estado SEND_PC: enviar valor del contador de programa
        SEND_PC: begin
            if(i_txFull) begin          // Si buffer TX está lleno
                r_stateNext = WAIT_TX_PC;  // Esperar espacio disponible
            end
            else begin
                // Preparar byte del PC
                r_dataToWriteNext = (i_programCounter >> (r_byteCounter*8)) & 32'h000000ff;

                if(r_byteCounter == 2'b11) begin  // Si es el último byte del PC
                    r_byteCounterNext = 2'b00;    // Reiniciar contador
                    r_stateNext = FINISH_SEND;    // Finalizar envío
                end
                else begin
                    r_byteCounterNext = r_byteCounter + 1;  // Incrementar contador
                    r_stateNext = SEND_PC;                  // Seguir enviando PC
            end
        end
        end

        // Estado de espera para transmisión en SEND_PC
        WAIT_TX_PC: begin
            // Este estado espera hasta que haya espacio en buffer TX
            if(~i_txFull)               // Cuando hay espacio disponible
                r_stateNext = SEND_PC;  // Volver a enviar PC
        end

        // Estado FINISH_SEND: completar secuencia de envío
        FINISH_SEND: begin
            if(i_txFull) begin          // Si buffer TX está lleno
                r_stateNext = WAIT_TX_FINISH;  // Esperar espacio disponible
            end
            else begin
                if(r_byteCounter == 2'b01) begin  // Enviar marcador de finalización
                    r_stateNext = IDLE;           // Volver a IDLE
                end
                else begin
                    r_byteCounterNext = r_byteCounter + 1;  // Incrementar contador
                    r_stateNext = FINISH_SEND;             // Continuar finalizando
            end
        end
        end

        // Estado de espera para transmisión en FINISH_SEND
        WAIT_TX_FINISH: begin
            // Este estado espera hasta que haya espacio en buffer TX
            if(~i_txFull)                  // Cuando hay espacio disponible
                r_stateNext = FINISH_SEND;  // Volver a finalizar envío
        end

        // Estado RESET: resetear la CPU
        RESET: begin
            r_stateNext = IDLE;  // Volver a IDLE después de resetear
        end

        // Estado por defecto (no debería ocurrir)
        default: begin
            r_instructionToWriteNext = {CPU_DATA_LEN{1'b0}};  // Limpiar instrucción
            r_dataToWriteNext = 0;                           // Limpiar datos
            r_byteCounterNext = 2'b00;                       // Reiniciar contador    
        end
    endcase
end

// Lógica de salida
always @(*) begin
    // Valores por defecto: todas las señales inactivas
    r_writeUart = 1'b0;
    r_writeInstruction = 1'b0;
    r_readUart = 1'b0;
    r_enable = 1'b0;
    r_reset = 1'b0;

    case (r_state)
        // Activar señales específicas según el estado
        IDLE: begin
            // No se activan señales en estado IDLE
        end

        DECODE: begin
            r_readUart = 1'b1;       // Habilitar lectura de UART
        end

        WAIT_RX_DECODE: begin
            // No se activan señales en este estado de espera
        end

        FETCH_INSTRUCTION: begin
            r_readUart = 1'b1;       // Habilitar lectura de UART
        end

        WAIT_RX_FETCH: begin
            // No se activan señales en este estado de espera
        end

        WRITE_INSTRUCTION: begin
            r_writeInstruction = 1'b1;  // Habilitar escritura de instrucción
        end

        STEP: begin
            r_enable = 1'b1;         // Habilitar CPU para un paso
        end

        RUN: begin
            r_enable = 1'b1;         // Habilitar CPU para ejecución continua
        end

        PREPARE_SEND: begin
            // No se activan señales en este estado
        end

        WAIT_TX_PREPARE: begin
            // No se activan señales en este estado de espera
        end

        SEND_VALUES: begin
            r_writeUart = 1'b1;      // Habilitar escritura a UART
        end

        WAIT_TX_SEND: begin
            // No se activan señales en este estado de espera
        end

        SEND_PC: begin
            r_writeUart = 1'b1;      // Habilitar escritura a UART
        end

        WAIT_TX_PC: begin
            // No se activan señales en este estado de espera
        end

        FINISH_SEND: begin
            r_writeUart = 1'b1;      // Habilitar escritura a UART
        end

        WAIT_TX_FINISH: begin
            // No se activan señales en este estado de espera
        end

        RESET: begin
            r_reset = 1'b1;          // Activar señal de reset
        end

        default: begin
            // No se activan señales en el caso por defecto
        end
    endcase
end

// Conexiones de salida
assign o_instructionToWrite = r_instructionToWrite;
assign o_enable = r_enable;
assign o_writeInstruction = r_writeInstruction;
assign o_regMemAddress = r_regMemAddress[4:0];  // 5 bits para dirección
assign o_regMemCtrl = r_regMemAddress[5];       // Bit 5 para selección reg/mem

assign o_readUart = r_readUart;
assign o_writeUart = r_writeUart;
assign o_dataToWrite = r_dataToWrite;
assign o_reset = r_reset;

endmodule
