`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.09.2025 13:33:51
// Design Name: 
// Module Name: Door_Lock_Code
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


module Door_Lock_Code(
 input  logic clk, // Señal de reloj
 input  logic rst, // Reset activo en alto
 input  logic [7:0] sw,  // Switches para la clave secreta
 input  logic [3:0] btn, // 4 botones para la entrada
 output logic [1:0] led  // led[0]: Éxito, led[1]: Fallo
 );
 //fsm state type
 // Definición de la Máquina de Estados (FSM)
    typedef enum logic [2:0] {
        IDLE,         // Esperando para iniciar la secuencia
        S1,
        S2,
        S3,        
        RESULT   // Mostrando el resultado final
    } statetype;
    //Registro para guardar estado actual y siguiente
    statetype estado_actual, estado_siguiente;
    logic error_flag, next_error_flag; // Bandera para registrar un error
    logic [1:0] digit_count, next_digit_count; // Contador de dígitos (0 a 3)
    // Señales para la detección de flanco de subida del botón
    logic [3:0] btn_prev;
    logic [3:0] btn_pressed;
    // Señales para decodificar la entrada
    logic [1:0] pressed_value;
    logic [1:0] expected_value;
    logic button_is_pressed;
    
    // Proceso síncrono para actualizar los registros (estado, contador y flag)
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            estado_actual <= IDLE;
            digit_count <= 2'b0;
            error_flag <= 1'b0;
            btn_prev <= 4'b0;
        end else begin
            estado_actual <= estado_siguiente;
            digit_count <= next_digit_count;
            error_flag <= next_error_flag;
            btn_prev <= btn;
        end
    end
    // Proceso combinacional
    always_comb begin
        // Valores por defecto para evitar latches
        estado_siguiente = estado_actual;
        next_digit_count = digit_count;
        next_error_flag = error_flag;
        // Detección de flanco (una pulsación a la vez)
        btn_pressed = btn & ~btn_prev;
        button_is_pressed = |btn_pressed;
         // Decodifica el botón presionado a su valor binario de 2 bits
        case(1'b1)
            btn_pressed[0]: pressed_value = 2'b00; // btn[0] -> 0
            btn_pressed[1]: pressed_value = 2'b01; // btn[1] -> 1
            btn_pressed[2]: pressed_value = 2'b10; // btn[2] -> 2
            btn_pressed[3]: pressed_value = 2'b11; // btn[3] -> 3
            default:        pressed_value = 2'b00;
        endcase
         // Selecciona el dígito esperado de la clave secreta
        case(digit_count)
            2'd0: expected_value = sw[7:6];
            2'd1: expected_value = sw[5:4];
            2'd2: expected_value = sw[3:2];
            2'd3: expected_value = sw[1:0];
            default: expected_value = 2'b00;
        endcase
        // Lógica de transición de estados
        case (estado_actual)
            IDLE: begin
                // Al iniciar, el contador y la bandera de error se resetean
                next_digit_count = 2'b0;
                next_error_flag = 1'b0;
                if (button_is_pressed) begin
                  if(pressed_value != expected_value) begin
                  next_error_flag = 1'b1;
                  estado_siguiente = S1;
                  end
                end
            end
            
            S1: begin
                if (button_is_pressed) begin
                    // Compara el dígito presionado con el esperado
                    if (pressed_value != expected_value) begin
                        // Si hay un error, se activa la bandera
                        next_error_flag = 1'b1;
                        estado_siguiente = S2;
                    end           
                 end
             end
            S2: begin
                if (button_is_pressed) begin
                    // Compara el dígito presionado con el esperado
                    if (pressed_value != expected_value) begin
                        // Si hay un error, se activa la bandera
                        next_error_flag = 1'b1;
                        estado_siguiente = S3;
                    end
                end
            end
            S3: begin
            if (button_is_pressed) begin
                    // Compara el dígito presionado con el esperado
                    if (pressed_value != expected_value) begin
                        // Si hay un error, se activa la bandera
                        next_error_flag = 1'b1;
                        estado_siguiente = RESULT;
                    end
                end
            end
        endcase
    end
    
    // Los LEDs solo se encienden en el estado final
    always_comb begin
        if (estado_actual == RESULT) begin
            if (error_flag) begin
                led = 2'b10; // Error: enciende led[1]
            end else begin
                led = 2'b01; // Éxito: enciende led[0]
            end
        end else begin
            led = 2'b00; // En cualquier otro estado, los LEDs están apagados
        end
        end
endmodule
