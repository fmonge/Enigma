;****************************************
;*	Tecnológico de Costa Rica	*
;*	Ingeniería en Computación	*
;*	Arquitectura de Computadoras	*
;*	Profe:       			*
;*	Erick Hernández Bonilla 	*
;*	Proyecto:       		*
;*	Máquina Enigma en Ensamblador 	*
;*	Alumnos:    			*
;*	Melissa Molina 2013006074	*
;*	Liza Chaves Carranza 2013016573	*
;*	Fabián Monge			*
;*	Gabreiel Pizarro 201216833	*
;****************************************
%include "string.mac"
%include "cifrado.mac"

section .bss
	bufTmp:	resb 1024
	lenBufTmp:	equ $ - bufTmp

	bufRotorTmp:	resb 26
	lenBufRotorTmp:	equ $ - bufRotorTmp

	textIn:		resb 1024
	lenTextIn:	equ $ - textIn
	textoCifrado:	resb 1024
	lenTextoCifrado:	equ $ - textoCifrado

 	;plugboard:      resb 29
	;lenPlugboard:   equ $ - plugboard
	; ejemplo de blugboard:
	; XF,PZ,SQ,GR,AJ,UO,CN,BV,TM,KI

section .data
	
	newline:	db 0x0A
	rotorUno:       db 'EKMFLGDQVZNTOWYHXUSPAIBRCJ'
	lenRotores:	equ $ - rotorUno
	rotorDos:       db 'AJDKSIRUXBLHWTMCQGZNPYFVOE'
	rotorTres:      db 'BDFHJLCPRTXVZNYEIWGAKMUSQO'
	plugboard:	db 'XF,PZ,SQ,GR,AJ,UO,CN,BV,TM,KI'
;	plugboard:	db 'XFPZSQGRAJUOCNBVTMKI'
	
	
	rotorI:       	db 'EKMFLGDQVZNTOWYHXUSPAIBRCJ'
	rotorII:       	db 'AJDKSIRUXBLHWTMCQGZNPYFVOE'
	rotorIII:      	db 'BDFHJLCPRTXVZNYEIWGAKMUSQO'
	rotorIV:  	db 'ESOVPZJAYQUIRHXLNFTGKDCMWB'
	rotorV:   	db 'VZBRGITYUPSDNHLXAWMJQOFECK'
	reflector:      db 'EJMZALYXVBWFCRQUONTSPIKHGD'
	;reflectorB:	db 'YRUHQSLDPXNGOKMIEBFZCWVJAT'
	;reflectorC:	db 'FVPJIAOYEDRZXWGCTKUQSBNMHL'
	;estatico:	db 'ABCDEFHGIJKLMNOPQRSTUVWXYZ'



	;plugboard:	resb 29
	;lenPlugboard: 	equ $ - plugboard
	; ejemplo de blugboard:
		;XF,PZ,SQ,GR,AJ,UO,CN,BV,TM,Ki

section .text
	global _start

_start:
	xor rdi, rdi
	xor rdx, rdx
	xor rax, rax
	xor rbx, rbx
	leer textIn, lenTextIn	;len de lectura --> rax
	mov rcx, rax
	dec rcx			;quitar 0x0A	
	xor r8, r8
	mov r8, rcx

	movBuf textoCifrado, textIn		; mov textoCifrado, textIn	
	;; call copiarBuf

;	plugboardM lenTextIn, plugboard	;XF,PZ,SQ,GR,AJ,UO,CN,BV,TM,Ki

	;; rotaciones iniciales ******
	rotarBuf rotorUno, 1
	print rotorUno, lenRotores	

 	call printText
	
			;call rotores	;rbx ==> puntero-cont recorre el bufer
	rotoresM rotorUno, 1 ; de tamaño r8, 
	call printText
	rotoresM rotorDos, 2
	call printText
	rotoresM rotorTres, 3
	call printText
	rotoresM reflector, 0
	call printText
	rotoresM rotorTres, 3
	call printText
	rotoresM rotorDos, 2
	call printText
	rotoresM rotorUno, 1
	call printText
	plugboardM lenTextIn, plugboard	
	call printText
	exit
	
printText:
       print newline, 1
	print textoCifrado, lenTextIn	
	lea rsi, [textIn]
	lea rdi, [textoCifrado]	 		
	ret

;end prinf

