`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.09.2025 17:16:53
// Design Name: 
// Module Name: Door_Lock_Code_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Door_Lock_Code_tb;
 // Parámetros de la simulación
    localparam CLK_PERIOD = 10; // 10 ns -> 100 MHz
    
    logic clk;
    logic rst;
    logic [7:0] sw;
    logic [3:0] btn;
    logic [1:0] led;
// Instanciar
// (Asegúrate de que el nombre del módulo coincida con tu archivo)
    Door_Lock_Code dut (
        .clk(clk),
        .rst(rst),
        .sw(sw),
        .btn(btn),
        .led(led)
    );
    // Generador de reloj
    always #(CLK_PERIOD / 2) clk = ~clk;
    // Tarea para simular una pulsación de botón realista
    task press_button(input int button_index, input int duration_ms);
        $display("[%0t ns] Presionando botón %0d por %0d ms", $time, button_index, duration_ms);
        btn[button_index] = 1'b1;
        #(duration_ms * 1_000_000); // Espera la duración en ns
        btn[button_index] = 1'b0;
        #(10_000_000); // Espera 10ms entre pulsaciones
    endtask
    // Secuencia principal de la simulación
    initial begin
        // 1. Inicialización y Reset
        clk = 0;
        rst = 1;
        sw  = 8'h0;
        btn = 4'b0;
        $display("[%0t ns] Simulación iniciada. Aplicando Reset.", $time);
        
        #(CLK_PERIOD * 5);
        rst = 0;
        $display("[%0t ns] Reset liberado. El sistema está en IDLE.", $time);

        // 2. Definir clave secreta: 1-2-3-0 -> 01_10_11_00 -> 8'b01101100 -> 8'h6C
        sw = 8'h6C;
        $display("[%0t ns] Clave secreta establecida en 1-2-3-0 (0x%h)", $time, sw);

        // 3. Prueba 1: Ingresar la clave correcta
        $display("--- INICIANDO PRUEBA DE CLAVE CORRECTA ---");
        press_button(1, 20); // Presiona botón 1 (valor '1')
        press_button(2, 20); // Presiona botón 2 (valor '2')
        press_button(3, 20); // Presiona botón 3 (valor '3')
        press_button(0, 20); // Presiona botón 0 (valor '0')
        
        #(CLK_PERIOD * 10); // Espera a que la FSM se actualice
        $display("[%0t ns] Resultado final: led = %b", $time, led);
        if (led == 2'b01) $display(">>> PRUEBA CORRECTA PASADA! <<<");
        else              $display(">>> PRUEBA CORRECTA FALLIDA! <<<");
        
        // 4. Resetear para la siguiente prueba
        rst = 1;
        #(CLK_PERIOD * 5);
        rst = 0;

        // 5. Prueba 2: Ingresar una clave incorrecta (1-2-0-3)
        $display("--- INICIANDO PRUEBA DE CLAVE INCORRECTA ---");
        press_button(1, 20); // Presiona botón 1 (valor '1') - Correcto
        press_button(2, 20); // Presiona botón 2 (valor '2') - Correcto
        press_button(0, 20); // Presiona botón 0 (valor '0') - INCORRECTO (se esperaba 3)
        press_button(3, 20); // Presiona botón 3 (valor '3')
        
        #(CLK_PERIOD * 10);
        $display("[%0t ns] Resultado final: led = %b", $time, led);
        if (led == 2'b10) $display(">>> PRUEBA INCORRECTA PASADA! <<<");
        else              $display(">>> PRUEBA INCORRECTA FALLIDA! <<<");
        
        // 6. Terminar simulación
        $display("Simulación completada.");
        $finish;
    end

endmodule
