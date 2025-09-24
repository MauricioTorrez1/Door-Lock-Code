#Cerradura Digital Secuencial con Anti-Rebote en SystemVerilog

Este proyecto implementa una cerradura digital segura en una FPGA Basys 3. El diseño, codificado en SystemVerilog, requiere que un usuario introduzca una secuencia de 4 dígitos a través de botones. Para mayor seguridad, el sistema no revela si un dígito es incorrecto hasta que se ha introducido la secuencia completa.

# Características Principales

-   Clave Secreta Configurable**: La clave de 4 dígitos (8 bits) se establece fácilmente mediante los 8 interruptores (`switches`) de la tarjeta.
-   Entrada Secuencial: El usuario introduce la clave presionando 4 botones en el orden correcto.
-   Verificación Segura: El sistema no da retroalimentación inmediata sobre un dígito erróneo. El resultado (éxito o fallo) se muestra únicamente después de introducir los 4 dígitos.
-   Máquina de Estados Finitos (FSM)**: El núcleo de la lógica se gestiona con una FSM clara y robusta.
  
