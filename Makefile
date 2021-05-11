main: main.o calculator.o utilities.o
	ld -g -o main main.o calculator.o utilities.o

main.o: main.asm
	yasm -Worphan-labels -g dwarf2 -f elf64 main.asm -l main.lst

calculator.o: calculator.asm
	yasm -Worphan-labels -g dwarf2 -f elf64 calculator.asm -l main.lst

utilities.o: utilities.asm
	yasm -Worphan-labels -g dwarf2 -f elf64 utilities.asm -l utilities.lst

clean:
	rm -f main *.o *.lst