.setcpu		"6502"
.autoimport	on

.export nmi_proc

.segment "STARTUP"

.proc	nmi_proc
    ;;stop nmi
    lda #$7f
    and ppu_ctl
    sta ppu_ctl
    sta $2000

    ;;enable nmi
    lda #$80
    ora ppu_ctl
    sta ppu_ctl
    sta $2000
    rti
.endproc


;;;;r/w global variables.
.segment "BSS"
