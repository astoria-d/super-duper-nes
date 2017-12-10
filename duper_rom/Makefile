ASMSOURCES =	duper-rom.asm ppu.asm nmi.asm

OBJECTS	=	$(ASMSOURCES:.asm=.o)

LIBRARIES =
#-------------------------------------------------------------------------------
all :	$(OBJECTS) $(LIBRARIES)
	ld65 -o duper-rom.nes -vm --mapfile duper-rom.map  --config linker.cfg --obj $(OBJECTS)
	./dd-img.sh duper-rom
	cp sample1-chr-4k.hex ../duper_cartridge/
	cp sample1-prg-8k.hex ../duper_cartridge/
#	ld65 -o duper-rom.nes --dbgfile duper-rom.dbg -vm --mapfile duper-rom.map  --config linker.cfg --obj $(OBJECTS)
	 cp duper-rom.nes ../../motonesemu/bin/
	 cp duper-rom.nes ../duper_cartridge/


run : all
	date; VirtuaNES.exe duper-rom.nes

disas : all
	./disasm-rom.sh
	less duper-rom.disas

.SUFFIXES : .asm .o

.asm.o :
	ca65 -t none $*.asm

clean :
	-rm *.nes
	-rm *.o
	-rm *.bin *.hex
	-rm *.map *.dbg *.disas
	-rm debug-info.cfg

