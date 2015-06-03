section .bss
buff resb 7

section .data


section .text
  global _start
  
_start: 

mov byte[buff + 0], 'A'
mov byte[buff + 1], 'B'
mov byte[buff + 2], 'C'
mov byte[buff + 3], 'D'
mov byte[buff + 4], 'E'
mov byte[buff + 5], 'F'
mov byte[buff + 6], 'G'

mov rax, 1
mov rdi, 1
mov rsi, buff
mov rdx, 7
syscall

RotateLeftRotorMacro buff, 3	; linea 26

mov rax, 1
mov rdi, 1
mov rsi, buff
mov rdx, 7
syscall

exit:
  mov rax, 60
  mov rdi, 0
  syscall
  
  
%Macro RotateLeftRotorMacro 2
  push rax
  push rbx
  push rdx
  xor rax, rax
  xor rbx, rbx 
  
  %%begin:
      cmp %2, 0                                   ; si parametro 2 (numero de rotates) = 0, se acaban los movimientos
      je %%exit                                        
      mov al, byte[%1]                            ; al = valor a inicial que va al final
  
  %%ciclo:
      cmp byte[%1 + rbx + 1], 00h                 ; para saber si estoy apuntando al último dígito del buffer     
      je %%agregarDigito
      
      mov dl, byte[%1 + rbx + 1]                  ; guarda el valor a intercambiar
      mov byte[%1 + rbx], dl                      ; intercambia el valor con el anterior
      inc rbx                                      ; incrementa contador
      jmp %%ciclo
      
   %%agregarDigito:                                 ; agrega al final el dígito que al inició estaba de primero
      mov byte[%1 + rbx], al                      ; mueve el primer dígito al final
      dec %2                                      ; decremento el número de veces que tengo que hacer el ciclo
      mov rbx, 0                                   ; para volver a recorrer el buffer
      jmp %%begin
      
  %%exit:
      pop rdx
      pop rbx
      pop rax
      ret
%ENDMACRO