SECTION .data 

ErrMsg 	db "Terminated with error.",10
ERRLEN equ $-ErrMsg

saltoLinea: db "", 10, 0			; saltoLinea
saltoLineaLargo: equ $-saltoLinea

SECTION .bss 

MAXARGS equ 3 				; Máximo de argumentos soportados
ArgCount: resq 1 			; Números de argumentos pasados al programa
ArgPtrs: resq MAXARGS 			; Tabla de punteros a los argumentos
ArgLens: resq MAXARGS 			; Tabla de los largos de los argumentos


NombreArch1: resq 100					; Nombre del argumento número 1	
lenNombreArch1 equ $ - NombreArch1

NombreArch2: resq 100					; Nombre del argumentos número 2
lenNombreArch2 equ $ - NombreArch2

textoFinal: resq 1024					; Texto contenido en el archivo número 1
lenTextoFinal equ $ - textoFinal

textoFinal2: resq 1024					; Texto contenido en el archivo número 2
lenTextoFinal2 equ $ - textoFinal2

buffRotoresSeleccionados: resq 1024					; Buffer con los rotores seleccionados
lenBuffRotores equ $ - buffRotoresSeleccionados

buffDesplazamientoRotores: resq 1024					; Buffer con los rotores seleccionados
lenBuffDesplazamientoRotores equ $ - buffDesplazamientoRotores

plugboard: resq 1024					; Buffer donde está la codificación del plugboard
lenPlugboard equ $ - plugboard

SECTION .text 			

global _start

_start:

	; Toma el argumento de la línea de comando de la pila y lo valida

	pop rcx 	                		; Contiene el contador de argumentos
	mov qword [ArgCount], rcx 			; Guarda la cantidad de argumentos en memoria

	xor rdx,rdx 						; Contador para sacar los argumentos 

SaveArgs:
	pop qword [ArgPtrs + rdx * 8] 		; Pop an arg addr into the memory table
	inc rdx 	                        ; Bump the counter to the next arg addr
	cmp rdx, rcx 						; Is the counter = the argument count?
	jb SaveArgs 						; If not, loop back and do another

	; With the argument pointers stored in ArgPtrs, we calculate their lengths:
	xor eax,eax 			; Searching for 0, so clear AL to 0
	xor ebx,ebx 			; Pointer table offset starts at 0

ScanOne:
	mov rcx,000000000000ffffh 	; Limit search to 65535 bytes max
	mov rdi,qword [ArgPtrs + rbx * 8]	; Put address of string to search in EDI
	mov rdx, rdi 			; Copy starting address into EDX

	cld 				; Set search direction to up-memory
	repne scasb 			; Search for null (0 char) in string at edi
	jnz Error 			; REPNE SCASB ended without finding AL

	mov byte [rdi-1],10 		; Store an EOL where the null used to be
	sub rdi, rdx 			; Subtract position of 0 from start address
	mov qword [ArgLens + ebx * 8],rdi; Put length of arg into table
	inc rbx 			        ; Add 1 to argument counter
	cmp rbx, [ArgCount] 		; See if arg counter exceeds argument count
	jb ScanOne 			; If not, loop back and do another one

	; Display all arguments to stdout:
	xor rbx,rbx 			; Start (for table addressing reasons) at 0

Showem:
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

		mov rsi,[ArgPtrs + 2 * 8] 	; Pasa la dirección a la que está apuntando el segundo argumento al rsi

		xor r9, r9 ; Contador para sacar el nombre de la pila y meterlo en el buffer
		mov r9, 0

	.ciclo2:
		cmp byte[rsi + r9], 10          ;Se compara el primer caracter de la pila con un salto de linea
		je .abrir_leer                  ; Si es igual, pasa a revisar el otro archivo de la pila
		mov al, byte[rsi + r9]          ; Si no es igual. mueve el byte al AL
		mov byte[NombreArch2 + r9], al  ; Luego mueve lo que hay en AL, al primer byte del buffer NombreArch1
		inc r9
		jmp .ciclo2                     ; Vuelve de nuevo al ciclo para seguir revisando la pila

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

	xor r10, r10
	mov r10, -1

	xor r9, r9
	mov r9, 0

	.limpiar_orden_rotores:
		inc r10
		cmp byte[textoFinal + r10], 10
		je .limpiar_comienzo_rotores_aux
		cmp byte[textoFinal + r10], ' '
		je .limpiar_orden_rotores
		mov al, byte[textoFinal + r10]   ; Si no es igual. mueve el byte al AL
		mov byte[buffRotoresSeleccionados + r9], al  ; Luego mueve lo que hay en AL, al primer byte del buffer
		inc r9
		jmp .limpiar_orden_rotores      ; Vuelve de nuevo al ciclo para seguir revisando la pila

	.limpiar_comienzo_rotores_aux:

	xor r9, r9
	mov r9, 0

	.limpiar_comienzo_rotores:
		inc r10
		cmp byte[textoFinal + r10], 10
		je .limpiar_plugboard_aux
		cmp byte[textoFinal + r10], ' '
		je .limpiar_comienzo_rotores
		mov al, byte[textoFinal + r10]   	; Si no es igual. mueve el byte al AL
		mov byte[buffDesplazamientoRotores + r9], al  ; Luego mueve lo que hay en AL, al primer byte
		inc r9
		jmp .limpiar_comienzo_rotores      ; Vuelve de nuevo al ciclo para seguir revisando la pila

	.limpiar_plugboard_aux:

	xor r9, r9
	mov r9, 0

	.limpiar_plugboard:
		inc r10
		cmp byte[textoFinal + r10], 0h
		je .imprimir
		cmp byte[textoFinal + r10], ' '
		je .limpiar_plugboard
		cmp byte[textoFinal + r10], ','
		je .limpiar_plugboard
		mov al, byte[textoFinal + r10]   ; Si no es igual. mueve el byte al AL
		mov byte[plugboard + r9], al  ; Luego mueve lo que hay en AL, al primer byte 
		inc r9
		jmp .limpiar_plugboard      ; Vuelve de nuevo al ciclo para seguir revisando la pila


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
	mov rax, 1 			; Specify sys_write call
	mov rdi, 1 			; Specify File Descriptor 2: Standard Error
	mov rsi, ErrMsg 			; Pass offset of the error message
	mov rdx, ERRLEN 			; Pass the length of the message
	syscall

Exit: 
	mov rax, 60 			; Code for Exit Syscall
	mov rdi, 0 			; Return a code of zero
	syscall
	
