
obj-m               += bbb_tty_drv.o
bbb_tty_drv-y      := bt_module.o bbb_tty.o bt_proc.o bt_i2c.o bt_gpio.o

clean-files         += *.dtbo

V=1
ARCH=arm
CROSS_COMPILE=arm-linux-gnueabi-

export V
export ARCH
export CROSS_COMPILE

all:
	make V=1 -C $(KERNEL_SRC)/ M=$(PWD) modules
	cp bbb_tty_drv.ko $(NFSROOT)

clean:
	make V=1 -C $(KERNEL_SRC)/ M=$(PWD) clean

dtbo:
	$(KERNEL_SRC)/scripts/dtc/dtc -O dtb -o bbb_tty-00A0.dtbo -@ bbb_tty.dts
	cp bbb_tty-00A0.dtbo $(NFSROOT)

