%include "lib.asm"



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

  call CargarArchivos
  call CargarRotoresSeleccionados
  call RotarRotores
  
  call Exit
 