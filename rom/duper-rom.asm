.setcpu		"6502"
.autoimport	on

.export ppu_ctl
.export ppu_mask

; iNES header
.segment "HEADER"
	.byte	$4E, $45, $53, $1A	; "NES" Header
	.byte	$02			; PRG-BANKS
	.byte	$01			; CHR-BANKS
	.byte	$01			; Vetrical Mirror
	.byte	$00			; 
	.byte	$00, $00, $00, $00	; 
	.byte	$00, $00, $00, $00	; 


;;;;memory map
;;0000 - 00ff  zp: volatile though functions
;;0100 - 01ff  sp: preserved through functions   
;;0200 - 02ff  dma: dedicated for dma
;;0300 - 07ff  global: global variables.

.segment "STARTUP"

.proc	reset_proc

; interrupt off, initialize sp.
	sei
	ldx	#$ff
	txs

    jsr init_global
    jsr init_ppu

    jsr char_test
    jsr main_screen_init


    ;;init scroll point.
    lda #$00
    sta $2005

    lda #$00
    sta $2005

    ;;show bg...
	lda	#$1e
	sta	$2001
	sta	ppu_mask

    ;;;enable nmi
	lda	#$80
	sta	$2000
	sta	ppu_ctl

    ;;done...
    ;;infinite loop.
mainloop:
	jmp	mainloop
.endproc

;;initialize bss segment datas
.proc init_global
    lda #$00
    sta ppu_ctl
    sta ppu_mask
    sta jp_suspend_cnt
    rts
.endproc

;;;;r/w global variables.
.segment "BSS"

;;ppu ctl reg val @2000
ppu_ctl:
    .byte   $00
;;ppu mask reg val @2001
ppu_mask:
    .byte   $00

;;;for DE1 internal memory constraints.
.segment "VECINFO_8k"
	.word	nmi_proc
	.word	reset_proc
	.word	$0000

.segment "VECINFO"
	.word	nmi_proc
	.word	reset_proc
	.word	$0000

; character rom file.
.segment "CHARS"
	.incbin	"character.chr"
