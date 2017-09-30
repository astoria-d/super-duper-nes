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
	cld
	ldx	#$ff
	txs

    jsr init_reset
    jsr init_global
    jsr init_ppu

    jsr char_test
    jsr main_screen_init

    jsr init_menu

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

;;initialize very after reset.
.proc init_reset

;;must caribrate for several vblank counts.
    ldx #3

@car_start:
    lda $2002
    and #$80
    beq @vbl_chk
    ;;vblank happened.
    dex
    beq @car_done
@vbl_chk:
    jmp @car_start
@car_done:

;;initialize ram.

;;init zp area.
    lda #0
    sta $0
    sta $1
    ldy #$ff
:
    sta ($0), y
    dey
    bne :-
    sta ($0), y

;;init sp area
    tsx
    txa
    tay
    lda #1
    sta $1
    lda #0
    sta $0
:
    sta ($0), y
    dey
    bne :-
    sta ($0), y


;;init remaining area (0200 - 07ff).
    ldx #7
    lda #0

@rep:
    stx $1
:
    sta ($0), y
    dey
    bne :-
    dex
    cpx #2
    bpl @rep


;;init vram (2000 - 27ff)..
    ldx #$20
    lda #0
    ldy #0

@rep2:
    stx $2006
    sty $2006
:
    sta $2007
    iny
    bne :-
    inx
    cpx #$28
    bmi @rep2

;;init vram (3f00 - 3f1f)..
    ldx #$3f
    lda #0
    ldy #0

    stx $2006
    sty $2006
:
    sta $2007
    iny
    cpy #$20
    bne :-

    rts

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
