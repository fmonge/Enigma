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

section .bss

	rotores:        resb 1024

 	plugboard:      resb 29
	lenPlugboard:   equ $ - plugboard
	; ejemplo de blugboard:
	; XF,PZ,SQ,GR,AJ,UO,CN,BV,TM,Ki

section .data

	rotorUno:       db 'EKMFLGDQVZNTOWYHXUSPAIBRCJ'
	rotorDos:       db 'AJDKSIRUXBLHWTMCQGZNPYFVOE'
	rotorTres:      db 'BDFHJLCPRTXVZNYEIWGAKMUSQO'
	rotorCuatro:    db 'ESOVPZJAYQUIRHXLNFTGKDCMWB'
	rotorCinco:     db 'VZBRGITYUPSDNHLXAWMJQOFECK'
	reflector:      db 'JPGVOUMFYQBENHZRDKASXLICTW'
	;  estatico:    db 'ABCDEFHGIJKLMNOPQRSTUVWXYZ'


	rotores:	resb 	

	plugboard:	resb 29
	lenPlugboard: 	equ $ - plugboard
	; ejemplo de blugboard:
		; XF,PZ,SQ,GR,AJ,UO,CN,BV,TM,Ki

section .text
	global _start

_start:
	
numeros: 	db 'I,II,III,IV,V'

getPos:



