NOMBRES DE LAS VARIABLES:  
En todas las variables(excepto en clock y reset) va el nombre del modulo(es el mismo nombre que le asignamos pero sin el guion bajo)
  
PARÁMETROS:  
todo en mayúscula, el nombre del modulo que quede en el medio preferentemente
- Ejemplo: NB_FIFOMODULE_DATA
  
PUERTOS:  
1. input(i) u output(o) ← minuscula
2. un guion bajo
3. nombre del modulo, todo junto ← minuscula
4. un guion bajo
5. nombre descriptivo de la variable ← MAYUSCULA
- Ejemplo: i_fifomodule_WRITEDATA
  
ESTADOS:  
1. nombre del modulo, todo junto ← minuscula
2. guion bajo
3. nombre del estado, seguido de la palabra “state”. todo junto ← minuscula
- Ej: rxmodule_stopstate
  
REGISTROS O WIRES QUE NO SON PUERTOS:  
Para registros:  
1. nombre del modulo ← minuscula
2. guion bajo
3. nombre descriptivo, seguido de la palabra “reg”. todo junto ← minuscula
- Ej: rxmodule_samptickreg
  
Para wires:  
1. nombre del modulo ← minuscula
2. guion bajo
3. nombre descriptivo, seguido de la palabra “wire”. todo junto ← minuscula
- Ej: uartmodule_maxtickwire
  
EN CASO DE QUE LA VARIABLE TENGA SU “NEXT”, colocar el next al inicio, seguido de lo mismo de antes:
- ej: rxmodule_samptickreg → rxmodule_nextsamptickreg
  
SEÑAL DE CLOCK Y RESET  
siempre las vamos a definir de estas maneras ya que no dependen del modulo en el que se creen xq siempre son la misma señal:
- i_clk ← minuscula
- i_reset ← minuscula
