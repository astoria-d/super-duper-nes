#!/bin/bash 

if [ "$1" == "" ] ; then
    echo "$0 -in_filename (w/o .nex )"
    exit -1
fi

in_name=$1

in_file=$in_name.nes
out_file1=$in_name-prg.bin
out_file2=$in_name-chr.bin

echo in_file=$in_name.nes
echo out_file1=$in_name-prg.bin
echo out_file2=$in_name-chr.bin

echo "processing...."

dd if=$in_file of=$out_file1 bs=16 skip=1 count=2048 2> /dev/null
dd if=$in_file of=$out_file2 bs=16 skip=2049 2> /dev/null

objcopy -I binary -O ihex $in_name-prg.bin sample1-prg.hex
objcopy -I binary -O ihex $in_name-chr.bin sample1-chr.hex

#8k img creation
dd if=$in_name-prg.bin of=$in_name-prg-8k.bin bs=512 count=16
objcopy -I binary -O ihex $in_name-prg-8k.bin sample1-prg-8k.hex

echo "done."
