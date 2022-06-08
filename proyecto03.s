/* -----------------------------------------------
* UNIVERSIDAD DEL VALLE DE GUATEMALA 
* Organizacion de computadoras y Assembler
* Ciclo 1 - 2022
*
* Brian Anthony Carrillo Monzon 21108
* Josue Isaac Morales Gonzalez 21116
* Carlos Edgardo Lopez Barrera 21666
*
* proyecto03.s
* Programa: Acumulador de bits.
*
 ----------------------------------------------- */

/* REPRESENTACION
    (no. pin) - (# wPI)  - (GPIO Rpi)   - (pin fisico) = (dispositivo)
	 pin 0     -   0	  -   GPIO 17	 -      11	    = LED 1 
	 pin 1     -   1      -   GPIO 18    -      12      = LED 2
	 pin 2     -   2      -   GPIO 27    -      13      = LED 3 
	 pin 3     -   3      -   GPIO 22    -      15      = LED 4
	 pin 4     -   4      -   GPIO 23    -      16      = LED 5
	 pin 5     -   5      -   GPIO 24    -      18      = LED 6
	 pin 6     -   6      -   GPIO 25    -      22      = LED 7
	 pin 7     -   7      -   GPIO 4     -      7       = LED 8
	 pin 8     -   21     -   GPIO 5     -      29      = push button
     pin 9     -   22     -   GPIO 6     -      31      = sensor de movimiento
     pin 10    -   25     -   GPIO 26    -      37      = LED Jugador 1
     pin 11    -   27     -   GPIO 16    -      36      = LED Jugador 2
*/


.data
.balign 4

@@ Definicion de mensajes
Intro: 	 .asciz  "Raspberry Pi wiringPi blink test\n"
ErrMsg:	 .asciz	"Setup didn't work... Aborting...\n"
@@ Periodo (2s por ciclo)
delayMs: .int	2000
@@ valor de output para pin
OUTPUT	 =	1
INPUT	 =	0
@@Contadores de jugadores
contadorJ1: .word 0
contadorJ2: .word 0
ganador: .word 0

type_entrada: .asciz "%c"
entrada: .byte 0

mensaje_final: .asciz "\nPuntuaciones: Jugador 1: %d - Jugador 2: %d\n"
mensaje_reinicio: .asciz "Presione [q] para reiniciar o acerque su mano al sensor."
mensaje_ingreso: .asciz "Jugador 1: Presione el pulsador. Jugador 2: Presione [d]."
mensaje_ganadorj1: .asciz "Jugador 1 ha ganado."
mensaje_ganadorj2: .asciz "Jugador 2 ha ganado."

	.text
	.global main
    @@ Importaciones
	.extern printf
	.extern wiringPiSetup
	.extern delay
	.extern digitalWrite
	.extern pinMode

main:   push 	{ip, lr}
	bl	wiringPiSetup			// Inicializar libreria wiringpi
	mov	r1,#-1					// -1 representa un codigo de error
	cmp	r0, r1					// verifica si se retorno codigo de error en r0
	bne	init					// NO error, entonces iniciar programa
	ldr	r0, =ErrMsg				// SI error, 
	bl	printf					// Imprimir mensaje
	b	done

init:
    @@ ------------------------------------------------------
    @@ Contador de cicloPinMode - OUTPUT
    mov r4, #0
    @@ Ultimo pin
    mov r5, #7

    @@ Ciclo de modos de pin - OUTPUT
	cicloPinMode_output:
    @@ pinMode(pin, 1);
    mov r0, r4
    mov	r1, #OUTPUT				// lo configura como salida, r1 = 1
	bl	pinMode					// llama funcion wiringpi para configurar
    
    @@ Incremento de contador
    add r4, #1
    cmp r4, r5
    ble cicloPinMode_output

    @@ ------------------------------------------------------
    @@ Contador de cicloPinMode - INPUT
    mov r4, #21
    @@ Ultimo pin
    mov r5, #22

    @@ Ciclo de modos de pin - INPUT
	cicloPinMode_input:
    @@ pinMode(pin, 0);
    mov r0, r4
    mov	r1, #INPUT				// lo configura como entrada, r1 = 0
	bl	pinMode					// llama funcion wiringpi para configurar
    
    @@ Incremento de contador
    add r4, #1
    cmp r4, r5
    ble cicloPinMode_input

    @@ ------------------------------------------------------
    @@ Contador de cicloPinMode - OUTPUT
    mov r4, #25
    @@ Ultimo pin
    mov r5, #27

    @@ Ciclo de modos de pin - OUTPUT
	cicloPinMode_output_jugador:
    @@ pinMode(pin, 1);
    mov r0, r4
    mov	r1, #OUTPUT				// lo configura como salida, r1 = 1
	bl	pinMode					// llama funcion wiringpi para configurar
    
    @@ Incremento de contador
    add r4, #2
    cmp r4, r5
    ble cicloPinMode_output_jugador

    secuencia:
    @@ ------------------------------------------------------
    @@ Contador de ciclo forLoop (i=0)
    mov r4, #0
    @@ Cantidad de ciclos -1
    mov r5, #7

    @@ Mensaje indicacion de controles secuencia
    ldr r0,=mensaje_ingreso
    bl puts

    @@ Ciclo de encendido de leds
    forLoop:
    @------- if gpio in == 1		// si se activa pulsador entrada gpio5
    try:
	@------- delay(2000)	
	ldr	r0, =delayMs
	ldr	r0, [r0]
	bl	delay
	
    @@ Lectura entrada push button
	mov r0, #21                  // carga direccion de pin entrada push button
	bl 	digitalRead				// lectura de entrada
	cmp	r0, #0
    bne contar_J1

    @@ Lectura entrada por teclado
    ldr r0,=type_entrada
    ldr r1,=entrada
    bl scanf
    ldr r6,=entrada
    ldrb r6,[r6]
    cmp r6,#'d'
    bne try
    beq contar_J2

    @@ Sumatoria en el contador del Jugador 1
    contar_J1:
    ldr r0,=contadorJ1
    ldr r7,[r0]
    add r7,#1
    str r7,[r0]
    @@ Determinacion ganador ultimo estado
    ldr r8,=ganador
    ldr r9,[r8]
    cmp r4, #7
    bne fin_entrada
    add r9, #1
    str r9,[r8]
    bl fin_entrada

    @@ Sumatoria en el contador del Jugador 2
    contar_J2:
    ldr r0,=contadorJ2
    ldr r7,[r0]
    add r7,#1
    str r7,[r0]
    @@ Determinacion ganador ultimo estado
    ldr r8,=ganador
    ldr r9,[r8]
    cmp r4, #7
    bne fin_entrada
    add r9, #2
    str r9,[r8]
    bl fin_entrada

    fin_entrada:
    @ digitalWrite(pin, 1);		
	mov r0, r4
	mov	r1, #1
	bl 	digitalWrite			// escribe 1 en pin para activar puerto GPIO

    @@ Incremento de contador
    add r4, #1
    cmp r4, r5
    ble forLoop

    @@ Impresion en pantalla de puntajes
    ldr r0,=mensaje_final
    ldr r1,=contadorJ1
    ldr r1,[r1]
    ldr r2,=contadorJ2
    ldr r2,[r2]
    bl printf

    @@ Comparacion de puntajes de Jugadores
    ldr r1,=ganador
    ldr r1,[r1]
    cmp r1, #1
    beq ganadorJ1
    cmp r1, #2
    beq ganadorJ2

    @@ Encendido LED Jugador 1
    ganadorJ1:
    @ digitalWrite(25, 1);		
	mov r0, #25
	mov	r1, #1
	bl 	digitalWrite			// escribe 1 en pin para activar puerto GPIO
    @@ Mensaje Jugador 1 ganador
    ldr r0,=mensaje_ganadorj1
    bl puts
    bl reiniciar

    @@ Encendido LED Jugador 2
    ganadorJ2:
    @ digitalWrite(27, 1);		
	mov r0, #27
	mov	r1, #1
	bl 	digitalWrite			// escribe 1 en pin para activar puerto GPIO
    @@ Mensaje Jugador 2 ganador
    ldr r0,=mensaje_ganadorj2
    bl puts
    bl reiniciar

    reiniciar:
    @@ Mensaje indicacion de controles reinicio
    ldr r0,=mensaje_reinicio
    bl puts

    @------- if gpio in == 0		// si se activa sensor entrada gpio6
    try2:
	@------- delay(2000)	
	ldr	r0, =delayMs
	ldr	r0, [r0]
	bl	delay
	
    @@ Lectura entrada push button
	mov r0, #22                  // carga direccion de pin entrada sensor de movimiento
	bl 	digitalRead				// lectura de entrada
	cmp	r0, #1
	bne limpiar

    @@ Lectura entrada por teclado
    ldr r0,=type_entrada
    ldr r1,=entrada
    bl scanf
    ldr r6,=entrada
    ldrb r6,[r6]
    cmp r6,#'q'
    bne try2

    limpiar:
    @@ Contador de cicloLimpiar
    mov r4, #0
    @@ Cantidad de ciclos -1
    mov r5, #7

    @@ Ciclo de apagado de leds
    cicloLimpiar:
    @ digitalWrite(pin, 0);
    mov r0, r4
    mov	r1, #0
    bl 	digitalWrite			// escribe 0 en pin para desactivar puerto GPIO
    
    @@ Incremento de contador
    add r4, #1
    cmp r4, r5
    ble cicloLimpiar

    @@ Contador de cicloLimpiar_Jugador
    mov r4, #25
    @@ Ultimo pin
    mov r5, #27

    @@ Ciclo de apagado de leds Jugador
    cicloLimpiar_jugador:
    @ digitalWrite(pin, 0);
    mov r0, r4
    mov	r1, #0
    bl 	digitalWrite			// escribe 0 en pin para desactivar puerto GPIO
    
    @@ Incremento de contador
    add r4, #2
    cmp r4, r5
    ble cicloLimpiar_jugador

    @@ Reinicio de indicadores
    ldr r0,=ganador
    ldr r1,[r0]
    mov r1, #0
    str r1,[r0]

    ldr r0,=contadorJ1
    ldr r1,[r0]
    mov r1, #0
    str r1,[r0]

    ldr r0,=contadorJ2
    ldr r1,[r0]
    mov r1, #0
    str r1,[r0]

    bl init

@@ Finalizacion de programa    
done:	
        pop 	{ip, pc}


