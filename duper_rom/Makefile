ASMSOURCES =	duper-rom.asm ppu.asm nmi.asm

OBJECTS	=	$(ASMSOURCES:.asm=.o)

LIBRARIES =
#-------------------------------------------------------------------------------
all :	$(OBJECTS) $(LIBRARIES)
	ld65 -o duper-rom.nes -vm --mapfile duper-rom.map  --config linker.cfg --obj $(OBJECTS)
	./dd-img.sh duper-rom
#	cp regression.nes ../../de1_nes/simulation/modelsim/rom-file.nes
#	cp regression.nes ../../de0_cv_nes/simulation/modelsim/rom-file.nes
#	cp sample1-chr.hex ../../de1_nes/
#	cp sample1-prg-8k.hex ../../de1_nes/sample1-prg.hex
#	cp sample1-chr.hex ../../de0_cv_nes/
#	cp sample1-prg.hex ../../de0_cv_nes/
#	ld65 -o duper-rom.nes --dbgfile duper-rom.dbg -vm --mapfile duper-rom.map  --config linker.cfg --obj $(OBJECTS)

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

