# To-Do List
IMPORTANTE:
    - Los localparam, por convencion son en mayuscula y nosotros lo escribiamos en minuscula.
    - Agregar esto al git, en la parte de NAMES.md (tal vez, modificar algun README.md). 

### Primer review
1. **En alu_module.v, no estan carry, zero, etc.**
2. ~~En baudrg_module.v, definir el tema de contreg_next.~~
3. ~~En fifo_module.v, no usa `timescale y el nuestro no tenia caso de default.~~
4. ~~En interface_module.v, no usa `timescale, tiene una señal o_is_valid que no se usa en ningun lado (sacar?) y el nuestro tenia los LEDs.~~
5. ~~En rx_module.v, nuestro o_rxmodule_DOUT era signed, ¿por que rxmodule_bitsreasreg se llama asi?, tenemos distintas condiciones para el IDLE (solo marco la dif).~~
6. ~~En tx_module.v, no usa `timescale.~~
7. ~~Tanto en TX como en RX, en los begin del always@(*) comienzan con el X_nextstatereg = X_statereg, y los nuestros los tenian despues del algo_algo_XDONE (Para tener en cuenta).~~
8. ~~En uart_module.v, (Creo que la cague en los nombres de las funciones de las instancias) no usa `timescale, tiene parameter PTR_LEN = 2 que nosotro no teniamos (revisar, creo que es nuestro NB_UARTMODULE_ADDR, pero 2 en lugar de 4, onda se usa en lugares similares), nuestro i_uartmodule_fifotx_WRITEDATA y o_uartmodule_fiforx_READDATA eran signed, nosotros no teniamos wire tx_not_empty (agregamos, sacamos?, me parece que nosotros usamos el ~tx_empty), al final de todo asigna assign tx_not_empty = ~uartmodule_emptywire (revisar).~~
9. ~~En top_module.v, no se usa `timescale, tiene parameter PTR_LEN = 2 que nosotro no teniamos (revisar, creo que es nuestro NB_UARTMODULE_ADDR, pero 2 en lugar de 4, onda se usa en lugares similares), muchos wire nuestro eran signed, aparece la funcion o_is_valid() (revisar), como orden hace uart-interface-alu y nosotros teniamos alu-uart-interface (solo marco la dif).~~
10. En constraints.xdc, ya se cambio el nombre de las señales de RX y TX.

### Segunda review
11. ~~Cambiar los localparam con nombre mas chicos + state al final, + cambiar en git.~~
12. ~~En baudrg_module.v seguir la logica del tp newest.~~
13. ~~En fifo agregar timescale y en todos los demas. (a menos que se rompa todo)~~
14. ~~Sacamos cosas.~~
15. ~~En uart_module.v, cambiar los ptr_len a la logica del pibe, y lo del emprywire usar nuestra logica ya negada.~~

### Tercer review
16. Se arreglaron todos los localparam para cumplir con la convencion (falta en git).
17. En baudrg_module.v, ya se modificaron los nombres y estamos OK.
18. Todavia no se agregan los timescale en los lugares donde no estaban (comparando con nuestra logica anterior).
19. En interface_module.v y en top_module.v, se saco la señal o_is_valid().
20. Todavia no se agregan los signed en los lugares donde no estaban (rx_module.v, uart_module.v, top_module.v).
21. En uart_module.v, ya se modifico el nombre del parameter PTR_LEN a NB_UARTMODULE_ADDR, se saco de la signal declaration el tx_not_empty() y se mantuvo nuestra logica anterior (negando _emptywire).
22. En top_module.v, ya se modifico el nombre del parameter PTR_LEN a NB_UARTMODULE_ADDR.
23. CONFIRMAMOS: Todo funciona joya.

### Cuarta review
24. Para poner en funcionamiento el Clock Wizard se modifico:
    - top_module.v -> el parameter MOD_TOPMODULE_M = 326 por parameter MOD_TOPMODULE_M = 163.
    - uart_module.v -> el parameter MOD_UARTMODULE_M = 326 por parameter MOD_UARTMODULE_M = 163.
    - baudrg_module.v -> el parameter MOD_BAUDRGMODULE_M = 326 por parameter MOD_BAUDRGMODULE_M = 163.

### Quinta review
25. Ya atacado el README.md:
    - Hecho lo de FIFO.
    - Hecho lo del clock wizard.