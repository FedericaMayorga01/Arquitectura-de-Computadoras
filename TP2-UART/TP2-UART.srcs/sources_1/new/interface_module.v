`timescale 1ns / 1ps

module interface_module
#(
    parameter NB_INTERFACEMODULE_DATA = 8,          // Data bits
    parameter NB_INTERFACEMODULE_OP   = 6           // Operation bits
)
(
    input   wire i_clk, i_reset,                                            // Clk y reset
    input   wire i_interfacemodule_read,                                    // Señal para leer de la FIFO
    input   wire i_interfacemodule_empty,                                   // Indica si la FIFO está vacía
    input   wire i_interfacemodule_full,                                    // Indica si la FIFO está llena
    input   wire [NB_INTERFACEMODULE_DATA - 1:0] i_interfacemodule_data,    // Datos leídos desde la FIFO
    input   wire signed [NB_INTERFACEMODULE_DATA - 1:0] i_alu_result,       // Resultado de la ALU

    output  reg o_interfacemodule_readdata,                                             // Señal para iniciar lectura de FIFO
    output  reg o_interfacemodule_write,                                                // Señal para escribir la FIFO
    output  reg  signed [NB_INTERFACEMODULE_DATA - 1:0] o_interfacemodule_writedata,    // Byte enviado
    output  wire signed [NB_INTERFACEMODULE_DATA - 1:0] o_alu_data_A,                   // Dato A para la ALU
    output  wire signed [NB_INTERFACEMODULE_DATA - 1:0] o_alu_data_B,                   // Dato B para la ALU
    output  wire [NB_INTERFACEMODULE_OP - 1:0] o_alu_OP,                                // Operando para la ALU
    output  reg signed [NB_INTERFACEMODULE_DATA - 1:0] o_result_data                    // Resultado de la ALU procesado
);

// symbolic state declaration
localparam [2:0]
    interfacemodule_idlestate   = 3'b000,
    interfacemodule_dataAstate  = 3'b001,
    interfacemodule_dataBstate  = 3'b010,
    interfacemodule_opstate     = 3'b011,
    interfacemodule_resultstate = 3'b100;    // Nuevo estado para manejar el resultado de la ALU

// signal declaration
reg [2:0] state_reg, state_next;                                // Estado actual y siguiente
reg [NB_INTERFACEMODULE_DATA - 1:0] data_A_reg, data_B_reg;     // Registros para los datos A y B
reg [NB_INTERFACEMODULE_OP - 1 :0] op_reg;                      // Registro para el operando de la ALU

// FSMD state & interface_module registers
always @(posedge i_clk, posedge i_reset)
    begin
        if (i_reset)
            state_reg <= interfacemodule_idlestate;
        else
            state_reg <= state_next;
    end

// FSMD next-state logic
always @(*)
begin
    state_next                 = state_reg;
    o_interfacemodule_readdata = 1'b0;          // Por defecto no lee de la FIFO Rx
    o_interfacemodule_write    = 1'b0;          // Por defecto no escribe en la FIFO Tx

    case (state_reg)
        interfacemodule_idlestate:
            if (!i_interfacemodule_empty && i_interfacemodule_read) 
                begin
                    o_interfacemodule_readdata = 1'b1;          // Iniciar lectura de FIFO
                    state_next = interfacemodule_dataAstate;    // Cambiar al estado para leer el dato A
                end

        interfacemodule_dataAstate:
            begin
                o_interfacemodule_readdata = 1'b1;              // Leer valor de la FIFO
                state_next = interfacemodule_dataBstate;        // Cambiar al estado para leer el dato B
            end

        interfacemodule_dataBstate:
            begin
                o_interfacemodule_readdata = 1'b1;              // Leer valor de la FIFO
                state_next = interfacemodule_opstate;           // Cambiar al estado para leer el operando
            end

        interfacemodule_opstate:
            begin
                o_interfacemodule_readdata = 1'b1;               // Leer el operando de la FIFO
                state_next = interfacemodule_resultstate;        // Cambiar al estado de resultado
            end

        interfacemodule_resultstate:                                        // Nuevo estado para manejar el resultado
            begin
                o_result_data = i_alu_result;                              // Guardar el resultado de la ALU
                if (!i_interfacemodule_full)                               // Solo escribe si la FIFO Tx no está llena
                    state_next = interfacemodule_writestate;               // Cambiar al estado para escribir en la FIFO Tx
                else
                    state_next = interfacemodule_resultstate;              // Mantenerse en el estado de resultado si la FIFO Tx está llena
            end

        interfacemodule_writestate:                                        // Estado para escribir en la FIFO Tx
            begin
                o_interfacemodule_write = 1'b1;                            // Señal para escribir en la FIFO
                o_interfacemodule_writedata = o_result_data;               // Escribir el resultado en la FIFO Tx
                state_next = interfacemodule_idlestate;                    // Regresar al estado idle
            end
    endcase
end

// Store the FIFO values in the registers
always @(posedge i_clk, posedge i_reset)
begin
    if (i_reset)
        begin
            data_A_reg    <= 0;
            data_B_reg    <= 0;
            op_reg        <= 0;
            o_result_data <= 0;      // Reset del registro del resultado
        end
    else
        begin
            if (state_reg == interfacemodule_dataAstate)
                data_A_reg <= i_interfacemodule_data;
            else if (state_reg == interfacemodule_dataBstate)
                data_B_reg <= i_interfacemodule_data;
            else if (state_reg == interfacemodule_opstate)
                op_reg <= i_interfacemodule_data[NB_INTERFACEMODULE_OP - 1:0]; // Solo se toman los bits necesarios para el operando
        end
end

// output
assign o_alu_data_A = data_A_reg;
assign o_alu_data_B = data_B_reg;
assign o_alu_OP     = op_reg;

endmodule