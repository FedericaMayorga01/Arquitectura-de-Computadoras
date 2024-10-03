`timescale 1ns / 1ps

module interface_module
#(
    parameter NB_INTERFACEMODULE_DATA = 8,          // Data bits
    parameter NB_INTERFACEMODULE_OP   = 6           // Operation bits
)
(
    input   wire i_clk, i_reset,                                        // Clk y reset
    input   wire i_fifo_read,                                           // Señal para leer de la FIFO
    input   wire i_fifo_empty,                                          // Indica si la FIFO está vacía
    input   wire [NB_INTERFACEMODULE_DATA - 1:0] i_fifo_data,           // Datos leídos desde la FIFO
    input   wire signed [NB_INTERFACEMODULE_DATA - 1:0] i_alu_result,   // Resultado de la ALU

    output  reg o_fifo_read,                                            // Señal para iniciar lectura de FIFO
    output  wire signed [NB_INTERFACEMODULE_DATA - 1:0] o_alu_data_A,   // Dato A para la ALU
    output  wire signed [NB_INTERFACEMODULE_DATA - 1:0] o_alu_data_B,   // Dato B para la ALU
    output  wire [NB_INTERFACEMODULE_OP - 1:0] o_alu_OP                 // Operando para la ALU
);

// symbolic state declaration
localparam [1:0]
    interfacemodule_idlestate  = 2'b00,
    interfacemodule_dataAstate = 2'b01,
    interfacemodule_dataBstate = 2'b10,
    interfacemodule_opstate    = 2'b11;

// signal declaration
reg [1:0] state_reg, state_next;            // Estado actual y siguiente
reg [NB_INTERFACEMODULE_DATA - 1:0] data_A_reg, data_B_reg;   // Registros para los datos A y B
reg [NB_INTERFACEMODULE_OP - 1 :0] op_reg;                     // Registro para el operando de la ALU

// body
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
    state_next  = state_reg;
    o_fifo_read = 1'b0;         // Por defecto no lee de la FIFO

    case (state_reg)
        interfacemodule_idlestate:
            if (!i_fifo_empty && i_fifo_read) 
                begin
                    o_fifo_read = 1'b1;                         // Iniciar lectura de FIFO
                    state_next = interfacemodule_dataAstate;    // Cambiar al estado para leer el dato A
                end

        interfacemodule_dataAstate:
            begin
                o_fifo_read = 1'b1;                             // Leer valor de la FIFO
                state_next = interfacemodule_dataBstate;        // Cambiar al estado para leer el dato B
            end

        interfacemodule_dataBstate:
            begin
                o_fifo_read = 1'b1;                             // Leer valor de la FIFO
                state_next = interfacemodule_opstate;           // Cambiar al estado para leer el operando
            end

        interfacemodule_opstate:
            begin
                o_fifo_read = 1'b1;                             // Leer el operando de la FIFO
                state_next = interfacemodule_idlestate;         // Regresar al estado idle
            end
    endcase
end

// Store the FIFO values in the registers
always @(posedge i_clk, posedge i_reset)
begin
    if (i_reset)
        begin
            data_A_reg <= 0;
            data_B_reg <= 0;
            op_reg     <= 0;
        end
    else
        begin
            if (state_reg == interfacemodule_dataAstate)
                data_A_reg <= i_fifo_data;
            else if (state_reg == interfacemodule_dataBstate)
                data_B_reg <= i_fifo_data;
            else if (state_reg == interfacemodule_opstate)
                op_reg <= i_fifo_data[NB_INTERFACEMODULE_OP - 1:0];               // Solo se toman los bits necesarios para el operando
        end
end

// output
assign o_alu_data_A = data_A_reg;
assign o_alu_data_B = data_B_reg;
assign o_alu_OP     = op_reg;

endmodule
