todo: enigma.o
	yasm -f elf64 enigma.asm -o enigma.o
	ld enigma.o -o enigma
