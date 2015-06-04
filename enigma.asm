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



%macro rotoresM 1
	%%loop:
	rotor %1, rbx	; %macro rotor 1  ; rotorActual
	inc rbx
	cmp rbx, rcx
	jne %%loop
	xor rbx, rbx
	;ret
%endmacro



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
	push rax		;XF,PZ,SQ,GR,AJ,UO,CN,BV,TM,KI	
	push rcx	; cont Buf
	push rbx	; cont de pb
	push rdx	
	
	xor rcx, rcx
%%loopBuf:
	xor rbx, rbx
	xor rax, rax
	;div rbx, divide el rax entre el rbx, 
	;deja el resultado en el rax y el residuo en el rdx	
	mov al, [textoCifrado+ rcx]
	
%%loopPb:
	mov ah, [%2+ rbx]
	cmp al, ah
	je %%swap
	
	inc rbx
	cmp rbx, 29
	jne %%loopPb
	je %%continueLoop

%%swap:
	cmp rbx, 0
	je %%masUno
	cmp rbx, 1
	je %%menosUno
	cmp rbx, 28
	je %%menosUno
	cmp byte [%2+ rbx - 1], ','
	je %%masUno
	jne %%menosUno
	
%%masUno:		;no dec rdi	
	mov ah, [%2 + rbx + 1 ]
	mov [textoCifrado + rcx], ah
	jmp %%continueLoop

%%menosUno:
	mov ah, [%2 + rbx - 1]
	mov byte[textoCifrado + rcx], ah

%%continueLoop:
	inc rcx
	cmp rcx, %1
	jne %%loopBuf
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

 	call copiarBuf		; mov textoCifrado, textIn	

;	plugboardM lenTextIn, plugboard

	xor r8, r8 		
	lea rsi, [textIn]
	lea rdi, [textoCifrado]	 	
	;;call rotores	;rbx ==> puntero-cont recorre el bufer

	rotoresM rotorUno

        print newline, 1
	print textoCifrado, lenTextIn
	
	print newline, 2



	;print textIn, lenTextIn
	exit
	

rotoresA:
	rotor rotorUno, rbx	; %macro rotor 1  ; rotorActual
	inc rbx
	cmp rbx, rcx
	jne rotoresA
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


exit
