calculator: calculator.o utilities.o
	ld -g -o calculator calculator.o utilities.o

calculator.o: calculator.asm
	yasm -Worphan-labels -g dwarf2 -f elf64 calculator.asm -l main.lst

utilities.o: utilities.asm
	yasm -Worphan-labels -g dwarf2 -f elf64 utilities.asm -l utilities.lst

clean:
	rm -f calculator *.o *.lst