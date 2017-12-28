
ifeq ($(findstring cmd.exe,${COMSPEC}),cmd.exe)
#case cygwin environment.
    ARCH=x86
    CROSS_COMPILE=
    copy_nfs=
    CFLAGS = -D ENV_CYGWIN
else
#arm-linux-gnueabi- doesn't work on user space...
    ARCH=arm
    CROSS_COMPILE=arm-linux-gnueabihf-
    CFLAGS = -marm -O0 -g 
    ifeq ($(TARGET),angstrom)
        CFLAGS += -march=armv4t -mfloat-abi=soft
    endif
    copy_nfs=cp $(bin) $(NFSROOT)
endif


AR=${CROSS_COMPILE}ar
AS=${CROSS_COMPILE}as
LD=${CROSS_COMPILE}gcc
RANLIB=${CROSS_COMPILE}ranlib
CC=${CROSS_COMPILE}gcc
NM=${CROSS_COMPILE}nm

bin=echo_shell
obj=echo_shell.o gpio_handler.o

all:    $(bin)

$(bin): $(obj)
	$(LD)  $(obj) -o $(bin)
	$(copy_nfs)

.c.o: 
	$(CC) $(CFLAGS) -c $<


clean:
	-rm $(obj) $(bin)



