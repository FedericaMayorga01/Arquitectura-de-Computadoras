`timescale 1ns / 1ps

module interface_module
#(
    parameter NB_INTERFACEMODULE_DATA = 8,          // Data bits
    parameter NB_INTERFACEMODULE_OP   = 6           // Operation bits
)
(
    input   wire i_clk, i_reset,                                            // Clk y reset
    input   wire i_interfacemodule_EMPTY,                                   // Indica si la FIFO está vacía
    input   wire i_interfacemodule_FULL,                                    // Indica si la FIFO está llena
    input  reg o_interfacemodule_READDATA,                                             // Señal para iniciar lectura de FIFO
    input  reg signed [NB_INTERFACEMODULE_DATA - 1:0] o_interfacemodule_DATARES,                    // Resultado de la ALU procesado
    //input   wire [NB_INTERFACEMODULE_DATA - 1:0] i_interfacemodule_DATA,    // Datos leídos desde la FIFO
    //input   wire signed [NB_INTERFACEMODULE_DATA - 1:0] i_interfacemodule_ALURESULT,       // Resultado de la ALU

    output  wire i_interfacemodule_READ,                                    // Señal para leer de la FIFO
    output  reg o_interfacemodule_WRITE,                                                // Señal para escribir la FIFO
    output  reg  signed [NB_INTERFACEMODULE_DATA - 1:0] o_interfacemodule_WRITEDATA,    // Byte enviado
    output  wire signed [NB_INTERFACEMODULE_DATA - 1:0] o_interfacemodule_DATAA,                   // Dato A para la ALU
    output  wire signed [NB_INTERFACEMODULE_DATA - 1:0] o_interfacemodule_DATAB,                   // Dato B para la ALU
    output  wire [NB_INTERFACEMODULE_OP - 1:0] o_interfacemodule_OP                                // Operando para la ALU
);

// symbolic state declaration
localparam [2:0]
    interfacemodule_idlestate   = 3'b000,
    interfacemodule_dataAstate  = 3'b001,
    interfacemodule_dataBstate  = 3'b010,
    interfacemodule_opstate     = 3'b011,
    interfacemodule_resultstate = 3'b100;    // Nuevo estado para manejar el resultado de la ALU

// signal declaration
reg [2:0] interfacemodule_statereg, interfacemodule_nextstatereg;                                // Estado actual y siguiente
reg [NB_INTERFACEMODULE_DATA - 1:0] interfacemodule_dataAreg, interfacemodule_dataBreg;     // Registros para los datos A y B
reg [NB_INTERFACEMODULE_OP - 1 :0] interfacemodule_opreg;                      // Registro para el operando de la ALU

// FSMD state & interface_module registers
always @(posedge i_clk)
    begin
        if (i_reset)
            interfacemodule_statereg <= interfacemodule_idlestate;
        else
            interfacemodule_statereg <= interfacemodule_nextstatereg;
    end

// FSMD next-state logic
always @(*)
begin
    interfacemodule_nextstatereg                 = interfacemodule_statereg;
    o_interfacemodule_READDATA = 1'b0;          // Por defecto no lee de la FIFO Rx
    o_interfacemodule_WRITE    = 1'b0;          // Por defecto no escribe en la FIFO Tx

    case (interfacemodule_statereg)
        interfacemodule_idlestate:
            if (!i_interfacemodule_EMPTY && i_interfacemodule_READ) 
                begin
                    o_interfacemodule_READDATA = 1'b1;          // Iniciar lectura de FIFO
                    interfacemodule_nextstatereg = interfacemodule_dataAstate;    // Cambiar al estado para leer el dato A
                end

        interfacemodule_dataAstate:
            begin
                o_interfacemodule_READDATA = 1'b1;              // Leer valor de la FIFO
                interfacemodule_nextstatereg = interfacemodule_dataBstate;        // Cambiar al estado para leer el dato B
            end

        interfacemodule_dataBstate:
            begin
                o_interfacemodule_READDATA = 1'b1;              // Leer valor de la FIFO
                interfacemodule_nextstatereg = interfacemodule_opstate;           // Cambiar al estado para leer el operando
            end

        interfacemodule_opstate:
            begin
                o_interfacemodule_READDATA = 1'b1;               // Leer el operando de la FIFO
                interfacemodule_nextstatereg = interfacemodule_resultstate;        // Cambiar al estado de resultado
            end

        interfacemodule_resultstate:                                        // Nuevo estado para manejar el resultado
            begin
                o_interfacemodule_RESULTDATA = i_interfacemodule_ALURESULT;                              // Guardar el resultado de la ALU
                if (!i_interfacemodule_full)                               // Solo escribe si la FIFO Tx no está llena
                    interfacemodule_nextstatereg = interfacemodule_writestate;               // Cambiar al estado para escribir en la FIFO Tx
                else
                    interfacemodule_nextstatereg = interfacemodule_resultstate;              // Mantenerse en el estado de resultado si la FIFO Tx está llena
            end

        interfacemodule_writestate:                                        // Estado para escribir en la FIFO Tx
            begin
                o_interfacemodule_WRITE = 1'b1;                            // Señal para escribir en la FIFO
                o_interfacemodule_WRITEDATA = o_interfacemodule_RESULTDATA;               // Escribir el resultado en la FIFO Tx
                interfacemodule_nextstatereg = interfacemodule_idlestate;                    // Regresar al estado idle
            end
    endcase
end

// Store the FIFO values in the registers
always @(posedge i_clk, posedge i_reset)
begin
    if (i_reset)
        begin
            interfacemodule_dataAreg    <= 0;
            interfacemodule_dataBreg    <= 0;
            interfacemodule_opreg        <= 0;
            o_interfacemodule_RESULTDATA <= 0;      // Reset del registro del resultado
        end
    else
        begin
            if (interfacemodule_statereg == interfacemodule_dataAstate)
                interfacemodule_dataAreg <= i_interfacemodule_DATA;
            else if (interfacemodule_statereg == interfacemodule_dataBstate)
                interfacemodule_dataBreg <= i_interfacemodule_DATA;
            else if (interfacemodule_statereg == interfacemodule_opstate)
                interfacemodule_opreg <= i_interfacemodule_DATA[NB_INTERFACEMODULE_OP - 1:0]; // Solo se toman los bits necesarios para el operando
        end
end

// output
assign o_interfacemodule_DATAA = interfacemodule_dataAreg;
assign o_interfacemodule_DATAB = interfacemodule_dataBreg;
assign o_interfacemodule_ALUOP     = interfacemodule_opreg;

endmodule
