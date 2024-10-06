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
    input  wire signed [NB_INTERFACEMODULE_DATA - 1:0] i_interfacemodule_READDATA,                                             // Señal para iniciar lectura de FIFO
    input  wire signed [NB_INTERFACEMODULE_DATA - 1:0] i_interfacemodule_DATARES,                    // Resultado de la ALU procesado

    output  reg o_interfacemodule_READ,                                    // Señal para leer de la FIFO
    output  reg o_interfacemodule_WRITE,                                                // Señal para escribir la FIFO
    output  wire  signed [NB_INTERFACEMODULE_DATA - 1:0] o_interfacemodule_WRITEDATA,    // Byte enviado
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
reg signed [NB_INTERFACEMODULE_DATA - 1:0] interfacemodule_dataAreg, interfacemodule_dataBreg, interfacemodule_dataresreg;     // Registros para los datos A y B
reg [NB_INTERFACEMODULE_OP - 1 :0] interfacemodule_opreg;                      // Registro para el operando de la ALU
reg [2:0] interfacemodule_statereg ,    interfacemodule_nextstatereg ;    // 3 bits ya que hay 5 estados, de 0 a 3

// FSMD state & interface_module registers
always @(posedge i_clk)
    begin
        if (i_reset)
            interfacemodule_statereg <= interfacemodule_idlestate;
        else
            interfacemodule_statereg <= interfacemodule_nextstatereg;
    end

// Registro de los datos A, B y operando
always @(posedge i_clk) begin
    if (i_reset) begin
        interfacemodule_dataAreg <= 0;
        interfacemodule_dataBreg <= 0;
        interfacemodule_opreg <= 0;
        interfacemodule_dataresreg <= 0;
    end
    else begin
        case (interfacemodule_statereg)
            interfacemodule_dataAstate: begin
                if (!i_interfacemodule_EMPTY) begin
                    interfacemodule_dataAreg <= i_interfacemodule_READDATA;   // Almacenar valor en DATAA
                end
            end

            interfacemodule_dataBstate: begin
                if (!i_interfacemodule_EMPTY) begin
                    interfacemodule_dataBreg <= i_interfacemodule_READDATA;   // Almacenar valor en DATAB
                end
            end

            interfacemodule_opstate: begin
                if (!i_interfacemodule_EMPTY) begin
                    interfacemodule_opreg <= i_interfacemodule_READDATA[NB_INTERFACEMODULE_OP-1:0];  // Almacenar operando
                end
            end

            interfacemodule_resultstate: begin
                interfacemodule_dataresreg <= i_interfacemodule_DATARES;      // Almacenar resultado
            end
        endcase
    end
end

// FSMD next-state logic
always @(*) begin
    interfacemodule_nextstatereg                 = interfacemodule_statereg;
    o_interfacemodule_READ = 1'b0;          // Por defecto no lee de la FIFO Rx
    o_interfacemodule_WRITE    = 1'b0;          // Por defecto no escribe en la FIFO Tx

    case (interfacemodule_statereg)
        interfacemodule_idlestate:
            if (!(i_interfacemodule_EMPTY)) 
                begin
                   // interfacemodule_dataAreg = i_interfacemodule_READDATA;
                    o_interfacemodule_READ = 1'b1;          // Iniciar lectura de FIFO
                    interfacemodule_nextstatereg = interfacemodule_dataAstate;    // Cambiar al estado para leer el dato A
                end

        interfacemodule_dataAstate:
            if (!(i_interfacemodule_EMPTY)) 
                begin
                    //interfacemodule_dataBreg = i_interfacemodule_READDATA;
                    o_interfacemodule_READ = 1'b1;          // Iniciar lectura de FIFO
                    interfacemodule_nextstatereg = interfacemodule_dataBstate;                
                end

        interfacemodule_dataBstate:
            if (!(i_interfacemodule_EMPTY)) 
                begin
                    //interfacemodule_opreg = i_interfacemodule_READDATA[NB_INTERFACEMODULE_OP-1:0];  // Se realiza el truncamiento;
                    o_interfacemodule_READ = 1'b1;          // Iniciar lectura de FIFO
                    interfacemodule_nextstatereg = interfacemodule_opstate;                
                end

        interfacemodule_opstate:
            begin
                //interfacemodule_dataresreg = i_interfacemodule_DATARES;             
                interfacemodule_nextstatereg = interfacemodule_resultstate;        // Cambiar al estado de resultado
            end

        interfacemodule_resultstate:                                        // Nuevo estado para manejar el resultado
            if (!(i_interfacemodule_FULL))                               // Solo escribe si la FIFO Tx no está llena
                begin
                    o_interfacemodule_WRITE = 1'b1;                              
                    interfacemodule_nextstatereg = interfacemodule_idlestate;              
                end

    endcase
end

// output
assign o_interfacemodule_DATAA = interfacemodule_dataAreg;
assign o_interfacemodule_DATAB = interfacemodule_dataBreg;
assign o_interfacemodule_OP     = interfacemodule_opreg;
assign o_interfacemodule_WRITEDATA = interfacemodule_dataresreg;


endmodule
