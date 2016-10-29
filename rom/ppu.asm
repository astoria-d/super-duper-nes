.setcpu		"6502"
.autoimport	on

.export main_screen_init
.export char_test
.export init_ppu

.segment "STARTUP"

.proc	main_screen_init

    ;;create box.
    lda #$20
    sta $00
    lda #$41
    sta $01
    lda #$20
    sta $02
    lda #$4e
    sta $03
    lda #$21
    sta $04
    lda #$61
    sta $05
    lda #$21
    sta $06
    lda #$6e
    sta $07
    jsr create_rect

    ;;set message.
    lda #$20
    sta $02
    lda #$62
    sta $03
    lda top_menu1
    sta $00
    lda top_menu1+1
    sta $01
    jsr print_str
    
    lda #$20
    sta $02
    lda #$84
    sta $03
    lda top_menu_internet
    sta $00
    lda top_menu_internet+1
    sta $01
    jsr print_str
    
    lda #$20
    sta $02
    lda #$a4
    sta $03
    lda top_menu_game
    sta $00
    lda top_menu_game+1
    sta $01
    jsr print_str
    
    lda #$20
    sta $02
    lda #$c4
    sta $03
    lda top_menu_shell
    sta $00
    lda top_menu_shell+1
    sta $01
    jsr print_str
    



;    ;;create box.
;    lda #$20
;    sta $00
;    lda #$6d
;    sta $01
;    lda #$20
;    sta $02
;    lda #$79
;    sta $03
;    lda #$21
;    sta $04
;    lda #$ad
;    sta $05
;    lda #$21
;    sta $06
;    lda #$b9
;    sta $07
;    jsr create_rect

    rts
.endproc

;;;param $00, $01 = top left.
;;;param $02, $03 = top right
;;;param $04, $05 = bottom left.
;;;param $06, $07 = bottom right
.proc	create_rect

    ;leftmost @ 2021.
    lda $00
    sta $2006
    lda $01
    sta $2006
    lda #$82
    sta $2007

    ;top right
    lda $02
    sta $2006
    lda $03
    sta $2006
    lda #$83
    sta $2007

    ;left bottom
    lda $04
    sta $2006
    lda $05
    sta $2006
    lda #$84
    sta $2007

    ;right bottom
    lda $06
    sta $2006
    lda $07
    sta $2006
    lda #$85
    sta $2007
    
    ;;calc width
    sec
    lda $03
    sbc $01
    sta $08 ;;$08=width
    dec $08
    dec $08

    ;;get y index1
    lda $01
    lsr
    lsr
    lsr
    lsr
    lsr
    sta $0a ;;$0a=top pos in y axis (bottom 3bit.)

    lda #$1f
    and $00 ;;$0b=top pos (top 5bit.)
    asl
    asl
    asl
    ora $0a ;;$09=top pos
    sta $09

    ;;get y index2
    lda $05
    lsr
    lsr
    lsr
    lsr
    lsr
    sta $0a ;;$0a=bottom pos in y axis (bottom 3bit.)

    lda #$1f
    and $04 ;;$0b=bottom pos (top 5bit.)
    asl
    asl
    asl
    ora $0a ;;$0a=bottom pos
    sta $0a
    
    sec
    sbc $09
    sta $09 ;;$09=hight
    dec $09
    dec $09

    ;;horizontal line.
    lda $00
    sta $2006
    clc
    lda #$01
    adc $01
    sta $2006

    ldx $08
    lda #$80
:
    sta $2007
    dex
    bpl :-

    lda $04
    sta $2006
    lda #$01
    adc $05
    sta $2006

    ldx $08
    lda #$80
:
    sta $2007
    dex
    bpl :-

    ;;incretemt 32 bit.
    lda #$04
    ora ppu_ctl
    sta ppu_ctl
    sta $2000
    
    ;;vertical line.
    clc
    lda #32
    adc $01
    sta $0a

    lda #0
    adc $00
    sta $2006
    lda $0a
    sta $2006

    ldx $09
    lda #$81
:
    sta $2007
    dex
    bpl :-

    ;;
    clc
    lda #32
    adc $03
    sta $0a

    lda #0
    adc $02
    sta $2006
    lda $0a
    sta $2006

    ldx $09
    lda #$81
:
    sta $2007
    dex
    bpl :-


    lda #$fb
    and ppu_ctl
    sta ppu_ctl
    sta $2000


    ;;fill blank in the box.

    lda #33
    adc $01
    sta $0c
    lda #0
    adc $00
    sta $0b
    ;;set left most point @0b, 0c.
    ldy $09
    
@y_loop:
    lda $0b
    sta $2006
    lda $0c
    sta $2006
    ldx $08
    lda #' '
:
    sta $2007
    dex
    bpl :-
    
    lda #$20
    clc
    adc $0c
    bcc :+
    inc $0b
:
    sta $0c
    dey
    bpl @y_loop

    rts
.endproc


.proc	char_test
    lda ad_start_msg
    sta $00
    lda ad_start_msg+1
    sta $01
    jsr print_ln
    jsr print_ln
    jsr print_ln

    lda ad_cht_chk_msg1
    sta $00
    lda ad_cht_chk_msg1+1
    sta $01
    jsr print_ln
    lda ad_cht_chk_msg2
    sta $00
    lda ad_cht_chk_msg2+1
    sta $01
    jsr print_ln

    lda ad_cht_chk_msg3
    sta $00
    lda ad_cht_chk_msg3+1
    sta $01
    jsr print_ln

    rts
.endproc


;;;param $00, $01 = msg addr.
;;;param $02, $03 = vram pos
;;;print string at the pos specified in the parameter.
.proc print_str
    lda $02
    sta $2006
    lda $03
    sta $2006

    ldy #$00
@msg_loop:
    lda ($00), y
    sta $2007
    beq @print_done
    iny
    jmp @msg_loop
@print_done:

    rts
.endproc

;;;param $00, $01 = msg addr.
;;;print_ln display message. 
;;;start position is the bottom of the screen.
.proc print_ln
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


;;ppu initialize
.proc init_ppu
;;vram pos start from the top left.
    lda #$20
    sta vram_current
    lda #$00
    sta vram_current + 1

    ;ppu register initialize.
	lda	#$00
	sta	$2000
	sta ppu_ctl
	sta	$2001
	sta ppu_mask

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


;;;;string datas
ad_start_msg:
    .addr   :+
:
    .byte   "test start..."
    .byte   $00

ad_cht_chk_msg1:
    .addr   :+
:
    .byte   " !"
    .byte   $22    ;;;" char.
    .byte   "#$%&'()*+,-./0123456789:;<=>?"
    .byte   $00

ad_cht_chk_msg2:
    .addr   :+
:
    .byte   "@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_"
    .byte   $00

ad_cht_chk_msg3:
    .addr   :+
:
    .byte   "`abcdefghijklmnopqrstuvwxyz{|}~"
    .byte   $00

top_menu1:
    .addr   :+
:
    .byte   "Command"
    .byte   $00

top_menu_internet:
    .addr   :+
:
    .byte   "Internet"
    .byte   $00

top_menu_game:
    .addr   :+
:
    .byte   "Game"
    .byte   $00

top_menu_shell:
    .addr   :+
:
    .byte   "Shell"
    .byte   $00

;;;;r/w global variables.
.segment "BSS"
vram_current:
    .byte   $00
    .byte   $00
