
obj-m               += bbb-tty-core.o
bbb-tty-core-y      := bbb_tty.o bbb_tty_proc.o


V=1
ARCH=arm
CROSS_COMPILE=arm-linux-gnueabi-

export V
export ARCH
export CROSS_COMPILE

all:
	make V=1 -C $(KERNEL_SRC)/ M=$(PWD) modules
	cp bbb-tty-core.ko $(NFSROOT)

bbb-tty-core.o:
	make V=1 -C $(KERNEL_SRC)/ M=$(PWD) 

clean:
	make V=1 -C $(KERNEL_SRC)/ M=$(PWD) clean

