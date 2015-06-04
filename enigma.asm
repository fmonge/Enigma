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
%include "in_out.mac"


%macro rotor 2	;rotorNext, pos
	push rax
	xor rax, rax

	mov al, byte [textIn + %2] ; rdx =  buf mas desplazamiento
	sub al, 'A' 		;obtener pos en rotor next	
	mov ah, byte [%1+ rax]	
	mov al, ah		; en al para stosb
	stosb 			; al a [rdi++]
	;rotar %1, %2		; macro rotar

	pop rax
%endmacro

%macro plugboardM 2		; lenBuf, plugboard
	push rx		;	
	push rcx
	push rbx
	push rdx

	xor rbx, rbx
%%loopBuf:
	xor rdx, rdx
	cmp rcx, %1
	je %%endPB

	mov dl, [textoCifrado + rcx]

	
	xor rdi, rdi
%%findInPlugboard:
	cmp rdi, 20
	je %%continueLoop

	cmp dl, [plugboard+rdi]
	inc rdi
	jne %%findInPlugboard	 
	
	push rax
	xor rax, rax
	mov rbx, 2
	mov rax, rdi
	div rbx
	cmp rdx, 0
	je %%masUno
	jne %%menosUno
	;div rbx, divide el rax entre el rbx, 
	;deja el resultado en el rax y el residuo en el rdx	

	
	

	%%masUno:		;no dec rdi	
	mov dl, byte[%2 + rdi]
	mov byte[textoCifrado + rcx], dl
	jmp %%continueLoop

	%%menosUno:
	;dec rdi	
	;dec rdi
	mov dl, byte[%2 + rdi]
	mov byte[textoCifrado + rcx], dl
	

%%continueLoop:
	inc rcx
	jmp %%loopBuf
%%endPB
	pop rdx
	pop rbx
	pop rcx	
	pop rax
%endmacro


section .bss

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
	;plugboard:	db 'XF,PZ,SQ,GR,AJ,UO,CN,BV,TM,KI'
	plugboard:	db 'XFPZSQGRAJUOCNBVTMKI'
	
	
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
	;plugboardM
 	call copiarBuf		; mov textoCifrado, textIn	

plugboardM lenTextIn, plugboard

	xor r8, r8 		
	lea rsi, [textIn]
	lea rdi, [textoCifrado]	 	
;	call rotores	;rbx ==> puntero-cont recorre el bufer
	
        print newline, 1
	print textoCifrado, lenTextIn
	
	print newline, 2

	

	;print textIn, lenTextIn
	exit
	

rotores:
	rotor rotorUno, rbx	; %macro rotor 1  ; rotorActual
	inc rbx
	cmp rbx, rcx
	jne rotores
	xor rbx, rbx
	ret
;end rot1

copiarBuf:
	push rcx
	lea rsi, [textIn]
	lea rdi, [textoCifrado]
	rep movsb
	pop rcx
	ret
;end copiar




;cifrar:


;endCifrar









exit
