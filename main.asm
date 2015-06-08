%include "lib.asm"
%include "string.mac"
%include "cifrado.mac"

section .bss
despTemp resb 3                              ; para guardar el cada desplazamiento y convertirlo en int
buffNumRomano resb 4						        ; buffer donde se guardan el número romano
buffRotorLen equ 27						           ; solo un len porque todos los rotores tiene el mismo tamaño
buffRotorUno resb buffRotorLen					; buffer donde se carga el primer rotor seleccionado
buffRotorDos resb buffRotorLen					; buffer donde se carga el segundo rotor seleccionado
buffRotorTres resb buffRotorLen					; buffer donde se carga el tercer rotor seleccionado

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

buffDesplazamientoRotores: resq 9					; Buffer con los rotores seleccionados
lenBuffDesplazamientoRotores equ $ - buffDesplazamientoRotores

plugboard: resq 1024					; Buffer donde está la codificación del plugboard
lenPlugboard equ $ - plugboard

bufTmp:	resb 1024
bufTextTmp: resb 1024

textoCifrado: resb 1024
lenTextoCifrado: equ $ - textoCifrado

section .data
newline:	db 0x0A
rotor1: db "EKMFLGDQVZNTOWYHXUSPAIBRCJ"				; R
rotor2: db "AJDKSIRUXBLHWTMCQGZNPYFVOE"				; O
rotor3: db "BDFHJLCPRTXVZNYEIWGAKMUSQO"				; T
rotor4: db "ESOVPZJAYQUIRHXLNFTGKDCMWB"				; O
rotor5: db "VZBRGITYUPSDNHLXAWMJQOFECK"				; RES
reflector: db "JPGVOUMFYQBENHZRDKASXLICTW"

ErrMsg 	db "Terminated with error.",10
ERRLEN equ $-ErrMsg

saltoLinea: db "", 10, 0			; saltoLinea
saltoLineaLargo: equ $-saltoLinea


section .text
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
	
 
  call CargarArchivos			; carga los archivos de configuración y la frase a encriptar
  call CargarRotoresSeleccionados	; carga los rotores que se selccionen en la configuración 
  call RotarRotores			; rota los rotores hasta las posiciones iniciales
  
  ; comienza el cifrado
  xor rdi, rdi
  xor rdx, rdx
  xor rax, rax
  xor rbx, rbx
  xor r15, r15
  xor r13, r13
  dec r15
  .loop:	
	inc r15
	mov al, byte[textoFinal2+r15]	; textoFinal2 = palabra a cifrar
	mov [textoCifrado], al

	plugboardM 1, plugboard		;XF,PZ,SQ,GR,AJ,UO,CN,BV,TM,Ki
	call printText ;call rotores	;rbx ==> puntero-cont recorre el bufer
	rotoresM buffRotorUno, 1
	call printText
	rotoresM buffRotorDos, 2
	call printText
	rotoresM buffRotorTres, 3
	call printText
	rotoresM reflector, 0
	call printText
	rotoresOutM buffRotorTres, 3, r15
	call printText
	rotoresOutM buffRotorDos, 2, r15
	call printText
	rotoresOutM buffRotorUno, 1, r15
	call printText
	plugboardM 1024, plugboard	
	call printText
	print newline, 1
	cmp r15, r8
	jne .loop
	exit
	
  printText:
	print newline, 1
	  print textoCifrado, textoFinal2	
	  lea rsi, [textoFinal2]
	  lea rdi, [textoCifrado]			
	  ret
  ;;prueba para saber que todo está bien
  ;call ImprimirRotores
  ;;
  
  call Exit
 
