;********************************************************************
;*				Tecnológico de Costa Rica							*
;*				Ingeniería en Computación							*
;*				Arquitectura de Computadores						*
;*				Erick Hernández Bonilla								*
;*				Proyecto: Máquina Enigma en Ensamblador				*
;*				Alumnos: Melissa Molina Corrales 2013006074			*
;*						 Liza Chaves Carranza 2013016573			*
;*						 Gabriel Pizarro 201216833					*
;*						 Fabián Monge								*
;********************************************************************

; Datos sin inicializar
section .bss

	buffer: resb bufferLen 
	bufferLen: equ 1024

; Datos inicializados
section .data

	primerRotor: db 'EKMFLGDQVZNTOWYHXUSPAIBRCJ'
	segundoRotor: db 'AJDKSIRUXBLHWTMCQGZNPYFVOE'
	tercerRotor: db 'BDFHJLCPRTXVZNYEIWGAKMUSQO'
	cuartoRotor: db 'BDFHJLCPRTXVZNYEIWGAKMUSQO'
	quintoRotor: db 'ESOVPZJAYQUIRHXLNFTGKDCMWB'
	reflector: db ''

	

; Código
section .text
	global _start

_start:

