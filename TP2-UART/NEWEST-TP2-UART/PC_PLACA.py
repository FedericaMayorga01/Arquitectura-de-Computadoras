import sys
import serial
from typing import Optional

# Configuración prefijada
BAUDRATE = 19200  # Set baud rate for communication
SERIAL_PORT = "COM6"  # Establece el puerto COM directamente aquí

OPCODES = {
    'ADD': 0x20,
    'SUB': 0x22,
    'AND': 0x24,
    'OR':  0x25,
    'XOR': 0x26,
    'NOR': 0x27,
    'SRA': 0x03,
    'SRL': 0x020
}

EXIT_COMMANDS = {'q', 'e'}

class SerialPortControl:
    def __init__(self) -> None:
        try:
            self.serial_port = serial.Serial(SERIAL_PORT, BAUDRATE, timeout=1)
        except serial.SerialException as e:
            print(f"Error opening serial port: {e}")
            sys.exit(1)

    def send_serial_data(self) -> None:
        # Mostrar mensajes de advertencia al usuario
        print("----------------------------------------------")
        print("Recordar presionar el botón de reset en placa antes de comenzar.")
        print("Revisar el puerto COM colocado.")
        print("----------------------------------------------")

        while True:
            operand1 = self.get_operand("Ingrese el primer byte de datos: ")
            if operand1 is None:
                break

            operand2 = self.get_operand("Ingrese el segundo byte de datos: ")
            if operand2 is None:
                break

            operation = self.get_operation()
            if operation is None:
                break

            self.send_data(operation, operand1, operand2)
            self.receive_result()

    def get_operand(self, prompt: str) -> Optional[int]:
        operand_str: str = input(f'{prompt}').lower()
        if operand_str in EXIT_COMMANDS:
            self.exit_program()

        if len(operand_str) == 8 and all(c in '01' for c in operand_str):
            operand = int(operand_str, 2)
            if operand & 0x80:
                operand -= 256
            return operand & 0xFF
        else:
            print('Error: por favor ingrese un numero binario de 8 bits.')
            return None

    def get_operation(self) -> Optional[int]:
        operation: str = input('Ingrese la operacion ... ADD, SUB, AND, OR, XOR, NOR, SRA, SRL : ').lower()
        if operation in EXIT_COMMANDS:
            self.exit_program()

        if operation.upper() in OPCODES:
            return OPCODES[operation.upper()]
        else:
            print('Operacion invalida')
            return None

    def send_data(self, operation: int, operand1: int, operand2: int) -> None:
        data_to_send: bytes = bytes([operation, operand1, operand2])
        self.serial_port.write(data_to_send)

    def receive_result(self) -> None:
        received_data: bytes = self.serial_port.read(1)
        if len(received_data) == 1:
            result: int = int.from_bytes(received_data, byteorder='big', signed=True)
            binary_result: str = f'{result & 0xFF:08b}'
            print(f'Resultado: {binary_result} ({result})')
        else:
            print('Error de recepcion: ningun dato recibido')

    def exit_program(self) -> None:
        print('Saliendo...')
        self.serial_port.close()
        sys.exit()

if __name__ == "__main__":
    app = SerialPortControl()
    app.send_serial_data()  # Continuously send operations until exit command is entered
