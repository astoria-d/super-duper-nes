
all:
	~/super-duper-nes/linux-4.4/scripts/dtc/dtc -O dtb -o duper-i2c-00A0.dtbo -b -0 -@ duper-i2c.dts
	cp duper-i2c-00A0.dtbo ~/super-duper-nes/nfsroot/dts-work/

clean:
	rm *.dtbo
