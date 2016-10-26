.setcpu		"6502"
.autoimport	on

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

.proc	Reset

; interrupt off, initialize sp.
	sei
	ldx	#$ff
	txs

    jsr init_global
    jsr init_ppu

    lda ad_start_msg
    sta $00
    lda ad_start_msg+1
    sta $01
    jsr print_ln
    jsr print_ln
    jsr print_ln


    ;;init scroll point.
    lda #$00
    sta $2005

    lda #$00
    sta $2005

    ;;set vs_cnt init value.
    lda #60
    sta vs_cnt

    ;;show bg...
	lda	#$1e
	sta	$2001
	sta	ppu_stat2

short_cut1:
    ;;;enable nmi
	lda	#$80
	sta	$2000
	sta	ppu_stat1

    ;;done...
    ;;infinite loop.
mainloop:
	jmp	mainloop
.endproc

.proc	nmi_test
    rti
.endproc

;;initialize bss segment datas
.proc init_global
;;ppu test flag
    lda use_ppu
    beq @ppu_skip

;;vram pos start from the top left.
;;(pos 0,0 is sprite hit point.)
    lda #$20
    sta vram_current
    lda #$01
    sta vram_current + 1

    lda #$00
    sta scroll_x
    lda #$00
    sta scroll_y

    lda #$00
    sta ppu_stat1
    lda #$00
    sta ppu_stat2

    lda #$00
    sta vs_cnt
    lda #$00
    sta disp_cnt
@ppu_skip:

    rts

.endproc

;;ppu initialize
.proc init_ppu
    jsr check_ppu
    ;ppu register initialize.
	lda	#$00
	sta	$2000
	sta ppu_stat1
	sta	$2001
	sta ppu_stat2

    ;;load palette.
	lda	#$3f
	sta	$2006
	lda	#$00
	sta	$2006

	ldx	#$00
	ldy	#$20
@copypal:
	lda	@palettes, x
	sta	$2007
	inx
	dey
	bne	@copypal
    rts

@palettes:
;;;bg palette
	.byte	$0f, $00, $10, $20
	.byte	$0f, $04, $14, $24
	.byte	$0f, $08, $18, $28
	.byte	$0f, $0c, $1c, $2c
;;;spr palette
	.byte	$0f, $00, $10, $20
	.byte	$0f, $06, $16, $26
	.byte	$0f, $08, $18, $28
	.byte	$0f, $0a, $1a, $2a

.endproc

;;check_ppu exists caller's function if use_ppu flag is off
.proc check_ppu
    lda use_ppu
    bne @use_ppu_ret
    ;;pop caller's return addr
    pla
    pla
@use_ppu_ret:
    rts
.endproc

;;;param $00, $01 = msg addr.
;;;print_ln display message. 
;;;start position is the bottom of the screen.
.proc print_ln
    jsr check_ppu
    lda vram_current
    sta $2006
    lda vram_current + 1
    sta $2006

    ldy #$00
@msg_loop:
    lda ($00), y
    sta $2007
    beq @print_done
    iny
    jmp @msg_loop
@print_done:

    ;;clear remaining space.
@clr_line:
    tya
    and #$1f
    cmp #$1f
    beq @clr_done
    lda #$00
    sta $2007
    iny
    jmp @clr_line
@clr_done:

    ;;renew vram pos
    lda vram_current + 1
    sty vram_current + 1
    adc vram_current + 1
    sta vram_current + 1
    tax         ;; x = new vram_l
    lda vram_current
    bcc @no_carry
    clc
    adc #01     ;; a = new vram_h
    sta vram_current
@no_carry:

    cmp #$23
    bne @vpos_done

    txa 
    cmp #$c0
    bne @vpos_done
    ;;;if vram pos = 23c0. reset pos.
    lda #$20
    sta vram_current
    lda #$00
    sta vram_current + 1
@vpos_done:

    rts
.endproc

;;;;string datas
ad_start_msg:
    .addr   :+
:
    .byte   "regression test start..."
    .byte   $00

;;ppu test flag.
use_ppu:
    .byte   $01

;;;;r/w global variables.
.segment "BSS"
vram_current:
    .byte   $00
    .byte   $00
scroll_x:
    .byte   $00
scroll_y:
    .byte   $00

;;ppu status reg val @2000
ppu_stat1:
    .byte   $00
;;ppu status reg val @2001
ppu_stat2:
    .byte   $00

vs_cnt:
    .byte   $00
disp_cnt:
    .byte   $00

;;;for DE1 internal memory constraints.
.segment "VECINFO_8k"
	.word	nmi_test
	.word	Reset
	.word	$0000

.segment "VECINFO"
	.word	nmi_test
	.word	Reset
	.word	$0000

; character rom file.
.segment "CHARS"
	.incbin	"character.chr"
