// Testbench con valores aleatorios para probar todas las operaciones de la ALU
`timescale 1ns / 1ps

module tb_top_module;

    // Parámetros
    parameter NB_MODSIMU_DATA = 8;
    parameter NB_MODSIMU_OP = 6;
    parameter NB_MODSIMU_BUT = 3;
    
    // Señales de entrada
    reg i_simu_clk;
    reg i_simu_reset;
    reg [NB_MODSIMU_DATA-1:0] i_simu_sw;
    reg [NB_MODSIMU_BUT-1:0] i_simu_but;
    
    // Señales de salida
    wire [NB_MODSIMU_DATA-1:0] o_simu_leds;

    // Variables temporales para generar valores aleatorios
    reg [NB_MODSIMU_DATA-1:0] A, B, expected_result;
    reg [NB_MODSIMU_OP-1:0] operation;

    // Instanciación del módulo top_module
    top_module #(
        .NB_MODTOP_DATA(NB_MODSIMU_DATA),
        .NB_MODTOP_OP(NB_MODSIMU_OP),
        .NB_MODTOP_BUT(NB_MODSIMU_BUT)
    ) uut (
        .i_clk(i_simu_clk),
        .i_modtop_reset(i_simu_reset),
        .i_modtop_sw(i_simu_sw),
        .i_modtop_but(i_simu_but),
        .o_modtop_leds(o_simu_leds)
    );

    // Generación del reloj
    always begin
        i_simu_clk = 0;
        forever #5 i_simu_clk = ~i_simu_clk; // Reloj con periodo de 10 ns
    end

    // Proceso de prueba
    initial begin
        // Inicialización
        i_simu_clk = 0;
        i_simu_reset = 1;
        i_simu_sw = 0;
        i_simu_but = 0;
        #20;
        
        // Salir de reset
        i_simu_reset = 0;

        repeat(10) begin // Realizar 10 pruebas con valores aleatorios
            // Generar valores aleatorios para A y B
            A = $random % 256;
            B = $random % 256;
            
            // PRUEBA 1: Suma (add)
            operation = 6'b100000;
            expected_result = A + B;
            run_test(A, B, operation, expected_result, "Suma");

            // PRUEBA 2: Resta (sub)
            operation = 6'b100010;
            expected_result = A - B;
            run_test(A, B, operation, expected_result, "Resta");

            // PRUEBA 3: AND
            operation = 6'b100100;
            expected_result = A & B;
            run_test(A, B, operation, expected_result, "AND");

            // PRUEBA 4: OR
            operation = 6'b100101;
            expected_result = A | B;
            run_test(A, B, operation, expected_result, "OR");

            // PRUEBA 5: XOR
            operation = 6'b100110;
            expected_result = A ^ B;
            run_test(A, B, operation, expected_result, "XOR");

            // PRUEBA 6: SRA (desplazamiento aritmético a la derecha)
            operation = 6'b000011;
            expected_result = $signed(A) >>> B;
            run_test(A, B, operation, expected_result, "SRA");

            // PRUEBA 7: SRL (desplazamiento lógico a la derecha)
            operation = 6'b000010;
            expected_result = A >> B;
            run_test(A, B, operation, expected_result, "SRL");

            // PRUEBA 8: NOR
            operation = 6'b100111;
            expected_result = ~(A | B);
            run_test(A, B, operation, expected_result, "NOR");
        end

        // Fin de las pruebas
        $finish;
    end

    // Procedimiento para ejecutar la prueba
    task run_test(
        input [NB_MODSIMU_DATA-1:0] A,
        input [NB_MODSIMU_DATA-1:0] B,
        input [NB_MODSIMU_OP-1:0] operation,
        input [NB_MODSIMU_DATA-1:0] expected_result,
        input [8*10:1] operation_name
    );
    begin
        // Asignar valor de A
        i_simu_sw = A;
        i_simu_but = 3'b001; // Setear A
        #10;

        // Asignar valor de B
        i_simu_sw = B;
        i_simu_but = 3'b010; // Setear B
        #10;

        // Asignar operación
        i_simu_sw = operation;
        i_simu_but = 3'b100; // Setear operación
        #10;

        // Comparar resultado
        if (o_simu_leds !== expected_result)
            $display("Error en %0s: A = %d, B = %d. Resultado esperado = %d, Resultado obtenido = %d", 
                     operation_name, A, B, expected_result, o_simu_leds);
        else
            $display("Prueba de %0s exitosa: A = %d, B = %d, Resultado = %d", 
                     operation_name, A, B, o_simu_leds);
    end
    endtask

endmodule
