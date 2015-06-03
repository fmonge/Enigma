Args: Args.asm
	@yasm -f elf64 -o Args.o Args.asm
	@ld -o Args Args.o
