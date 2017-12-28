
ifeq ($(OSTYPE),cygwin)
    ARCH=x86
    CROSS_COMPILE=
else
#arm-linux-gnueabi- doesn't work on user space...
    ARCH=arm
    CROSS_COMPILE=arm-linux-gnueabihf-
    CFLAGS = -marm -O0 -g 
    ifeq ($(TARGET),angstrom)
        CFLAGS += -march=armv4t -mfloat-abi=soft
    endif
endif


AR=${CROSS_COMPILE}ar
AS=${CROSS_COMPILE}as
LD=${CROSS_COMPILE}gcc
RANLIB=${CROSS_COMPILE}ranlib
CC=${CROSS_COMPILE}gcc
NM=${CROSS_COMPILE}nm

bin=echo_shell
obj=echo_shell.o

all:    $(bin)

$(bin): $(obj)
	$(LD)  $(obj) -o $(bin)
	cp $(bin) $(NFSROOT)

.c.o: 
	$(CC) $(CFLAGS) -c $<


clean:
	-rm $(obj) $(bin)



