
obj-m               += bbb_tty_core.o
bbb_tty_core-y      := bbb_tty.o bbb_tty_proc.o bt_i2c.o


V=1
ARCH=arm
CROSS_COMPILE=arm-linux-gnueabi-

export V
export ARCH
export CROSS_COMPILE

all:
	make V=1 -C $(KERNEL_SRC)/ M=$(PWD) modules
	cp bbb_tty_core.ko $(NFSROOT)

bbb-tty-core.o:
	make V=1 -C $(KERNEL_SRC)/ M=$(PWD) 

clean:
	make V=1 -C $(KERNEL_SRC)/ M=$(PWD) clean

