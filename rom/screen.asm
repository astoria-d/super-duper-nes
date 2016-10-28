.setcpu		"6502"
.autoimport	on

.export main_screen_init
.export char_test
.export vram_current

.segment "STARTUP"

.proc	main_screen_init

    ;leftmost @ 2021.
    lda #$20
    sta $2006
    lda #$41
    sta $2006
    lda #$82
    sta $2007

    ;top right
    lda #$20
    sta $2006
    lda #$4e
    sta $2006
    lda #$83
    sta $2007

    ;left bottom
    lda #$21
    sta $2006
    lda #$61
    sta $2006
    lda #$84
    sta $2007

    ;right bottom
    lda #$21
    sta $2006
    lda #$6e
    sta $2006
    lda #$85
    sta $2007

    lda #$20
    sta $2006
    lda #$42
    sta $2006

    ldx #11
    lda #$80
:
    sta $2007
    dex
    bpl :-

    lda #$21
    sta $2006
    lda #$62
    sta $2006

    ldx #11
    lda #$80
:
    sta $2007
    dex
    bpl :-

    ;;incretemt 32 bit.
    lda #$04
    ora ppu_stat1
    sta ppu_stat1
    sta $2000
    
    lda #$20
    sta $2006
    lda #$61
    sta $2006

    ldx #7
    lda #$81
:
    sta $2007
    dex
    bpl :-

    lda #$20
    sta $2006
    lda #$6e
    sta $2006

    ldx #7
    lda #$81
:
    sta $2007
    dex
    bpl :-


    lda #$fb
    and ppu_stat1
    sta ppu_stat1
    sta $2000

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
