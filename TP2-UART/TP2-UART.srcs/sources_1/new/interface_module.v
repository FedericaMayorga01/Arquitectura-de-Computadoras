`timescale 1ns / 1ps

// module interface_module
// #(
//     parameter NB_INTERFACEMODULE_DATA = 8,          // Data bits
//     parameter NB_INTERFACEMODULE_OP   = 6           // Operation bits
// )
// (
//     input   wire i_clk, i_reset,                                            // Clk y reset
//     input   wire i_interfacemodule_EMPTY,                                   // Indica si la FIFO está vacía
//     input   wire i_interfacemodule_FULL,                                    // Indica si la FIFO está llena
//     input  wire signed [NB_INTERFACEMODULE_DATA - 1:0] i_interfacemodule_READDATA,                                             // Señal para iniciar lectura de FIFO
//     input  wire signed [NB_INTERFACEMODULE_DATA - 1:0] i_interfacemodule_DATARES,                    // Resultado de la ALU procesado
// //    input wire i_interfacemodule_READY,

// //    output reg o_interfacemodule_VERIFIN,
//     output  wire o_interfacemodule_READ,                                    // Señal para leer de la FIFO
//     output  wire o_interfacemodule_WRITE,                                                // Señal para escribir la FIFO
//     output  wire  signed [NB_INTERFACEMODULE_DATA - 1:0] o_interfacemodule_WRITEDATA,    // Byte enviado
//     output  wire signed [NB_INTERFACEMODULE_DATA - 1:0] o_interfacemodule_DATAA,                   // Dato A para la ALU
//     output  wire signed [NB_INTERFACEMODULE_DATA - 1:0] o_interfacemodule_DATAB,                   // Dato B para la ALU
//     output  wire [NB_INTERFACEMODULE_OP - 1:0] o_interfacemodule_OP,                                // Operando para la ALU
//     output  wire [5:0] o_interfacemodule_LEDS
// );

// // symbolic interfacemodule_statereg declaration
// localparam [2:0]
//     interfacemodule_idlestate   = 3'b000,
//     interfacemodule_dataAstate  = 3'b001,
//     interfacemodule_dataBstate  = 3'b010,
//     interfacemodule_opstate     = 3'b011,
//     interfacemodule_resultstate = 3'b100;    // Nuevo estado para manejar el resultado de la ALU

// // signal declaration
// reg signed [NB_INTERFACEMODULE_DATA - 1:0] interfacemodule_dataAreg, interfacemodule_dataBreg, interfacemodule_dataresreg;     // Registros para los datos A y B
// reg [NB_INTERFACEMODULE_OP - 1 :0] interfacemodule_opreg;                      // Registro para el operando de la ALU
// reg [2:0] interfacemodule_statereg ,    interfacemodule_nextstatereg ;    // 3 bits ya que hay 5 estados, de 0 a 3
// reg [5:0] interfacemodule_ledsreg;
// reg interfacemodule_readreg, interfacemodule_writereg;

// // FSMD interfacemodule_statereg & interface_module registers
// always @(posedge i_clk)
//         if (i_reset)
//             begin
//                 interfacemodule_statereg <= interfacemodule_idlestate;
//             end
//         else
//             begin
//                 interfacemodule_statereg <= interfacemodule_nextstatereg;
//             end

// // Registro de los datos A, B y operando
// always @(posedge i_clk) begin
//     if (i_reset) begin
//         interfacemodule_dataAreg <= 0;
//         interfacemodule_dataBreg <= 0;
//         interfacemodule_opreg <= 0;
//         interfacemodule_dataresreg <= 0;
//         interfacemodule_ledsreg <= 6'b000001;
//         interfacemodule_readreg <= 0;
//         interfacemodule_writereg <= 0;
//     end
//     else begin
//         case (interfacemodule_statereg)
//             interfacemodule_idlestate: begin
//                 interfacemodule_ledsreg <= 6'b000010;
//             end

//             interfacemodule_dataAstate: begin
//                 interfacemodule_ledsreg <= 6'b000100;
//                 if (!i_interfacemodule_EMPTY) begin
//                     interfacemodule_dataAreg <= i_interfacemodule_READDATA;   // Almacenar valor en DATAA
//                     interfacemodule_readreg <= 1'b1;
//                 end
//             end

//             interfacemodule_dataBstate: begin
//                 interfacemodule_ledsreg <= 6'b001000;
//                 if (!i_interfacemodule_EMPTY) begin
//                     interfacemodule_dataBreg <= i_interfacemodule_READDATA;   // Almacenar valor en DATAB
//                     interfacemodule_readreg <= 1'b1;
//                 end
//             end

//             interfacemodule_opstate: begin
//                 interfacemodule_ledsreg <= 6'b010000;
//                 if (!i_interfacemodule_EMPTY) begin
//                     interfacemodule_opreg <= i_interfacemodule_READDATA[NB_INTERFACEMODULE_OP-1:0];  // Almacenar operando
//                     interfacemodule_readreg <= 1'b1;
//                 end
//             end

//             interfacemodule_resultstate: begin
//                 interfacemodule_writereg <= 1'b1;
//                 interfacemodule_ledsreg <= 6'b100000;
//                 interfacemodule_dataresreg <= i_interfacemodule_DATARES;      // Almacenar resultado
//             end
//         endcase
//     end
// end

// // FSMD next-interfacemodule_statereg logic
// always @(*) begin
//     interfacemodule_nextstatereg                 = interfacemodule_statereg;
//     //o_interfacemodule_READ = 1'b0;          // Por defecto no lee de la FIFO Rx
//     //o_interfacemodule_WRITE    = 1'b0;          // Por defecto no escribe en la FIFO Tx
// //    o_interfacemodule_VERIFIN = 1'b0;

//     case (interfacemodule_statereg)
//         interfacemodule_idlestate:
//             begin
//                 if (!(i_interfacemodule_EMPTY))     // fiforx no esta vacia
//                     begin
//                     // interfacemodule_dataAreg = i_interfacemodule_READDATA;
//                         //o_interfacemodule_READ = 1'b1;          // Iniciar lectura de FIFO
//                         interfacemodule_nextstatereg = interfacemodule_dataAstate;    // Cambiar al estado para leer el dato A
//                     end
//             end
//         interfacemodule_dataAstate:
//             begin
//                 if (!(i_interfacemodule_EMPTY)) 
//                     begin
//                         //interfacemodule_dataBreg = i_interfacemodule_READDATA;
//                         //o_interfacemodule_READ = 1'b1;          // Iniciar lectura de FIFO
//                         interfacemodule_nextstatereg = interfacemodule_dataBstate;                
//                     end
//             end

//         interfacemodule_dataBstate:
//             begin
//                 if (!(i_interfacemodule_EMPTY)) 
//                     begin
//                         //interfacemodule_opreg = i_interfacemodule_READDATA[NB_INTERFACEMODULE_OP-1:0];  // Se realiza el truncamiento;
//                         //o_interfacemodule_READ = 1'b1;          // Iniciar lectura de FIFO
//                         interfacemodule_nextstatereg = interfacemodule_opstate;                
//                     end
//             end

//         interfacemodule_opstate:
//             begin
//                 if (!(i_interfacemodule_EMPTY)) 
//                     begin
//                         //interfacemodule_dataresreg = i_interfacemodule_DATARES;             
//                         //o_interfacemodule_READ = 1'b1; 
//                         interfacemodule_nextstatereg = interfacemodule_resultstate;        // Cambiar al estado de resultado
//                     end
//             end

//         interfacemodule_resultstate:                                        
//             begin
//                 if ((!(i_interfacemodule_FULL))&(!(i_interfacemodule_EMPTY)))                               // Solo escribe si la FIFO Tx no está llena
//                     begin
//                         //o_interfacemodule_WRITE = 1'b1;                              

// //                        o_interfacemodule_VERIFIN = 1'b1;
//                         interfacemodule_nextstatereg = interfacemodule_idlestate;              
//                     end
//             end

//         default:
//             interfacemodule_nextstatereg = interfacemodule_idlestate;

//     endcase
// end

// // outputs
// assign o_interfacemodule_DATAA = interfacemodule_dataAreg;
// assign o_interfacemodule_DATAB = interfacemodule_dataBreg;
// assign o_interfacemodule_OP     = interfacemodule_opreg;
// assign o_interfacemodule_WRITEDATA = interfacemodule_dataresreg;
// assign o_interfacemodule_LEDS = interfacemodule_ledsreg;
// assign o_interfacemodule_WRITE = interfacemodule_writereg;
// assign o_interfacemodule_READ = interfacemodule_readreg;

// endmodule


module interface_module #
(
    parameter NB_INTERFACEMODULE_DATA = 8,
    parameter NB_INTERFACEMODULE_OP   = 6
)
(
    input wire i_clk,
    input wire i_reset,
    input wire [NB_INTERFACEMODULE_DATA-1:0] i_interfacemodule_DATARES,
    input wire [NB_INTERFACEMODULE_DATA-1:0] i_interfacemodule_READDATA,
    input wire                               i_interfacemodule_EMPTY,
    input wire                               i_interfacemodule_FULL,

    output wire                               o_interfacemodule_READ,
    output wire                               o_interfacemodule_WRITE,
    output wire [NB_INTERFACEMODULE_DATA-1:0] o_interfacemodule_WRITEDATA,
    output wire [NB_INTERFACEMODULE_OP-1:0]   o_interfacemodule_OP,
    output wire [NB_INTERFACEMODULE_DATA-1:0] o_interfacemodule_DATAA,
    output wire [NB_INTERFACEMODULE_DATA-1:0] o_interfacemodule_DATAB
);

// Symbolic interfacemodule_statereg declaration
localparam [3:0] interfacemodule_idlestate   = 4'b0000;
localparam [3:0] interfacemodule_dataAstate  = 4'b0001;
localparam [3:0] interfacemodule_dataBstate  = 4'b0010;
localparam [3:0] interfacemodule_opstate     = 4'b0011;
localparam [3:0] interfacemodule_resultstate = 4'b0100;
localparam [3:0] interfacemodule_waitstate   = 4'b0101; // new

reg [3:0]                         interfacemodule_statereg,   interfacemodule_nextstatereg;
reg                               interfacemodule_readreg,    interfacemodule_nextreadreg;      // new nextreadreg
reg                               interfacemodule_writereg,   interfacemodule_nextwritereg;     // new nextwritereg
reg [NB_INTERFACEMODULE_OP-1:0]   interfacemodule_opreg,      interfacemodule_nextopreg;        // new next
reg [NB_INTERFACEMODULE_DATA-1:0] interfacemodule_dataAreg,   interfacemodule_nextdataAreg;     // new next
reg [NB_INTERFACEMODULE_DATA-1:0] interfacemodule_dataBreg,   interfacemodule_nextdataBreg;     // new next
reg [NB_INTERFACEMODULE_DATA-1:0] interfacemodule_dataresreg, interfacemodule_nextdataresreg;   // new next
reg [3:0]                         interfacemodule_waitreg,    interfacemodule_nextwaitreg;      // new wait, new next
reg [6:0]                         interfacemodule_ledsreg;                                      // leds

always @(posedge i_clk) begin
    if(i_reset)
        begin
            interfacemodule_statereg    <= interfacemodule_idlestate;
            interfacemodule_readreg     <= 1'b0;
            interfacemodule_writereg    <= 1'b0;
            interfacemodule_opreg       <= {NB_INTERFACEMODULE_OP{1'b0}};
            interfacemodule_dataAreg    <= {NB_INTERFACEMODULE_DATA{1'b0}};
            interfacemodule_dataBreg    <= {NB_INTERFACEMODULE_DATA{1'b0}};
            interfacemodule_dataresreg  <= {NB_INTERFACEMODULE_DATA{1'b0}};
            interfacemodule_waitreg     <= 4'b0000;

            interfacemodule_ledsreg <= 7'b0000001;   // led

        end
    else
        begin
            interfacemodule_statereg    <= interfacemodule_nextstatereg;
            interfacemodule_readreg     <= interfacemodule_nextreadreg;
            interfacemodule_writereg    <= interfacemodule_nextwritereg;
            interfacemodule_opreg       <= interfacemodule_nextopreg;
            interfacemodule_dataAreg    <= interfacemodule_nextdataAreg;
            interfacemodule_dataBreg    <= interfacemodule_nextdataBreg;
            interfacemodule_dataresreg  <= interfacemodule_nextdataresreg;
            interfacemodule_waitreg     <= interfacemodule_nextwaitreg;
        end
end

always @(*) begin
    interfacemodule_nextstatereg   = interfacemodule_statereg;
    interfacemodule_nextreadreg    = interfacemodule_readreg;
    interfacemodule_nextwritereg   = interfacemodule_writereg;
    interfacemodule_nextopreg      = interfacemodule_opreg;
    interfacemodule_nextdataAreg   = interfacemodule_dataAreg;
    interfacemodule_nextdataBreg   = interfacemodule_dataBreg;
    interfacemodule_nextdataresreg = interfacemodule_resultstate;
    interfacemodule_nextwaitreg    = interfacemodule_waitreg;

    case (interfacemodule_statereg)
        interfacemodule_idlestate: begin
            interfacemodule_nextwritereg = 1'b0;
            interfacemodule_ledsreg <= 7'b0000010;   // led
            if(~i_interfacemodule_EMPTY) begin
                interfacemodule_nextstatereg = interfacemodule_dataAreg;    // changed
                interfacemodule_nextreadreg  = 1'b1;
            end
        end

        interfacemodule_dataAstate: begin
            interfacemodule_ledsreg <= 7'b0000100;   // led
            if(i_interfacemodule_EMPTY) begin
                interfacemodule_nextreadreg  = 1'b0;
                interfacemodule_nextstatereg = interfacemodule_waitstate;
                interfacemodule_nextwaitreg  = interfacemodule_dataAstate;
            end
            else begin
                interfacemodule_nextstatereg = interfacemodule_dataBstate;
                interfacemodule_nextdataAreg = i_interfacemodule_READDATA;
                interfacemodule_nextreadreg  = 1'b1;
            end
        end

        interfacemodule_dataBstate: begin
            interfacemodule_ledsreg <= 7'b0001000;   // led
            if(i_interfacemodule_EMPTY) begin
                interfacemodule_nextreadreg  = 1'b0;
                interfacemodule_nextstatereg = interfacemodule_waitstate;
                interfacemodule_nextwaitreg  = interfacemodule_dataBstate;
            end
            else begin
                interfacemodule_nextstatereg = interfacemodule_opstate;
                interfacemodule_nextdataBreg = i_interfacemodule_READDATA;
                interfacemodule_nextreadreg  = 1'b0;
            end
        end

        interfacemodule_opstate: begin
            interfacemodule_ledsreg <= 7'b0010000;   // led
            if(i_interfacemodule_EMPTY) begin
                interfacemodule_nextreadreg  = 1'b0;
                interfacemodule_nextstatereg = interfacemodule_waitstate;
                interfacemodule_nextwaitreg  = interfacemodule_opstate;
            end
            else begin
                interfacemodule_nextstatereg = interfacemodule_dataAstate;
                interfacemodule_nextopreg    = i_interfacemodule_READDATA[NB_INTERFACEMODULE_OP-1:0];
                interfacemodule_nextreadreg  = 1'b1;
            end
        end

        interfacemodule_resultstate: begin
            interfacemodule_ledsreg <= 7'b0100000;   // led
            if(~i_interfacemodule_FULL) begin
                interfacemodule_nextstatereg   = interfacemodule_idlestate;
                interfacemodule_nextdataresreg = i_interfacemodule_DATARES;
                interfacemodule_nextwritereg   = 1'b1;
            end
        end

        interfacemodule_waitstate: begin
            interfacemodule_ledsreg <= 7'b1000000;   // led
            if(~i_interfacemodule_EMPTY) begin
                interfacemodule_nextstatereg = interfacemodule_waitreg;
                interfacemodule_nextreadreg  = 1'b1;
            end
        end

        default: begin
            interfacemodule_nextstatereg = interfacemodule_idlestate;
            interfacemodule_nextreadreg  = 1'b0;
            interfacemodule_nextwritereg = 1'b0;
        end

    endcase
end

assign o_interfacemodule_DATAA     = interfacemodule_dataAreg;
assign o_interfacemodule_DATAB     = interfacemodule_dataBreg;
assign o_interfacemodule_OP        = interfacemodule_opreg;
assign o_interfacemodule_WRITEDATA = interfacemodule_resultstate;
assign o_interfacemodule_WRITE     = interfacemodule_writereg;
assign o_interfacemodule_READ      = interfacemodule_readreg;

endmodule