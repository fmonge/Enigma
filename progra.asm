section .bss
despTemp resb 3                      ; para guardar el cada desplazamiento y convertirlo en int
buffNumRomano resb 4				 ; buffer donde se guardan el número romano
buffRotorLen equ 27					 ; solo un len porque todos los rotores tiene el mismo tamaño
buffRotorUno resb buffRotorLen		 ; buffer donde se carga el primer rotor seleccionado
buffRotorDos resb buffRotorLen		 ; buffer donde se carga el segundo rotor seleccionado
buffRotorTres resb buffRotorLen		 ; buffer donde se carga el tercer rotor seleccionado

;;;;;;;;Para el test;;;;;;;;;;;;;;;;;;;;;;;;;;;
buffRotoresSeleccionados resb 8
buffDesplazamientoRotores resb 9
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .data
rotor1: db "EKMFLGDQVZNTOWYHXUSPAIBRCJ"				; R
rotor2: db "AJDKSIRUXBLHWTMCQGZNPYFVOE"				; O
rotor3: db "BDFHJLCPRTXVZNYEIWGAKMUSQO"				; T
rotor4: db "ESOVPZJAYQUIRHXLNFTGKDCMWB"				; O
rotor5: db "VZBRGITYUPSDNHLXAWMJQOFECK"				; RES
reflector: db "JPGVOUMFYQBENHZRDKASXLICTW"

section .text
  global _start
  
_start:
    mov rbp, rsp; for correct debugging
  
  ;;;;;;;;Para simular el buffer que tiene los rotores seleccionados y los corrimientos (parte de liza y Meli);;;;;;;;;;;
  mov byte[buffRotoresSeleccionados + 0], 'I'
  mov byte[buffRotoresSeleccionados + 1], ','
  mov byte[buffRotoresSeleccionados + 2], 'I'
  mov byte[buffRotoresSeleccionados + 3], 'I'
  mov byte[buffRotoresSeleccionados + 4], 'I'
  mov byte[buffRotoresSeleccionados + 5], ','
  mov byte[buffRotoresSeleccionados + 6], 'V'

  mov byte[buffDesplazamientoRotores + 0], '1'
  mov byte[buffDesplazamientoRotores + 1], '3'
  mov byte[buffDesplazamientoRotores + 2], ','
  mov byte[buffDesplazamientoRotores + 3], '1'
  mov byte[buffDesplazamientoRotores + 4], ','
  mov byte[buffDesplazamientoRotores + 5], '2'
  mov byte[buffDesplazamientoRotores + 6], '2'
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  call CargarRotoresSeleccionados
  call RotarRotores
 
  exit:
    mov rax, 60
    mov rdi, 0
    syscall
    
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
    mov rcx, 1											; contador para saber en cual buffer cargar el rotor seleccionado
    
    .begin:
        cmp byte[buffRotoresSeleccionados + rsi], 00h	; si se llega al final del buffer que contiene los rotores
        je .exit						                ; sale del procedimiento
	       
        mov r8, buffRotoresSeleccionados        		;parametros para CargarNumeroABuffer
        mov r9, buffNumRomano
	      call CargarNumeroABuffer						; va a cargar el número que el rsi esté apuntando
        
        mov rax, buffNumRomano							; parametro del procedimiento CambiarRomanoADecimal
        call CambiarRomanoADecimal				
        mov rax, buffNumRomano
        call LimpiarBuff				
        push rsi										; se guarda el rsi (contador de los números de rotores seleccionados)						
        call AsignarRotorSeleccionado				
        call AsignarBufferDeRotorSeleccionado
        call CargarRotorABuffer
        pop rsi											; se retorna rsi para seguir apuntando al buff de rotores
        
        inc rcx											; incrementa contador para saber en cual buffer cargar el rotor
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
    je .SeleccionarRotorUno				; hay que cargar el rotor1
    
    cmp rdx, 2							; si el rdx es 2 es porque
    je .SeleccionarRotorDos				; hay que cargar el rotor2
    
    cmp rdx, 3							; si el rdx es 3 es porque
    je .SeleccionarRotorTres			; hay que cargar el rotor3
    
    cmp rdx, 4							; si el rdx es 4 es porque
    je .SeleccionarRotorCuatro			; hay que cargar el rotor4
    
    cmp rdx, 5							; si el rdx es 5 es porque
    je .SeleccionarRotorCinco			; hay que cargar el rotor5
    
    .SeleccionarRotorUno:
        mov rsi, rotor1					; rsi = rotor1
        jmp .exit
        
    .SeleccionarRotorDos:
        mov rsi, rotor2					; rsi = rotor2
        jmp .exit
         
    .SeleccionarRotorTres:
        mov rsi, rotor3					; rsi = rotor3
        jmp .exit
        
    .SeleccionarRotorCuatro:
        mov rsi, rotor4					; rsi = rotor4
        jmp .exit
        
    .SeleccionarRotorCinco:
        mov rsi, rotor5					; rsi = rotor5
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
    je .bufferRotorUno					; el buffer a cargar es el primero
    
    cmp rcx, 2							; si rcx = 1 entonces
    je .bufferRotorDos					; el buffer a cargar es el segundo
    
    cmp rcx, 3							; si rcx = 1 entonces
    je .bufferRotorTres					; el buffer a cargar es el tercero
    
    .bufferRotorUno:
        mov rdi, buffRotorUno 			; rdi = buffRotorUno
        jmp .exit
        
    .bufferRotorDos:
        mov rdi, buffRotorDos 			; rdi = buffRotorDos
        jmp .exit
        
    .bufferRotorTres:
        mov rdi, buffRotorTres  		; rdi = buffRotorTres
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
     
    cmp byte[rax], 'V'			; si en la primera posición del número romano hay una 'V'
    je .cinco					; quiere decir que es un 5
    
    cmp byte[rax + 1], 'V'		; si en la segunda posición del número romano hay una 'V'
    je .cuatro					; quiere decir que es un 4
  
    cmp byte[rax + 2], 'I'		; si en la tercera posición del número romano hay una 'I'
    je .tres					; quiere decir que es un 3
    
    cmp byte[rax + 1], 'I'		; si en la segunda posición del número romano hay una 'I'
    je .dos						; quiere decir que es un 2
    
    mov rdx, 1				    ; si ninguno de los casos anteriores es verdad, significa que es un 1
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
        cmp byte[rax + rsi], 00h      ; si encuentra un nulo, ya terminó el buffer
        je .exit
        
        mov byte[rax + rsi], 00h      ; inserta nulo en la posición actual
        inc rsi                       ; incrementa contador
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
      
;-------------RotateLeftRotor Macro-------;
;                                         ;
; Aplica un rotate left a un buffer       ;
; n cantidad de veces                     ;
;                                         ;
; Parametros: %1 = buffer                 ;
;             %2 = n cantidad de rotates  ;
; Salida: buffer con rotates              ;
;_________________________________________;  

%Macro RotateLeftRotor 2
  push rax
  push rbx
  push rdx
  xor rax, rax
  xor rbx, rbx 
  
  %%begin:
      cmp %2, 0                          ; si parametro 2 (numero de rotates) = 0, se acaban los movimientos
      je %%exit                                        
      mov al, byte[%1]                   ; al = valor a inicial que va al final
  
  %%ciclo:
      cmp byte[%1 + rbx + 1], 00h        ; para saber si estoy apuntando al último dígito del buffer     
      je %%agregarDigito
      
      mov dl, byte[%1 + rbx + 1]         ; guarda el valor a intercambiar
      mov byte[%1 + rbx], dl             ; intercambia el valor con el anterior
      inc rbx                            ; incrementa contador
      jmp %%ciclo
      
   %%agregarDigito:                      ; agrega al final el dígito que al inició estaba de primero
      mov byte[%1 + rbx], al             ; mueve el primer dígito al final
      dec %2                             ; decremento el número de veces que tengo que hacer el ciclo
      mov rbx, 0                         ; para volver a recorrer el buffer
      jmp %%begin
      
  %%exit:
      pop rdx
      pop rbx
      pop rax
      ret
%ENDMACRO