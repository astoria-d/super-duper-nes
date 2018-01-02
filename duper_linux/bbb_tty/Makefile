
obj-m+=bbb_tty.o

V=1
ARCH=arm
CROSS_COMPILE=arm-linux-gnueabi-

export V
export ARCH
export CROSS_COMPILE

all:
	make V=1 -C $(KERNEL_SRC)/ M=$(PWD) modules
	cp bbb_tty.ko $(NFSROOT)

clean:
	make V=1 -C $(KERNEL_SRC)/ M=$(PWD) clean

