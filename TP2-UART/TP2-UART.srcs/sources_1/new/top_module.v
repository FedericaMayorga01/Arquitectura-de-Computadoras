`timescale 1ns / 1ps

module top_module
#(
    parameter NB_TOPMODULE_DATA    = 8,     // data bits
              NB_TOPMODULE_OP      = 6,
              SB_TOPMODULE_TICKS   = 16,   // stop bits ticks
              NB_TOPMODULE_COUNTER = 9,    // counter bits
              MOD_TOPMODULE_M      = 325,  // ms counter bits
              NB_TOPMODULE_ADDR    = 4

)
(
    input wire i_clk,
    input wire i_reset,
    input wire i_topmodule_RX,
    output wire o_topmodule_TX,
    output wire [3:0] o_topmodule_leds // boton 0 para data A, boton 1 para data B, boton 2 para OP, boton 3 para reset

);

//--------------- INICIALIZACION DE MODULOS --- start
alu_module #(
    .NB_ALUMODULE_DATA(NB_TOPMODULE_DATA),
    .NB_ALUMODULE_OP(NB_TOPMODULE_OP)
) alu_module_1 (
    .i_alumodule_data_A(),
    .i_alumodule_data_B(),
    .i_alumodule_OP(),
    .o_alumodule_data_RES(),
    .o_alumodule_ZERO(),                // no asignar por ahora
    .o_alumodule_NEGATIVE(),            // no asignar por ahora
    .o_alumodule_CARRY()                // no asignar por ahora
);


uart_module #(
    .NB_UARTMODULE_DATA(NB_TOPMODULE_DATA),
    .SB_UARTMODULE_TICKS(SB_TOPMODULE_TICKS),
    .NB_UARTMODULE_COUNTER(NB_TOPMODULE_COUNTER),
    .MOD_UARTMODULE_M(MOD_TOPMODULE_M),
    .NB_UARTMODULE_ADDR(NB_TOPMODULE_ADDR)
) uart_module_1 (
    .i_clk(i_clk),
    .i_reset(i_reset),
    .i_uartmodule_RX(i_topmodule_RX),
    .i_uartmodule_TXSTART(),            // conectar a la interfaz
    .i_uartmodule_DIN(),                // conectar a la interfaz
    .o_uartmodule_RXDONE(),             // conectar a la interfaz
    .o_uartmodule_DOUT(),               // conectar a la interfaz
    .o_uartmodule_TXDONE(),             // conectar a la interfaz
    .o_uartmodule_TX(o_topmodule_TX)
);

// ACA INICIALIZAR INTERFACE


//--------------- INICIALIZACION DE MODULOS --- end

always @(posedge i_clk)begin
        if(i_reset)begin
            o_topmodule_leds[0] <= 1'b1;
        end
        else begin
            o_topmodule_leds[0] <= 1'b0;  // Apaga el LED 0 cuando se suelta el reset
        end
end

endmodule
