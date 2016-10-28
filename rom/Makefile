ASMSOURCES =	duper-rom.asm screen.asm

OBJECTS	=	$(ASMSOURCES:.asm=.o)

LIBRARIES =
#-------------------------------------------------------------------------------
all :	$(OBJECTS) $(LIBRARIES)
	ld65 -o duper-rom.nes --config linker.cfg --obj $(OBJECTS)
#	./dd-img.sh regression
#	cp regression.nes ../../de1_nes/simulation/modelsim/rom-file.nes
#	cp regression.nes ../../de0_cv_nes/simulation/modelsim/rom-file.nes
#	cp sample1-chr.hex ../../de1_nes/
#	cp sample1-prg-8k.hex ../../de1_nes/sample1-prg.hex
#	cp sample1-chr.hex ../../de0_cv_nes/
#	cp sample1-prg.hex ../../de0_cv_nes/

run : all
	date; VirtuaNES.exe duper-rom.nes


.SUFFIXES : .asm .o

.asm.o :
	ca65 -t none $*.asm

clean :
	-rm *.nes
	-rm *.o
	-rm *.bin *.hex

