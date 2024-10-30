# Paso a paso de la implementacion del Clock Wizard

### Primer paso
Se debe crear el clock desde la pestaña de **Project Manager**, en la sección de **IP Catalog**.
<p align="center">
    <img src=".\imgs\clkwiz_paso1.jpg"><br>
    <em>Fig 1.Paso 1</em>
</p>


### Segundo paso
En la pestaña lateral (donde solemos ver el código), se abrirá el **IP Catalog**, en donde bajo la carpeta de **FPGA Features and Design**, **Clocking**, abriremos la sección **Clocking wizard**.
<p align="center">
    <img src=".\imgs\clkwiz_paso2.jpg"><br>
    <em>Fig 2.Paso 2</em>
</p>


### Tercer paso
Se abrirá una nueva ventana (que en nuestro caso es Re-customice IP), en donde se configura o parametriza el clock wizard. En la pestaña de **Board** se define el nombre del clock (clk_wiz_0), y se define que el CLK_IN1 (que es una entrada del módulo de clock wizard), y se cambia a sys clock.
<p align="center">
    <img src=".\imgs\clkwiz_paso3.jpg"><br>
    <em>Fig 3.Paso 3</em>
</p>


### Cuarto paso
En pestaña de **Clocking Options**, verificaremos al final de la misma que en **Input Clock Information**, **Input Clock**, qué Primary sea el clock definido por default y sea de 100 MHz. 
<p align="center">
    <img src=".\imgs\clkwiz_paso4.jpg"><br>
    <em>Fig 4.Paso 4</em>
</p>


### Quinto paso
En la pestaña de **Output Clocks**, se definirá el clock que se necesite. Se tilda la casilla de clk_out1, y se coloca la frecuencia, verificando que clock wizard lo verifique como válido o no (en algunas frecuencias muy altas, no se puede).
<p align="center">
    <img src=".\imgs\clkwiz_paso5.jpg"><br>
    <em>Fig 5.Paso 5</em>
</p>


### Sexto paso
En la pestaña de **Port Renamming** es posible renombrar el puerto de locked, que es la señal de control de loop cerrado que nos aporta el seleccionar PLL en la primer pestaña. No es necesario en este caso.
<p align="center">
    <img src=".\imgs\clkwiz_paso6.jpg"><br>
    <em>Fig 6.Paso 6</em>
</p>


### Séptimo paso
No se harán cambios por el momento en la pestaña de **MCMM Settings**.
En la pestaña de **Summary**, se verifica que las configuraciones del clock sean correctas, y por último se presiona OK.
<p align="center">
    <img src=".\imgs\clkwiz_paso7.jpg"><br>
    <em>Fig 7.Paso 7</em>
</p>


### Octavo paso
Ahora ya se generó el módulo de clock, lo cual se puede ver en la pestaña **Sources**.
Ahora hay que instanciar este módulo, como cualquier otro. Dentro de esta pestaña, se selecciona **IP Sources**.
<p align="center">
    <img src=".\imgs\clkwiz_paso8.jpg"><br>
    <em>Fig 8.Paso 8</em>
</p>


### Noveno paso
Dentro de la carpeta **IP**, **clk_wiz_o**, **Instantiation Template**, en **clk_wiz_0.veo** es donde se encuentra el código generado por el Clock Wizard para instancias en el top_module.v, el clock generado como se hizo antes con los demás módulos.
<p align="center">
    <img src=".\imgs\clkwiz_paso9.jpg"><br>
    <em>Fig 9.Paso 9</em>
</p>


### Decimo paso
En una nueva pestaña, se abrirá el archivo **clk_wiz_0.veo**, donde se ve la porción de código de la implementacion del módulo de clock.
<p align="center">
    <img src=".\imgs\clkwiz_paso10.jpg"><br>
    <em>Fig 10.Paso 10</em>
</p>

Por último, solo se debe copiar y pegar esta porción de código, cambiar `instance_name` por el nombre correspondiente, y reemplazar las señales necesarias tanto dentro de la porción de codigo como del top_module.v.


En cuanto a los constraints.xdc, para evitar tener Critical Warnings de Vivado, se recomienda utilizar una versión simplificada del clock default, que la propuesta por parte del [Repositorio de Digilent-xdc](https://github.com/Digilent/digilent-xdc/blob/master/Nexys-4-DDR-Master.xdc).

```VHDL
set_property IOSTANDARD LVCMOS33 [get_ports i_clk]
set_property PACKAGE_PIN E3 [get_ports i_clk]
```
