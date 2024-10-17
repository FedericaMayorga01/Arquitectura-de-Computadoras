import serial

def enviar_decimal_a_fpga(ser, numero):
    """
    Envía un número decimal de 8 bits (con signo) a la FPGA a través de UART.
    
    :param ser: Objeto serial
    :param numero: Número decimal con signo de 8 bits a enviar (-128 a 127)
    """
    # Verificar que el número esté dentro del rango de 8 bits con signo
    if -128 <= numero <= 127:
        # Convertir el número decimal (con signo) a un byte en complemento a dos
        data = numero.to_bytes(1, byteorder='big', signed=True)
        
        # Enviar los bytes a través del puerto serial
        ser.write(data)
        # Mostrar el valor del byte como un número entero para evitar representaciones como '\t'
        byte_value = int.from_bytes(data, byteorder='big', signed=True)
        print(f"Enviado: {numero} como byte (valor): {byte_value}")
    else:
        print("Error: El número debe estar entre -128 y 127.")

def recibir_datos_de_fpga(ser):
    """
    Recibe los datos enviados desde la FPGA a través de UART.
    
    :param ser: Objeto serial
    :return: Número decimal de 8 bits recibido (con signo)
    """
    # Leer 1 byte (porque estamos manejando números de 8 bits)
    recibido = ser.read(1)
    if recibido:
        # Convertir los bytes recibidos a un número decimal con signo
        numero = int.from_bytes(recibido, byteorder='big', signed=True)
        return numero
    else:
        return None

def main():
    # Configuración del puerto serial
    ser = serial.Serial(
        #port='COM24',       # Cambia esto al puerto correcto (Ej: 'COM3' en Windows o '/dev/ttyUSB0' en Linux)
        port='COM6',
        baudrate=19200,     # Asegúrate de usar el mismo baudrate que tu UART en la FPGA
        bytesize=serial.EIGHTBITS,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
        timeout=1          # Timeout de 1 segundo
    )

  #  for i in range(3):
    while True:
        numero = input("Ingresa un número decimal (-128 a 127) para enviar a la FPGA (o 'q' para salir): ")
        numero_decimal = int(numero)
        enviar_decimal_a_fpga(ser, numero_decimal)

        # Esperar y recibir respuesta desde la FPGA
        print("Esperando respuesta de la FPGA...")
        respuesta = recibir_datos_de_fpga(ser)
        if respuesta is not None:
            print(f"Recibido de la FPGA: {respuesta}")
        else:
            print("No se recibió respuesta.")

if __name__ == "__main__":
    main()
