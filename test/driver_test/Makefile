
kernel-src=/home/dmotooka/super-duper-nes/linux-4.4
nfs-dir=/home/dmotooka/super-duper-nes/nfsroot

obj-m+=test-drv.o

V=1
ARCH=arm
CROSS_COMPILE=arm-linux-gnueabi-

export V
export ARCH
export CROSS_COMPILE

all:
	make V=1 -C $(kernel-src)/ M=$(PWD) modules
	cp test-drv.ko $(nfs-dir)
clean:
	make V=1 -C $(kernel-src)/ M=$(PWD) clean

