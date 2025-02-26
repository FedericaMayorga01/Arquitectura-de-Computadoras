import sys
from PySide6.QtWidgets import QApplication, QMainWindow, QWidget, QTextEdit, QTableWidget, QPushButton, QGridLayout, QTableWidgetItem, QFileDialog
from PySide6.QtGui import QColor

from assembler.assemblyParser import assemblyParser
from assembler.instructionTable import instructionTable
from assembler.registerTable import registerTable

import serial

class mipsIDE(QMainWindow):

    codeEditor = None
    assemblyCode = None
    parser = assemblyParser(instructionTable, registerTable, 4)
    programValid = False
    serialComPort = serial.Serial("/dev/pts/2", 115200, timeout=2)

    def __init__(self):
        super().__init__()
        self.initUI()

    def initUI(self):
        self.setWindowTitle("MIPS IDE")

        centralWidget = QWidget()
        self.setCentralWidget(centralWidget)

        # Editor de código
        self.codeEditor = QTextEdit()
        self.codeEditor.setMinimumWidth(600)
        self.codeEditor.setMinimumHeight(300)
        
        # Codigo ensamblado
        self.assemblyCode = QTextEdit()
        self.assemblyCode.setMinimumHeight(300)

        # Tablas de registros
        self.registerTable = QTableWidget(32, 1)
        self.registerTable.setHorizontalHeaderLabels(["Registers"])
        self.registerTable.setMaximumWidth(300)
        self.setTableVerticalHeader(self.registerTable, 32)

        # Tabla de memoria
        self.memoryTable = QTableWidget(32, 1)
        self.memoryTable.setHorizontalHeaderLabels(["Memory"])
        self.memoryTable.setMaximumWidth(300)
        self.setTableVerticalHeader(self.memoryTable, 32)

        # Contador de programa
        self.programCounter = QTableWidget(1, 1)
        self.programCounter.setHorizontalHeaderLabels(["Program Counter"])
        self.programCounter.setMaximumWidth(300)
        self.programCounter.setFixedHeight(100)
        self.setTableVerticalHeader(self.programCounter, 1)

        # Botones
        buildBtn = QPushButton("Build")
        programBtn = QPushButton("Program")
        resetBtn = QPushButton("Reset")
        stepBtn = QPushButton("Step")
        runBtn = QPushButton("Run")
        saveBtn = QPushButton("Save")
        openBtn = QPushButton("Open")

        # Conexion de botones
        buildBtn.clicked.connect(self.handleBuild)
        programBtn.clicked.connect(self.handleProgram)
        resetBtn.clicked.connect(self.handleReset)
        stepBtn.clicked.connect(self.handleStep)
        runBtn.clicked.connect(self.handleRun)
        saveBtn.clicked.connect(self.saveSourceCode)
        openBtn.clicked.connect(self.openFile)

        # Estilo de botones
        buttonStyle = "background-color: #007bff; color: white; font-weight: bold;"
        for btn in [buildBtn, programBtn, resetBtn, stepBtn, runBtn, saveBtn, openBtn]:
            btn.setStyleSheet(buttonStyle)
            btn.setFixedHeight(30)
            btn.setFixedWidth(80)

        # Crea el layout principal
        layout = QGridLayout()
        centralWidget.setLayout(layout)

        # Columna izquierda
        layout.addWidget(self.codeEditor, 0, 0, 1, 2)
        layout.addWidget(self.assemblyCode, 1, 0, 1, 2)

        # Columna derecha
        layout.addWidget(self.registerTable, 0, 2, 1, 1)
        layout.addWidget(self.memoryTable, 1, 2, 1, 1)
        layout.addWidget(self.programCounter, 2, 2, 1, 1)

        # Botones en la parte inferior
        buttonLayout = QGridLayout()
        buttonLayout.addWidget(buildBtn, 0, 0)
        buttonLayout.addWidget(resetBtn, 0, 1)
        buttonLayout.addWidget(runBtn, 0, 2)
        buttonLayout.addWidget(openBtn, 0, 3)
        buttonLayout.addWidget(programBtn, 1, 0)
        buttonLayout.addWidget(stepBtn, 1, 1)
        buttonLayout.addWidget(saveBtn, 1, 2)

        # Agrega los botones al layout principal
        buttonWidget = QWidget()
        buttonWidget.setLayout(buttonLayout)
        layout.addWidget(buttonWidget, 2, 0, 1, 2)

        self.showMaximized()

    def handleBuild(self):
        lines = self.codeEditor.toPlainText().splitlines()
        result = self.parser.firstPass(lines)
        if result != 0:
            self.assemblyCode.setText(result)
            self.programValid = False
        else:
            self.parser.asmToMachineCode(lines)
            self.assemblyCode.setText('')
            for string in self.parser.outputArray:
                self.assemblyCode.append(str(string))
            self.programValid = True

    def handleStep(self):
        self.serialComPort.write(bytes.fromhex('12'))
        self.updateTables()

    def handleReset(self):
        self.serialComPort.write(bytes.fromhex('69'))
        pass

    def handleRun(self):
        self.serialComPort.write(bytes.fromhex('54'))
        self.updateTables()

    def handleProgram(self):
        if(self.programValid):
            for i in range (0, len(self.parser.instructions), 4):
                self.serialComPort.write(bytes.fromhex('23'))
                for j in range (3, -1, -1):
                    index = i+j
                    if (index < len(self.parser.instructions)):
                        byte = int(self.parser.instructions[index], 16)
                        self.serialComPort.write(bytes([byte]))
                    else: 
                        break
        else:
            print("Program not valid")

    def updateTables(self):
        data = self.serialComPort.read(260)
        if len(data) == 260:
            self.updateTable(data, self.registerTable, 0, 32)
            self.updateTable(data, self.memoryTable, 32, 64)
            self.updateTable(data, self.programCounter, 64, 65)
        else:
            print("Time out")

    def updateTable(self, data, table, startIndex, endIndex):
        for i in range(startIndex, endIndex):
            itemIndex = i - startIndex
            value = 0
            for j in range(4):
                byte = data[i * 4 + j]
                value += byte << (j * 8)

            item = QTableWidgetItem(hex(value))
            currentItem = table.item(itemIndex, 0)
            if (currentItem is not None and currentItem.text() != item.text()):
                item.setBackground(QColor(255, 165, 0))
            else:
                item.setBackground(QColor(0, 0, 0, 0))

            table.setItem(itemIndex, 0, item)

    def saveSourceCode(self):
        fileDialog = QFileDialog()
        fileDialog.setFileMode(QFileDialog.AnyFile)
        fileDialog.setAcceptMode(QFileDialog.AcceptSave)
        fileDialog.setNameFilter("*.asm")
        if fileDialog.exec():
            filePath = fileDialog.selectedFiles()[0]
            with open(filePath, 'w') as file:
                file.write(self.codeEditor.toPlainText())

    def openFile(self):
        fileDialog = QFileDialog()
        fileDialog.setFileMode(QFileDialog.ExistingFile)
        fileDialog.setNameFilter("*.asm")
        if fileDialog.exec():
            filePath = fileDialog.selectedFiles()[0]
            with open(filePath, 'r') as file:
                content = file.read()
                self.codeEditor.setPlainText(content)

    def setTableVerticalHeader(self, table, cells):
        for i in range(cells):
            table.setItem(i,0, QTableWidgetItem(""))
            item = QTableWidgetItem()
            item.setData(0,i)
            table.setVerticalHeaderItem(i,item)

def main():
    app = QApplication(sys.argv)
    mipsIde = mipsIDE()
    sys.exit(app.exec())

if __name__ == '__main__':
    main()