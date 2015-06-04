SECTION .data 

ErrMsg 	db "Terminated with error.",10
ERRLEN equ $-ErrMsg

saltoLinea: db "", 10, 0			; saltoLinea
saltoLineaLargo: equ $-saltoLinea

SECTION .bss 

MAXARGS 	equ 3							; Máximo de argumentos soportados
ArgCount: 	resq 1 							; Números de argumentos pasados al programa
ArgPtrs: 	resq MAXARGS 					; Tabla de punteros a los argumentos
ArgLens: 	resq MAXARGS 					; Tabla de los largos de los argumentos


;;;;;;;;;;;;;;;BUFFERS PARA GUARDAR EL NOMBRE DE LOS ARCHIVOS QUE SE DAN COMO ARGUMENTOS;;;;;;;;;;;;;;;;;;;;

NombreArch1: 	resq 100					; Nombre del argumento número 1	
lenNombreArch1 	equ $ - NombreArch1

NombreArch2: 	resq 100					; Nombre del argumentos número 2
lenNombreArch2 	equ $ - NombreArch2

;;;;;;;;;;;;;;;;;;BUFFERS PARA GUARDAR EL TEXTO QUE ESTÁ DENTRO DE LOS ARCHIVOS 1 Y 2;;;;;;;;;;;;;;;;;;;;;;;

textoFinal: 	resq 1024					; Texto contenido en el archivo número 1
lenTextoFinal 	equ $ - textoFinal

textoFinal2: 	resq 1024					; Texto contenido en el archivo número 2
lenTextoFinal2 	equ $ - textoFinal2

;;;;;;;;;;;;;;;BUFFERS PARA GUARDAR CADA ARGUMENTO EN BUFFERS SEPARADOS PARA MEJOR MANIPULACIÓN;;;;;;;;;;;;;

buffRotoresSeleccionados: resq 1024					; Buffer con los rotores seleccionados
lenBuffRotores equ $ - buffRotoresSeleccionados

buffDesplazamientoRotores: resq 1024				; Buffer con las posiciones de inicio de los rotores
lenBuffDesplazamientoRotores equ $ - buffDesplazamientoRotores

plugboard: resq 1024								; Buffer donde está la codificación del plugboard
lenPlugboard equ $ - plugboard

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SECTION .text 			

global _start

_start:

	; Toma el argumento de la línea de comando de la pila y lo valida

	pop rcx 	                		; Contiene el contador de argumentos
	mov qword [ArgCount], rcx 			; Guarda la cantidad de argumentos en memoria

	xor rdx, rdx 						; Contador para sacar los argumentos 

GuardarArgumentos:
	pop qword [ArgPtrs + rdx * 8] 		; Saca la dirección a la que apunta el argumento y lo pone en la tabla de memoria
	inc rdx 	                        ; Incrementa el contador para direccionar el siguiente argumento
	cmp rdx, rcx 						; Verifica si el contador es igual que el contador de argumentos
	jb GuardarArgumentos 				; Si no lo es, entonces vuelve al loop y verifica otra vez

	; With the argument pointers stored in ArgPtrs, we calculate their lengths:
	xor eax, eax 			
	xor ebx, ebx 

EscaneoUno:
	mov rcx, 000000000000ffffh 			; El límite de búsqueda es de 65535 bytes máximo
	mov rdi, qword [ArgPtrs + rbx * 8]	; Mete la dirección del string a buscar en el RDI
	mov rdx, rdi 						; Copia la dirección de inicio en el RDX

	cld 								; Pone la bandera de dirección en clear (hacia arriba)
	repne scasb 						; Busca por caracteres nulos en el string que está en RDI
	jnz Error 							; REPNE SCASB terminado sin encontrar AL

	mov byte [rdi-1],10 				; Guarda un EOL donde el nulo estaba antes
	sub rdi, rdx 						; Resta la posición de 0 al comienzo de la dirección
	mov qword [ArgLens + ebx * 8],rdi	; Pone el largo del argumento en la tabla
	inc rbx 			        		; Aumenta en 1 el contador de argumentos
	cmp rbx, [ArgCount] 				; Verifica si el contador sobrepasa al contador de argumentos
	jb EscaneoUno 						; Si no, sigue buscando más argumentos

	xor rbx,rbx 

;;;;;;;;;;;;;;;;;;;;;;;;GUARDA LOS NOMBRES DE LOS ARGUMENTOS PASADOS AL PROGRAMA;;;;;;;;;;;;;;;;;;;;;;;;

Mostrar:
	mov rsi,[ArgPtrs + 1 * 8] 			; Pasa la dirección a la que está apuntando el primer argumento al rsi

	xor r9, r9							; Contador para sacar el nombre de la pila y meterlo en un buffer
	mov r9, 0

	.ciclo1:
		cmp byte[rsi + r9], 10			; Se compara el primer caracter de la pila con un salto de línea
		je .siguiente					; Si es igual, pasa a revisar el otro archivo de la pila
		mov al, byte[rsi + r9]			; Si no es igual. mueve el byte al AL
		mov byte[NombreArch1 + r9], al	; Luego mueve lo que hay en AL, al primer byte del buffer NombreArch1
		inc r9					
		jmp .ciclo1						; Vuelve de nuevo al ciclo para seguir revisando la pila

	.siguiente:

		mov rsi,[ArgPtrs + 2 * 8] 		; Pasa la dirección a la que está apuntando el segundo argumento al rsi

		xor r9, r9 						; Contador para sacar el nombre de la pila y meterlo en el buffer
		mov r9, 0

	.ciclo2:
		cmp byte[rsi + r9], 10          ; Se compara el primer caracter de la pila con un salto de linea
		je .abrir_leer                  ; Si es igual, pasa a revisar el otro archivo de la pila
		mov al, byte[rsi + r9]          ; Si no es igual. mueve el byte al AL
		mov byte[NombreArch2 + r9], al  ; Luego mueve lo que hay en AL, al primer byte del buffer NombreArch1
		inc r9
		jmp .ciclo2                     ; Vuelve de nuevo al ciclo para seguir revisando la pila

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;ABRIR Y LEER LOS ARCHIVOS CON RESPECTO AL NOMBRE DE LOS ARCHIVOS;;;;;
	.abrir_leer:

	; Abrir y leer el archivo 1
		mov rax, 2
		mov rdi, NombreArch1
		mov rsi, 0
		mov rdx, 0
		syscall

		mov rbx, rax

		mov rax, 0
		mov rdi, rbx
		mov rsi, textoFinal
		mov rdx, lenTextoFinal
		syscall

	; Abrir y leer el archivo 2 
		mov rax, 2
		mov rdi, NombreArch2
		mov rsi, 0
		mov rdx, 0
		syscall

		mov rbx, rax

		mov rax, 0
		mov rdi, rbx
		mov rsi, textoFinal2
		mov rdx, lenTextoFinal2
		syscall

		mov rax, 3
		syscall

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Se limpian los contadores para poder recorrer los buffers donde se va a insertar las líneas y del que se sacan las líneas nuevas
	xor r10, r10
	mov r10, -1

	xor r9, r9
	mov r9, 0

;;;;;; LIMPIEZA DE BUFFERS, SE QUITAN ESPACIOS EN BLANCO Y COMAS QUE NO SE NECESITEN PARA TENER LOS BUFFER LISTOS;;;;;;;;;;

	.limpiar_orden_rotores:

		inc r10
		cmp byte[textoFinal + r10], 10					; Se compara el primer caracter del primer archivo con un salto de línea
		je .limpiar_comienzo_rotores_aux				; Si es igual, entonces pasa a la limpieza del siguiente buffer
		cmp byte[textoFinal + r10], ' '					; Si no, se compara con un espacio en blanco
		je .limpiar_orden_rotores						; Si es igual, se ignora y se aumenta el contador del archivo

		mov al, byte[textoFinal + r10]   				; Si no es igual, mueve el byte del documento al AL
		mov byte[buffRotoresSeleccionados + r9], al  	; Luego mueve lo que hay en AL, al primer byte del buffer
		inc r9
		jmp .limpiar_orden_rotores      				; Vuelve de nuevo al ciclo para seguir revisando el buffer del archivo primero

	.limpiar_comienzo_rotores_aux:
		xor r9, r9
		mov r9, 0

	.limpiar_comienzo_rotores:

		inc r10
		cmp byte[textoFinal + r10], 10					; Se compara el caracter del primer archivo con un salto de línea
		je .limpiar_plugboard_aux						; Si es igual, entonces pasa a la limpieza del siguiente buffer
		cmp byte[textoFinal + r10], ' '					; Si no, se compara con un espacio en blanco
		je .limpiar_comienzo_rotores					; Si es igual, se ignora y se aumenta el contador del archivo

		mov al, byte[textoFinal + r10]   				; Si no es igual, mueve el byte del documento al AL
		mov byte[buffDesplazamientoRotores + r9], al  	; Luego mueve lo que hay en AL, al primer byte
		inc r9
		jmp .limpiar_comienzo_rotores      				; Vuelve de nuevo al ciclo para seguir revisando la pila

	.limpiar_plugboard_aux:
		xor r9, r9
		mov r9, 0

	.limpiar_plugboard:

		inc r10
		cmp byte[textoFinal + r10], 0h					; Se compara el caracter del primer archivo con un caracter nulo
		je .imprimir									; Si es igual, entonces imprime el contenido de los 3 buffers
		cmp byte[textoFinal + r10], ' '					; Si no, se compara con un espacio en blanco				
		je .limpiar_plugboard							; Si es igual, se ignora y se aumenta el contador del archivo
		cmp byte[textoFinal + r10], ','					; Se compara el caracter del primer archivo con un caracter de coma
		je .limpiar_plugboard							; Si es igual, se ignora y se aumenta el contador del archivo

		mov al, byte[textoFinal + r10]   				; Si no es igual, mueve el byte del documento al AL
		mov byte[plugboard + r9], al  					; Luego mueve lo que hay en AL, al primer byte 
		inc r9
		jmp .limpiar_plugboard      					; Vuelve de nuevo al ciclo para seguir revisando la pila

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.imprimir:

	;Se imprimen los buffer para ver si están bien
		mov rax, 1
		mov rdi, 1
		mov rsi, buffRotoresSeleccionados
		mov rdx, lenBuffRotores
		syscall

		mov rax, 1
		mov rdi, 1
		mov rsi, saltoLinea
		mov rdx, saltoLineaLargo
		syscall

		mov rax, 1
		mov rdi, 1
		mov rsi, buffDesplazamientoRotores
		mov rdx, lenBuffDesplazamientoRotores
		syscall

		mov rax, 1
		mov rdi, 1
		mov rsi, saltoLinea
		mov rdx, saltoLineaLargo
		syscall

		mov rax, 1
		mov rdi, 1
		mov rsi, plugboard
		mov rdx, lenPlugboard
		syscall

		mov rax, 1
		mov rdi, 1
		mov rsi, saltoLinea
		mov rdx, saltoLineaLargo
		syscall

		call Exit

Error: 
	mov rax, 1 			; sys_write
	mov rdi, 1 			; File Descriptor
	mov rsi, ErrMsg 	; String que contiene el error
	mov rdx, ERRLEN 	; Largo del mensaje de error
	syscall

Exit: 
	mov rax, 60 		; Código de Salida del Syscall
	mov rdi, 0 			; Retorna un código de cero
	syscall
	
