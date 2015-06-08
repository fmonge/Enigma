;****************************************
;*	Tecnológico de Costa Rica	*
;*	Ingeniería en Computación	*
;*	Arquitectura de Computadoras	*
;*	Profe:				*
;*	Erick Hernández Bonilla		*
;*	Proyecto:			*
;*	Máquina Enigma en Ensamblador	*
;*	Alumnos:			*
;*	Melissa Molina 2013006074	*
;*	Liza Chaves Carranza 2013016573	*
;*	Fabián Monge			*
;*	Gabreiel Pizarro 201216833	*
;****************************************
%include "string.mac"
%include "cifrado.mac"

section .bss
	bufTmp:		resb 1024
	bufTextTmp:	resb 1024
	
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
	;rotorUno:       db 'EKMFLGDQVZNTOWYHXUSPAIBRCJ'
	;rotorDos:       db 'AJDKSIRUXBLHWTMCQGZNPYFVOE'
	;rotorTres:      db 'BDFHJLCPRTXVZNYEIWGAKMUSQO'

	;rotorTres:	db 'AXYDEBCVQJKFGLMRHINOPUWSTZ'
	;rotorDos:	db 'PTOSMXUWEBVQFACJDIGLKZNYRH'
	;rotorUno:       db 'ZPTWYLOUESMBXVQNFADIGCJKRH'
	;;;;;		    ABCDEFGHIJKLMNOPQRSTUVWXYZ
	
	plugboard:	db 'XF,PZ,SQ,GR,AJ,UO,CN,BV,TM,KI'

	lenRotores:	equ $ - rotorUno
	
	rotorI:		db 'EKMFLGDQVZNTOWYHXUSPAIBRCJ'
	rotorII:	db 'AJDKSIRUXBLHWTMCQGZNPYFVOE'
	rotorIII:	db 'BDFHJLCPRTXVZNYEIWGAKMUSQO'
	rotorIV:	db 'ESOVPZJAYQUIRHXLNFTGKDCMWB'
	rotorV:		db 'VZBRGITYUPSDNHLXAWMJQOFECK'
	reflector:      db 'EJMZALYXVBWFCRQUONTSPIKHGD'
	
	;reflector: db 'YAMQRXSUJGZWVCTHLIPFOBNKED'
	;reflectorB:	db 'YRUHQSLDPXNGOKMIEBFZCWVJAT'
	;reflectorC:	db 'FVPJIAOYEDRZXWGCTKUQSBNMHL'
	;estatico:	db 'ABCDEFHGIJKLMNOPQRSTUVWXYZ'



	;plugboard:	resb 29
	;lenPlugboard:	equ $ - plugboard
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
	dec r8
	mov r10, rax
;	xor r10, r10
	rotarBufIzq rotorUno, 4	
	rotarBufIzq rotorDos, 4
	rotarBufIzq rotorTres, 4

;	movBuf bufTextTmp, textIn		; mov textX, textY	
;	movBuf textoCifrado, textIn
	;; call copiarBuf
	xor r15, r15
	xor r13, r13
	dec r15
	
.loop:	
	inc r15
	mov al, byte[textIn+r15]	
	mov [textoCifrado], al

	plugboardM 1, plugboard		;XF,PZ,SQ,GR,AJ,UO,CN,BV,TM,Ki
	call printText ;call rotores	;rbx ==> puntero-cont recorre el bufer
	rotoresM rotorUno, 1
	call printText
	rotoresM rotorDos, 2
	call printText
	rotoresM rotorTres, 3
	call printText
	rotoresM reflector, 0
	call printText
	rotoresOutM rotorTres, 3, r15
	call printText
	rotoresOutM rotorDos, 2, r15
	call printText
	rotoresOutM rotorUno, 1, r15
	call printText
	plugboardM lenTextIn, plugboard	
	call printText
	print newline, 1
	cmp r15, r8
	jne .loop
	exit
	
printText:
       print newline, 1
	print textoCifrado, lenTextIn	
	lea rsi, [textIn]
	lea rdi, [textoCifrado]			
	ret

;end prinf

