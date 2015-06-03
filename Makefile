abrir_leer: abrir_leer.asm
	@yasm -f elf64 -o abrir_leer.o abrir_leer.asm
	@ld -o abrir_leer abrir_leer.o
