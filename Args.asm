%include "System.mac"
%include "String.mac"

%define delimiter 10
section .data

section .bss
Buff	resb 64

section .text
global _start
_start:

	cmp argcount, 2
	jl .end

	; ;Open file again, but in read only. Read back written string
	; fopen argument(2), o_readonly
	; mov r8, rax	;fd is in rax, copy to r8
	; fgetstr r8, Buff
	; putstring Buff
	; fclose r8

	;Test csv parsing. Raisesegmentation fault if less than 3 csv
	clearString Buff, 64
	fopen argument(2), o_readonly
	mov r8, rax						;fd is in rax, copy to r8
	fgetcsv r8, Buff 				;get comma separated value
	putstring Buff
	clearString Buff, 64

	fgetcsv r8, Buff
	putstring Buff
	clearString Buff, 64
	
	fgetcsv r8, Buff
	putstring Buff
	fclose r8

.end:
	return 0
