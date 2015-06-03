section .bss
buffNumRomano resb 3
buffRotorLen equ 26
buffRotorUno resb buffRotorLen
buffRotorDos resb buffRotorLen
buffRotorTres resb buffRotorLen

;;;;;;;;Para el test;;;;;;;;;;;;;;;;;;;;;;;;;;;
buffRotoresSeleccionados resb 7
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

section .data
rotor1: db "EKMFLGDQVZNTOWYHXUSPAIBRCJ"
rotor2: db "AJDKSIRUXBLHWTMCQGZNPYFVOE"
rotor3: db "BDFHJLCPRTXVZNYEIWGAKMUSQO"
rotor4: db "ESOVPZJAYQUIRHXLNFTGKDCMWB"
rotor5: db "VZBRGITYUPSDNHLXAWMJQOFECK"
reflector: db "JPGVOUMFYQBENHZRDKASXLICTW"

section .text
  global _start
  
_start:
  
  ;;;;;;;;Para simular el buffer que tiene los rotores seleccionados (parte de liza y Meli);;;;;;;;;;;
  mov byte[buffRotoresSeleccionados + 0], 'I'
  mov byte[buffRotoresSeleccionados + 1], ','
  mov byte[buffRotoresSeleccionados + 2], 'I'
  mov byte[buffRotoresSeleccionados + 3], 'I'
  mov byte[buffRotoresSeleccionados + 4], 'I'
  mov byte[buffRotoresSeleccionados + 5], ','
  mov byte[buffRotoresSeleccionados + 6], 'V'
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  call CargarRotoresSeleccionados
  
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
    xor rsi, rsi
    mov rcx, 1
    .begin:
        cmp byte[buffRotoresSeleccionados + rsi], 00h
        je .exit
	  
	call CargarNumeroDeRotor				; va a cargar el número que el rsi esté apuntando
        
        mov rax, buffNumRomano
        call CambiarRomanoADecimal
        call LimpiarBuffNumRomano
        push rsi						; se guarda el rsi (contador de los números de rotores seleccionados)						
        call AsignarRotorSeleccionado
        call AsignarBufferDeRotorSeleccionado
        call CargarRotorABuffer
        pop rsi
        
        inc rcx
        jmp .begin
        
    .exit:
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
    cmp rdx, 1
    je .SeleccionarRotorUno
    
    cmp rdx, 2
    je .SeleccionarRotorDos
    
    cmp rdx, 3
    je .SeleccionarRotorTres
    
    cmp rdx, 4
    je .SeleccionarRotorCuatro
    
    cmp rdx, 5
    je .SeleccionarRotorCinco
    
    .SeleccionarRotorUno:
        mov rsi, rotor1
        jmp .exit
        
    .SeleccionarRotorDos:
        mov rsi, rotor2
        jmp .exit
         
    .SeleccionarRotorTres:
        mov rsi, rotor3
        jmp .exit
        
    .SeleccionarRotorCuatro:
        mov rsi, rotor4
        jmp .exit
        
    .SeleccionarRotorCinco:
        mov rsi, rotor5
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
    cmp rcx, 1
    je .bufferRotorUno
    
    cmp rcx, 2
    je .bufferRotorDos
    
    cmp rcx, 3
    je .bufferRotorTres
    
    .bufferRotorUno:
        mov rdi, buffRotorUno 
        jmp .exit
        
    .bufferRotorDos:
        mov rdi, buffRotorDos
        jmp .exit
        
    .bufferRotorTres:
        mov rdi, buffRotorTres 
        jmp .exit
        
    .exit:
        ret

;----------CargarNumeroDeRotor----------;
;                                       ;
; Cargar el primer número romano que    ;
; encuentre en el buffer de rotores     ;
; seleccionados a el buffer del         ;
; número romano                         ;
;                                       ;    
; Parametros: rsi = cont de num romanos ;                               
; Salida: buffer de num romano, cargado ;                                   
;_______________________________________;
CargarNumeroDeRotor:
    push rax
    push rcx
    xor rcx, rcx
    
    .begin:
        cmp byte[buffRotoresSeleccionados + rsi], 00h
        je .exit
           
        cmp byte[buffRotoresSeleccionados + rsi], ','
        je .nextNum
        
        mov al, byte[buffRotoresSeleccionados + rsi]
        mov byte[buffNumRomano + rcx], al
        
        inc rcx
        inc rsi
        jmp .begin
    
    .nextNum:
        inc rsi                    ; esto es por si se encontró una ',', y dejar el 
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
  rep movsb                    ; copia lo que tenga el rsi en el rdi, 26 veces
  
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
CambiarRomanoADecimal:  
    xor rdx, rdx
    
    cmp byte[rax], 'V'
    je .cinco
    
    cmp byte[rax + 1], 'V'
    je .cuatro
  
    cmp byte[rax + 2], 'I'
    je .tres
    
    cmp byte[rax + 1], 'I'
    je .dos
    
    mov rdx, 1
    jmp .exit
    
    .dos:
        mov rdx, 2
        jmp .exit
        
    .tres:
        mov rdx, 3
        jmp .exit
    
    .cuatro:
        mov rdx, 4
        jmp .exit
    
    .cinco:
        mov rdx, 5
        jmp .exit
    
    .exit:
        ret

;--LimpiarBuffNumRomano--;
;                        ;
; Limpia el buffer que   ;
; tiene le número romano ;
;                        ;
; Parametros: ---        ;
; Salida: ---            ;
;________________________;
LimpiarBuffNumRomano:
    mov byte[buffNumRomano + 0], 00h
    mov byte[buffNumRomano + 1], 00h
    mov byte[buffNumRomano + 2], 00h
    ret    