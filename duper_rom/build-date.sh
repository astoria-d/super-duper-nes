#!/bin/bash 

echo "
.setcpu		\"6502\"

.export build_msg

build_msg:
    .addr   :+
:
    .byte   \"build ver: $(date '+%Y%m%d-%H%M%S')\"
    .byte   \$00
" > build_msg.asm

