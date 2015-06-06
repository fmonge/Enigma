SECTION .data 

ErrMsg 	db "Terminated with error.",10
ERRLEN equ $-ErrMsg

saltoLinea: db "", 10, 0			; saltoLinea
saltoLineaLargo: equ $-saltoLinea

rotor1: db "EKMFLGDQVZNTOWYHXUSPAIBRCJ"				; R
rotor2: db "AJDKSIRUXBLHWTMCQGZNPYFVOE"				; O
rotor3: db "BDFHJLCPRTXVZNYEIWGAKMUSQO"				; T
rotor4: db "ESOVPZJAYQUIRHXLNFTGKDCMWB"				; O
rotor5: db "VZBRGITYUPSDNHLXAWMJQOFECK"				; RES
reflector: db "JPGVOUMFYQBENHZRDKASXLICTW"

SECTION .bss 
;;;;;;;;;;,
temp: resb 1
;;;;;;;;;;
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

buffRotoresSeleccionados: resq 8					; Buffer con los rotores seleccionados
lenBuffRotores equ $ - buffRotoresSeleccionados

buffDesplazamientoRotores: resq 1024					; Buffer con los rotores seleccionados
lenBuffDesplazamientoRotores equ $ - buffDesplazamientoRotores

plugboard: resq 1024					; Buffer donde está la codificación del plugboard
lenPlugboard equ $ - plugboard

despTemp resb 3                              ; para guardar el cada desplazamiento y convertirlo en int
buffNumRomano resb 4						        ; buffer donde se guardan el número romano
buffRotorLen equ 27						           ; solo un len porque todos los rotores tiene el mismo tamaño
buffRotorUno resb buffRotorLen					; buffer donde se carga el primer rotor seleccionado
buffRotorDos resb buffRotorLen					; buffer donde se carga el segundo rotor seleccionado
buffRotorTres resb buffRotorLen					; buffer donde se carga el tercer rotor seleccionado


SECTION .text 			

global _start

_start:

	; Toma el argumento de la línea de comando de la pila y lo valida
CargarArchivoABuffer:
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
			;je .exit
			je .imprimir
			cmp byte[textoFinal + r10], ' '
			je .limpiar_plugboard
		;	cmp byte[textoFinal + r10], ','
		;	je .limpiar_plugboard
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
				
				
				mov rax, 1
				mov rdi, 1
				mov rsi, buffRotorUno
				mov rdx, 27
				syscall

				mov rax, 1
				mov rdi, 1
				mov rsi, saltoLinea
				mov rdx, saltoLineaLargo
				syscall
				
				mov rax, 1
				mov rdi, 1
				mov rsi, buffRotorDos
				mov rdx, 27
				syscall

				mov rax, 1
				mov rdi, 1
				mov rsi, saltoLinea
				mov rdx, saltoLineaLargo
				syscall
				
				mov rax, 1
				mov rdi, 1
				mov rsi, buffRotorTres
				mov rdx, 27
				syscall

				mov rax, 1
				mov rdi, 1
				mov rsi, saltoLinea
				mov rdx, saltoLineaLargo
				syscall
				
				mov rax, 1
				mov rdi, 1
				mov rsi, saltoLinea
				mov rdx, saltoLineaLargo
				syscall

			.exit:
				;jmp Exit

call CargarRotoresSeleccionados
call RotarRotores

Exit: 
	mov rax, 60 			; Code for Exit Syscall
	mov rdi, 0 			; Return a code of zero
	syscall
	


Error: 
	push rax
	push rdi
	push rsi
	push rdx

	mov rax, 1 			; Specify sys_write call
	mov rdi, 1 			; Specify File Descriptor 2: Standard Error
	mov rsi, ErrMsg 			; Pass offset of the error message
	mov rdx, ERRLEN 			; Pass the length of the message
	syscall

	pop rdx
	pop rsi
	pop rdi
	pop rax
	ret	
    
;------CargarRotoresSeleccionados------;
;                                      ;
; Carga los rotores seleccionados      ;
; en los distintos buffers             ;
; (uno, dos y tres) respectivamente    ;
;                                      ;
; Parametros: rsi = buffer con rotores ;
; Salida: los buffers de los rotores   ;
;         ya cargados                  ;
;______________________________________;
CargarRotoresSeleccionados:    
    push rcx
    push rax
    push rsi
    push rdi
    push r8
    push r9
    xor rsi, rsi
    mov rcx, 1							; contador para saber en cual buffer cargar el rotor seleccionado
    
    .begin:
        cmp byte[buffRotoresSeleccionados + rsi], 00h		; si se llega al final del buffer que contiene los rotores
        je .exit						                    ; sale del procedimiento
	       
        mov r8, buffRotoresSeleccionados        ;parametros para CargarNumeroABuffer
        mov r9, buffNumRomano
	      call CargarNumeroABuffer				; va a cargar el número que el rsi esté apuntando
        
        mov rax, buffNumRomano					; parametro del procedimiento CambiarRomanoADecimal
        call CambiarRomanoADecimal				
        mov rax, buffNumRomano
        call LimpiarBuff				
        push rsi						; se guarda el rsi (contador de los números de rotores seleccionados)						
        call AsignarRotorSeleccionado				
        call AsignarBufferDeRotorSeleccionado
        call CargarRotorABuffer
        pop rsi							; se retorna rsi para seguir apuntando al buff de rotores
        
        inc rcx							; incrementa contador para saber en cual buffer cargar el rotor
        jmp .begin
        
    .exit:
        pop r9
        pop r8
	pop rdi
        pop rsi
        pop rax
        pop rcx
        ret
        
;----------AsignarRotorSeleccionado-------------;
;                                               ;
; Asigna al rsi el rotor que se debe pasar      ;
;                                               ;
; Parametros: rdx = número de rotor             ;
; salida: rsi = apuntando al rotor seleccionado ;
;_______________________________________________;
AsignarRotorSeleccionado:
    cmp rdx, 1							; si el rdx es 1 es porque
    je .SeleccionarRotorUno					; hay que cargar el rotor1
    
    cmp rdx, 2							; si el rdx es 2 es porque
    je .SeleccionarRotorDos					; hay que cargar el rotor2
    
    cmp rdx, 3							; si el rdx es 3 es porque
    je .SeleccionarRotorTres					; hay que cargar el rotor3
    
    cmp rdx, 4							; si el rdx es 4 es porque
    je .SeleccionarRotorCuatro					; hay que cargar el rotor4
    
    cmp rdx, 5							; si el rdx es 5 es porque
    je .SeleccionarRotorCinco					; hay que cargar el rotor5
    
    .SeleccionarRotorUno:
        mov rsi, rotor1						; rsi = rotor1
        jmp .exit
        
    .SeleccionarRotorDos:
        mov rsi, rotor2						; rsi = rotor2
        jmp .exit
         
    .SeleccionarRotorTres:
        mov rsi, rotor3						; rsi = rotor3
        jmp .exit
        
    .SeleccionarRotorCuatro:
        mov rsi, rotor4						; rsi = rotor4
        jmp .exit
        
    .SeleccionarRotorCinco:
        mov rsi, rotor5						; rsi = rotor5
        jmp .exit
        
    .exit:
        ret


;------AsignarBufferDeRotorSeleccionado-----;
;                                           ;
; Asigna al rdi el buffer para guardar      ;
; el rotor asignado                         ;
;                                           ;
; Parametros: rcx = número del buffer       ;
; salida: rdi = buffer para meter el rotor  ;
;___________________________________________;
AsignarBufferDeRotorSeleccionado:
    cmp rcx, 1							; si rcx = 1 entonces
    je .bufferRotorUno						; el buffer a cargar es el primero
    
    cmp rcx, 2							; si rcx = 1 entonces
    je .bufferRotorDos						; el buffer a cargar es el segundo
    
    cmp rcx, 3							; si rcx = 1 entonces
    je .bufferRotorTres						; el buffer a cargar es el tercero
    
    .bufferRotorUno:
        mov rdi, buffRotorUno 					; rdi = buffRotorUno
        jmp .exit
        
    .bufferRotorDos:
        mov rdi, buffRotorDos 					; rdi = buffRotorDos
        jmp .exit
        
    .bufferRotorTres:
        mov rdi, buffRotorTres  				; rdi = buffRotorTres
        jmp .exit
        
    .exit:
        ret


;------------CargarNumeroABuffer-------------;
;                                            ;
; Cargar el primer número romano que         ;
; encuentre en el buffer de rotores          ;
; seleccionados a el buffer del              ;
; número romano                              ;
;                                            ;    
; Parametros: rsi = cont de num romanos      ;
;             r8 = buffer con numeros        ;
;             r9 = buffer a depositar numero ;                                
; Salida: buffer del número, cargado         ;                                   
;____________________________________________;
CargarNumeroABuffer:
    push rax
    push rcx
    xor rcx, rcx
    
    .begin:
        cmp byte[r8 + rsi], 00h             ; si se llegó al final del buffer de numeros
        je .exit                            ; entonces sale del procedimiento
           
        cmp byte[r8 + rsi], ','             ; si encuentre una ',', entonces terminó de leer un número
        je .nextNum                         ; y salta para mover el rsi y elminar esa ','
        
        mov al, byte[r8 + rsi]              ; mueve al 'al' el dígito del número del rotor
        mov byte[r9 + rcx], al              ; guarda un dígito del número actual que esté leyendo al buffer para guardarlo
        
        inc rcx                             ; contador del buffer del número actual
        inc rsi                             ; incrementa contador del buffer de números
        jmp .begin                          ; si no ha terminado de leer, comienza de nuevo
    
    .nextNum:
        inc rsi                             ; esto es por si se encontró una ',', y dejar el 
                                            ; contador apuntando en el siguiente número 
    .exit:
        pop rcx
        pop rax
        ret


;---------cargarRotorABuffer---------;
;                                    ;
; Cargar un rotor a un buffer        ;
;                                    ;
; Parametros: rdi = buffer a cargar  ;
; 	      rsi = rotor            ;
; Salida: ---                        ;
;____________________________________;
CargarRotorABuffer:
  push rcx
  
  xor rcx, rcx
  mov rcx, 26                  ; cantidad de letras en un rotor
  rep movsb                    ; copia lo que tenga el rsi en el rdi, 26 veces (hasta que el rcx sea 0)
  
  pop rcx
  ret
  

;-----------CambiarRomanoADecimal------------;
;                                            ;
; Devuelve el equivalente decimal del número ;
; romano (del 1 al 5)                        ;
;                                            ;
; parametros: rax = buffer con número Romano ;
; salida: rdx = número decimal               ;
;____________________________________________;
;nota: este método solo sirve para los números 
; romanos del 1 al 5 (los únicos posibles en 
; la progra), por eso es tan estático
CambiarRomanoADecimal:  
    xor rdx, rdx				; para guardar el número decimal
     
    cmp byte[rax], 'V'				; si en la primera posición del número romano hay una 'V'
    je .cinco					; quiere decir que es un 5
    
    cmp byte[rax + 1], 'V'			; si en la segunda posición del número romano hay una 'V'
    je .cuatro					; quiere decir que es un 4
  
    cmp byte[rax + 2], 'I'		        ; si en la tercera posición del número romano hay una 'I'
    je .tres					; quiere decir que es un 3
    
    cmp byte[rax + 1], 'I'			; si en la segunda posición del número romano hay una 'I'
    je .dos					; quiere decir que es un 2
    
    mov rdx, 1				        ; si ninguno de los casos anteriores es verdad, significa que es un 1
    jmp .exit					; (el único caso que quedaba por evaluar) y lo mueve al rdx
    
    .dos:
        mov rdx, 2				; mueve 2 decimal a rdx
        jmp .exit
        
    .tres:
        mov rdx, 3				; mueve 3 decimal a rdx
        jmp .exit
    
    .cuatro:
        mov rdx, 4				; mueve 4 decimal a rdx
        jmp .exit
    
    .cinco:
        mov rdx, 5				; mueve 5 decimal a rdx
        jmp .exit
    
    .exit:
        ret


;--------LimpiarBuffNumRomano--------;
;                                    ;
; Limpia el buffer que               ;
; tiene le número romano             ;
;                                    ;
; Parametros: rax = buffer a limpiar ;
; Salida: ---                        ;
;____________________________________;
LimpiarBuff:
    push rsi
    xor rsi, rsi
    .begin:
        cmp byte[rax + rsi], 00h                ; si encuentra un nulo, ya terminó el buffer
        je .exit
        
        mov byte[rax + rsi], 00h                ; inserta nulo en la posición actual
        inc rsi                                 ; incrementa contador
        jmp .begin
    .exit:
        pop rsi
        ret    
    

;-------------RotateLeftRotor-------------;
;                                         ;
; Aplica un rotate left a un buffer       ;
; n cantidad de veces                     ;
;                                         ;
; Parametros: rsi = buffer                ;
;             rcx = n cantidad de rotates ;
; Salida: buffer con rotates              ;
;_________________________________________;
RotateLeftRotor:  
  push rax
  push rbx
  push rdx
  xor rax, rax
  xor rbx, rbx
  
  .begin:
      cmp rcx, 0                                   ; si rcx = 0, se acaban los movimientos
      je .exit                                        
      mov al, byte[rsi]                            ; al = valor a inicial que va al final
  
  .ciclo:
      cmp byte[rsi + rbx + 1], 00h                 ; para saber si estoy apuntando al último dígito del buffer     
      je .agregarDigito
      
      mov dl, byte[rsi + rbx + 1]                  ; guarda el valor a intercambiar
      mov byte[rsi + rbx], dl                      ; intercambia el valor con el anterior
      inc rbx                                      ; incrementa contador
      jmp .ciclo
      
   .agregarDigito:                                 ; agrega al final el dígito que al inició estaba de primero
      mov byte[rsi + rbx], al                      ; mueve el primer dígito al final
      dec rcx                                      ; decremento el número de veces que tengo que hacer el ciclo
      mov rbx, 0                                   ; para volver a recorrer el buffer
      jmp .begin
      
  .exit:
      pop rdx
      pop rbx
      pop rax
      ret


;---------------RotarRotores---------------;
;                                          ;
; Desplaza los rotores n cantidad de veces ;
;                                          ;
; Parametros:                              ;
; Salida: rotores desplazados              ;
;__________________________________________;
RotarRotores:
  push rcx
  push rsi
  push r8
  push r9
  push rbx
  xor rsi, rsi
  mov rbx, 1                                          ; contador para referenciar los rotores

  .begin:
    cmp byte[buffDesplazamientoRotores + rsi], 00h    ; si es nulo, terminó de leer los deplazamientos
    je .exit

    mov r8, buffDesplazamientoRotores                 ; mueve buffer con desplazamientos al r8
    mov r9, despTemp                                  ; mueve buffer temporal para deplazamiento al r9
    call CargarNumeroABuffer                          ; cargar el primer número que se encuentre al despTemp

    mov r8, despTemp                                  ; mueve buffer temporal para deplazamiento al r8
    call Atoi                                         ; convierte despTemp al integer
    
    mov rax, despTemp                                 ; mueve buffer temporar al rax para limpiarlo
    call LimpiarBuff
    
    push rsi                                          ; salva posición actual del buffer de deplazamientos
    mov rcx, rdx                                      ; mueve cantidad de rotaciones al rcx

    cmp rbx, 1                                        ; si el rbx es 1
    je .selectRotorUno                                ; hay que rotar el rotor 1

    cmp rbx, 2                                        ; si el rbx es 2
    je .selectRotorDos                                ; hay que rotar el rotor 2

    cmp rbx, 3                                        ; si el rbx es 3
    je .selectRotorTres                               ; hay que rotar el rotor 3

    .selectRotorUno:                
      mov rsi, buffRotorUno                           ; asiga buffer de rotor uno para rotarlo
      jmp .rotar                                      ; rotar

    .selectRotorDos:
      mov rsi, buffRotorDos                           ; asiga buffer de rotor dos para rotarlo
      jmp .rotar                                      ; rotar
      
    .selectRotorTres:
      mov rsi, buffRotorTres                          ; asiga buffer de rotor tres para rotarlo
      jmp .rotar                                      ; rotar
      
    .rotar:
      call RotateLeftRotor                            ; rotar
      
    pop rsi                                           ; vuelve la posición actual del buffer de desplazamientos
    inc rbx                                           ; incrementa número de referencia de rotor
    jmp .begin

  .exit:
    pop rbx
    pop r9
    pop r8
    pop rsi
    pop rcx
    ret
;--------------------Atoi--------------------;
;                                            ;
; Convierte Alfanumericos de un buffer       ;
; a integers                                 ;
;                                            ;
; Parametros; r8 = buff con numero a cambiar ;
; Salida: rdx = número decimal               ;
;____________________________________________;
Atoi:             
    push rax
    push rbx
    push rsi
    push rdi
    
    xor rsi, rsi
    xor rax,rax
    xor rbx, rbx
    xor rdx, rdx
    xor rdi, rdi
    
    .begin:
        mov al, byte[r8 + rsi]
        cmp al, 00h                       ; compara si es nulo
        je .exit                          ; si es nulo, sale del procedimiento
    
        cmp al, 30h                       ; compara con '0'
        jb .exit                          ; sale si es menor
        
        cmp al, 39h                       ; compara con '9'
        ja .exit                          ; sale si es mayor  
        
        sub al, 30h                       ; resta 30h para convertir en número
        
        mov rdi, rax
        inc rsi                           ; incrementa contador
        jmp .seguir
        
    .seguir:
        mov al, byte[r8 + rsi]            ; compara el siguiente caracter
        cmp al, 00h                       ; si es nulo, sale del procedimiento
        je .exit
        
        mov rax, rdx                      ; muevo al rax para multiplicarlo
        mov rbx, 10
        mul rbx                           ; multiplica al por bl
        mov rdx, rax                      ; muevo resultado de la multiplicación al rdx
        add rdx, rdi                      ; sumo el resultado al rdi
        jmp .begin
        
    .exit:
                                          ; para tomar el último número
        mov rax, rdx                      
        mov rbx, 10
        mul rbx
        mov rdx, rax
        add rdx, rdi
        
        pop rdi
        pop rsi
        pop rbx
        pop rax
        ret
      
