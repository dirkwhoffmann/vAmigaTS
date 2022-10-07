NAME = setcpu

VASM=/usr/local/bin/vasmm68k_mot
GCC=/opt/amiga/bin/m68k-amigaos-gcc

all:	$(NAME).adf

030Stuff.o:
	$(VASM) -Fhunk -quiet -esc 030stuff.a -o 030stuff.o -I/usr/local/amiga/vgcc/ndk/include

$(NAME).adf:	030Stuff.o $(NAME).c 
	$(GCC) -mcrt=nix13 $(NAME).c 030stuff.o -o $(NAME).exe
	@rm -f *.o

clean:
	@rm -f *.o *.exe
