progra: progra.asm
	@yasm -f elf64 -o progra.o progra.asm
	@ld -o progra progra.o
