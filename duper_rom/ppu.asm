.setcpu        "6502"
.autoimport    on

.export update_screen
.export main_screen_init
.export char_test
.export init_menu
.export init_ppu
.export jp_status

;;for debugging..
.export linefeed

.segment "STARTUP"


;;;screen func table.
update_funcs:
    .addr   main_screen_updt        ;0
    .addr   inet_screen_updt        ;1
    .addr   game_screen_updt        ;2
    .addr   shell_screen_updt       ;3
    .addr   inet_bmark_scr_updt     ;4
    .addr   inet_srch_scr_updt      ;5
    .addr   inet_dirct_scr_updt     ;6
    .word   $00

.proc update_screen
    ;;;get current screen stat.
    lda screen_status
    asl     ;;offset address to word.
    tay
    lda update_funcs, y ;;get handler low.
    sta $02
    iny
    lda update_funcs, y ;;get handler hi
    sta $03

    ;;goto handler.
    jmp ($02)
.endproc


;;;init func table.
init_funcs:
    .addr   main_screen_init        ;0
    .addr   inet_screen_init        ;1
    .addr   game_screen_init        ;2
    .addr   shell_screen_init       ;3
    .addr   inet_bmark_scr_init     ;4
    .addr   inet_srch_scr_init      ;5
    .addr   inet_dirct_scr_init     ;6
    .word   $00

.proc init_screen
    ;;;get current screen stat.
    lda screen_status
    asl     ;;offset address to word.
    tay
    lda init_funcs, y ;;get handler low.
    sta $02
    iny
    lda init_funcs, y ;;get handler hi
    sta $03

    ;;goto handler.
    jmp ($02)
.endproc

.proc main_screen_updt
    ;;;case up
    lda #$10
    bit jp1_data
    beq @down

    lda #1
    cmp top_menu_select
    bne :+
    jmp @end
:
    ;;move cursor up.
    lda top_menu_cur_pos
    sta $02
    lda top_menu_cur_pos+1
    sta $03
    lda un_select_cursor
    sta $00
    lda un_select_cursor+1
    sta $01
    jsr print_str

    sec
    lda #$20
    sta $00
    lda top_menu_cur_pos+1
    sbc $00
    sta top_menu_cur_pos+1
    sta $03

    lda #$00
    sta $00
    lda top_menu_cur_pos
    sbc $00
    sta top_menu_cur_pos
    sta $02

    lda select_cursor
    sta $00
    lda select_cursor+1
    sta $01
    jsr print_str
    
    ;;decrement selected index.
    dec top_menu_select
    
    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status

    jmp @end

@down:
    ;;case down
    lda #$20
    bit jp1_data
    beq @a

    lda #3
    cmp top_menu_select
    beq @end

    ;;move cursor down.
    lda top_menu_cur_pos
    sta $02
    lda top_menu_cur_pos+1
    sta $03
    lda un_select_cursor
    sta $00
    lda un_select_cursor+1
    sta $01
    jsr print_str

    clc
    lda #$20
    adc top_menu_cur_pos+1
    sta top_menu_cur_pos+1
    sta $03
    lda #$00
    adc top_menu_cur_pos
    sta top_menu_cur_pos
    sta $02

    lda select_cursor
    sta $00
    lda select_cursor+1
    sta $01
    jsr print_str
    
    ;;increment selected index.
    inc top_menu_select

    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status

    jmp @end

@a:
    ;;case a
    lda #$01
    bit jp1_data
    beq @end

    lda top_menu_select
    sta screen_status   ;;navigate to next screen.

    jsr init_screen

    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status

@end:
    rts
.endproc

.proc inet_screen_updt
    ;;;case up
    lda #$10
    bit jp1_data
    beq @down

    lda #4
    cmp inet_menu_select
    bne :+
    jmp @end
:
    ;;move cursor up.
    lda inet_menu_cur_pos
    sta $02
    lda inet_menu_cur_pos+1
    sta $03
    lda un_select_cursor
    sta $00
    lda un_select_cursor+1
    sta $01
    jsr print_str

    sec
    lda #$20
    sta $00
    lda inet_menu_cur_pos+1
    sbc $00
    sta inet_menu_cur_pos+1
    sta $03

    lda #$00
    sta $00
    lda inet_menu_cur_pos
    sbc $00
    sta inet_menu_cur_pos
    sta $02

    lda select_cursor
    sta $00
    lda select_cursor+1
    sta $01
    jsr print_str

    ;;increment selected index.
    dec inet_menu_select

    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status

    jmp @end

@down:
    ;;case down
    lda #$20
    bit jp1_data
    beq @a

    lda #7
    cmp inet_menu_select
    beq @end

    ;;move cursor down.
    lda inet_menu_cur_pos
    sta $02
    lda inet_menu_cur_pos+1
    sta $03
    lda un_select_cursor
    sta $00
    lda un_select_cursor+1
    sta $01
    jsr print_str

    clc
    lda #$20
    adc inet_menu_cur_pos+1
    sta inet_menu_cur_pos+1
    sta $03
    lda #$00
    adc inet_menu_cur_pos
    sta inet_menu_cur_pos
    sta $02

    lda select_cursor
    sta $00
    lda select_cursor+1
    sta $01
    jsr print_str

    ;;increment selected index.
    inc inet_menu_select

    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status

    jmp @end

@a:
    ;;case a
    lda #$01
    bit jp1_data
    beq @end

    lda #7
    cmp inet_menu_select
    bne :+
    ;;case return.
    jsr main_screen_init
    jmp @next_page_done
:
    lda inet_menu_select
    sta screen_status   ;;navigate to next screen.
    jsr init_screen
@next_page_done:
    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status

@end:

    rts
.endproc

.proc inet_bmark_scr_updt
    ;;;case up
    lda #$10
    bit jp1_data
    beq @down

    lda #0
    cmp bmark_menu_select
    bne :+
    jmp @end
:
    ;;move cursor up.
    lda bmark_menu_cur_pos
    sta $02
    lda bmark_menu_cur_pos+1
    sta $03
    lda un_select_cursor
    sta $00
    lda un_select_cursor+1
    sta $01
    jsr print_str

    sec
    lda #$20
    sta $00
    lda bmark_menu_cur_pos+1
    sbc $00
    sta bmark_menu_cur_pos+1
    sta $03

    lda #$00
    sta $00
    lda bmark_menu_cur_pos
    sbc $00
    sta bmark_menu_cur_pos
    sta $02

    lda select_cursor
    sta $00
    lda select_cursor+1
    sta $01
    jsr print_str

    ;;increment selected index.
    dec bmark_menu_select

    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status

    jmp @end

@down:
    ;;case down
    lda #$20
    bit jp1_data
    beq @a

    lda #4
    cmp bmark_menu_select
    bne :+
    jmp @end
:
    ;;move cursor down.
    lda bmark_menu_cur_pos
    sta $02
    lda bmark_menu_cur_pos+1
    sta $03
    lda un_select_cursor
    sta $00
    lda un_select_cursor+1
    sta $01
    jsr print_str

    clc
    lda #$20
    adc bmark_menu_cur_pos+1
    sta bmark_menu_cur_pos+1
    sta $03
    lda #$00
    adc bmark_menu_cur_pos
    sta bmark_menu_cur_pos
    sta $02

    lda select_cursor
    sta $00
    lda select_cursor+1
    sta $01
    jsr print_str

    ;;increment selected index.
    inc bmark_menu_select

    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status

    jmp @end

@a:
    ;;case a
    lda #$01
    bit jp1_data
    beq @end


    lda #4
    cmp bmark_menu_select
    bne :+
    ;;case return
    lda #$20
    sta $00
    lda #$6d
    sta $01
    lda #$20
    sta $02
    lda #$79
    sta $03
    lda #$21
    sta $04
    lda #$ad
    sta $05
    lda #$21
    sta $06
    lda #$b9
    sta $07
    jsr delete_rect
    jsr inet_screen_init
    jmp @next_page_done
:
    ;;case bmark is selected...
;;;    sta screen_status   ;;navigate to next screen.
;;;    jsr init_screen
@next_page_done:
    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status

@end:

    rts
.endproc

.proc inet_srch_scr_updt
    rts
.endproc

.proc inet_dirct_scr_updt
    rts
.endproc


.proc game_screen_updt
    rts
.endproc

.proc shell_screen_updt
    ;;;case up
    lda #$10
    bit jp1_data
    beq @down

	;;0 - 11 is the top line.
    lda #11
    cmp kb_select
    bcc :+
    jmp @kb_end
:
    lda #$7f
    cmp kb_select
    bne :+
    jmp @kb_end
:
    ;;move cursor up.
    lda kb_cur_pos
    sta $02
    lda kb_cur_pos+1
    sta $03
    lda un_select_cursor
    sta $00
    lda un_select_cursor+1
    sta $01
    jsr print_str

    sec
    lda #$40
    sta $00
    lda kb_cur_pos+1
    sbc $00
    sta kb_cur_pos+1
    sta $03

    lda #$00
    sta $00
    lda kb_cur_pos
    sbc $00
    sta kb_cur_pos
    sta $02

    lda select_cursor
    sta $00
    lda select_cursor+1
    sta $01
    jsr print_str

    ;;update selected index.
    lda #12
    sta $0
    sec
    lda kb_select
    sbc $0
    sta kb_select

    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status

    jmp @kb_end

@down:
    ;;case down
    lda #$20
    bit jp1_data
    bne :+
    jmp @left
:

	;;36 - 47 is the bottom line.
    lda #35
    cmp kb_select
    bcs :+
    jmp @left
:
    ;;move cursor down.
    lda kb_cur_pos
    sta $02
    lda kb_cur_pos+1
    sta $03
    lda un_select_cursor
    sta $00
    lda un_select_cursor+1
    sta $01
    jsr print_str

    clc
    lda #$40
    adc kb_cur_pos+1
    sta kb_cur_pos+1
    sta $03
    lda #$00
    adc kb_cur_pos
    sta kb_cur_pos
    sta $02

    lda select_cursor
    sta $00
    lda select_cursor+1
    sta $01
    jsr print_str

    ;;update selected index.
    lda #12
    clc
    adc kb_select
    sta kb_select

    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status

    jmp @kb_end

@left:
    ;;case left
    lda #$40
    bit jp1_data
    bne :+
    jmp @right
:
	;;left most side is 0, 12, 24, 36.
    lda #0
    cmp kb_select
    bne :+
    jmp @rtn_btn
:
    lda #12
    cmp kb_select
    bne :+
    jmp @rtn_btn
:
    lda #24
    cmp kb_select
    bne :+
    jmp @rtn_btn
:
    lda #36
    cmp kb_select
    bne :+
    jmp @rtn_btn
:
    lda #$7f
    cmp kb_select
    bne :+
    jmp @kb_end
:
    ;;move cursor left.
    lda kb_cur_pos
    sta $02
    lda kb_cur_pos+1
    sta $03
    lda un_select_cursor
    sta $00
    lda un_select_cursor+1
    sta $01
    jsr print_str

    sec
    lda #$2
    sta $00
    lda kb_cur_pos+1
    sbc $00
    sta kb_cur_pos+1
    sta $03

    lda #$00
    sta $00
    lda kb_cur_pos
    sbc $00
    sta kb_cur_pos
    sta $02

    lda select_cursor
    sta $00
    lda select_cursor+1
    sta $01
    jsr print_str

    ;;increment selected index.
    dec kb_select

    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status

    jmp @kb_end

@rtn_btn:
    ;;move cursor to return button pos.
    lda kb_cur_pos
    sta $02
    lda kb_cur_pos+1
    sta $03
    lda un_select_cursor
    sta $00
    lda un_select_cursor+1
    sta $01
    jsr print_str

    lda #$22
    sta $00
    sta kb_cur_pos
    lda #$a1
    sta $03
    sta kb_cur_pos+1

    lda select_cursor
    sta $00
    lda select_cursor+1
    sta $01
    jsr print_str

    ;;set selected index.
    lda #$7f
    sta kb_select

    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status

    jmp @kb_end

@right:
    ;;case down
    lda #$80
    bit jp1_data
    bne :+
    jmp @b
:

	;;right most side is 11, 23, 35, 47
    lda #11
    cmp kb_select
    bne :+
    jmp @kb_end
:
    lda #23
    cmp kb_select
    bne :+
    jmp @kb_end
:
    lda #35
    cmp kb_select
    bne :+
    jmp @kb_end
:
    lda #47
    cmp kb_select
    bne :+
    jmp @kb_end
:
    lda #$7f
    cmp kb_select
    bne :+
    jmp @back_to_kb
:
    ;;move cursor right.
    lda kb_cur_pos
    sta $02
    lda kb_cur_pos+1
    sta $03
    lda un_select_cursor
    sta $00
    lda un_select_cursor+1
    sta $01
    jsr print_str

    clc
    lda #$2
    adc kb_cur_pos+1
    sta kb_cur_pos+1
    sta $03
    lda #$00
    adc kb_cur_pos
    sta kb_cur_pos
    sta $02

    lda select_cursor
    sta $00
    lda select_cursor+1
    sta $01
    jsr print_str

    ;;increment selected index.
    inc kb_select

    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status

    jmp @kb_end

@back_to_kb:
    ;;return from back btn.
    lda kb_cur_pos
    sta $02
    lda kb_cur_pos+1
    sta $03
    lda un_select_cursor
    sta $00
    lda un_select_cursor+1
    sta $01
    jsr print_str

    lda #$22
    sta $00
    sta kb_cur_pos
    lda #$a4
    sta $03
    sta kb_cur_pos+1

    lda select_cursor
    sta $00
    lda select_cursor+1
    sta $01
    jsr print_str

    ;;set selected index.
    lda #00
    sta kb_select

    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status

    jmp @kb_end

@b:
    ;;case b
    ;;select in the buffer.
    lda #$02
    bit jp1_data
    bne :+
    jmp @a
:
    lda #60
    ;;max input text is 60 chars.
    cmp in_text_carret
    bne :+
    jmp @kb_end
:
    lda #$7f
    cmp kb_select
    bne :+
    jmp @end_shell
:
    lda #36
    cmp kb_select
    bne :+
    jmp @sft_btn
:
    lda #35
    cmp kb_select
    bne :+
    jmp @bs_btn
:
    clc

    ;;get selected char in x.
    lda kb_sft_status
    bne :+
    ;;case shift off
    lda text_kb_matrix
    sta $02
    lda text_kb_matrix+1
    sta $03
    jmp @ld_chr
:
    ;;case shift on
    lda text_kb_matrix_s
    sta $02
    lda text_kb_matrix_s+1
    sta $03
@ld_chr:
    ldy kb_select
    lda ($02), y
    tax

    ;;set buf base index.
    ldy in_text_carret
    lda in_text_buf_addr
    sta $00
    lda in_text_buf_addr+1
    sta $01

    ;;set char.
    txa
    sta ($00), y
    iny
    ;;put carret
    lda #$8a
    sta ($00), y
    iny
    ;;terminate.
    lda #0
    sta ($00), y

    lda carret_pos
    sta $02
    lda carret_pos+1
    sta $03
    jsr print_str

    inc in_text_carret

    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status
    jmp @kb_end

@end_shell:
    ;;close all window.
    lda #$20
    sta $00
    sta $01
    lda #$20
    sta $02
    lda #$3e
    sta $03
    lda #$23
    sta $04
    lda #$a0
    sta $05
    lda #$23
    sta $06
    lda #$be
    sta $07
    jsr delete_rect
    ;;back to main screen
    jsr main_screen_init

    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status
    jmp @kb_end

@sft_btn:
    lda kb_sft_status
    bne @s_on

    ;;case shift off
    lda #$22
    sta $02
    lda #$a5
    sta $03
    lda kb_1_s
    sta $00
    lda kb_1_s+1
    sta $01
    jsr print_str

    lda #$22
    sta $02
    lda #$e5
    sta $03
    lda kb_2_s
    sta $00
    lda kb_2_s+1
    sta $01
    jsr print_str

    lda #$23
    sta $02
    lda #$25
    sta $03
    lda kb_3_s
    sta $00
    lda kb_3_s+1
    sta $01
    jsr print_str

    lda #$23
    sta $02
    lda #$65
    sta $03
    lda kb_4_s
    sta $00
    lda kb_4_s+1
    sta $01
    jsr print_str

    ;;set shift on.
    lda #1
    sta kb_sft_status

    lda #$00
    sta jp_status
    jmp @kb_end
@s_on:
    ;;case shift on.
    lda #$22
    sta $02
    lda #$a5
    sta $03
    lda kb_1
    sta $00
    lda kb_1+1
    sta $01
    jsr print_str

    lda #$22
    sta $02
    lda #$e5
    sta $03
    lda kb_2
    sta $00
    lda kb_2+1
    sta $01
    jsr print_str

    lda #$23
    sta $02
    lda #$25
    sta $03
    lda kb_3
    sta $00
    lda kb_3+1
    sta $01
    jsr print_str

    lda #$23
    sta $02
    lda #$65
    sta $03
    lda kb_4
    sta $00
    lda kb_4+1
    sta $01
    jsr print_str

    ;;set shift off
    lda #0
    sta kb_sft_status

    lda #$00
    sta jp_status
    jmp @kb_end

@bs_btn:
    ;;backspace.
    lda in_text_carret
    bne :+
    jmp @kb_end
:

    dec in_text_carret

    ldy in_text_carret
    lda in_text_buf_addr
    sta $00
    lda in_text_buf_addr+1
    sta $01

    ;;put carret
    lda #$8a
    sta ($00), y
    iny
    ;;erase old char.
    lda #' '
    sta ($00), y
    iny
    ;;terminate.
    lda #0
    sta ($00), y

    lda carret_pos
    sta $02
    lda carret_pos+1
    sta $03
    jsr print_str

    lda #$00
    sta jp_status
    jmp @kb_end

@a:
    ;;case a..
    lda #$01
    bit jp1_data
    beq @kb_end


    ;;check if input text is empty.
    ;;the head char is carret(|), then input is empty.
    lda #$8a
    cmp in_text_buf
    beq @kb_end

    ;;send input line to i2c...
    jsr send_i2c

    ;;reset carret.
    lda #$22
    sta $02
    sta carret_pos
    lda #$41
    sta carret_pos+1
    sta $03
    lda #0
    sta in_text_carret
    lda in_text_buf_addr
    sta $00
    lda in_text_buf_addr+1
    sta $01
    lda #$8a
    ldy #0
    sta ($00), y
    ldx #61
    lda #' '
    iny
:
    sta ($00), y
    iny
    dex
    bne :-
    jsr print_str

    ;;invalidate jp input for a while.
    lda #$00
    sta jp_status

@kb_end:

    ;;check i2c input data...
    ;;check fifo_stat empty bit.
    lda fifo_stat
    bne :+
    jsr print_i2c
:
    rts
.endproc


.proc send_i2c
    ;;in_text_carret holds offset from the head.
    ldx in_text_carret
    ;;the tail char is a carret '|', must -1
    dex
    ldy #0

    lda in_text_buf_addr
    sta $00
    lda in_text_buf_addr+1
    sta $01

:
    ;;write i2c fifo
    lda ($00), y
    sta $fff9
    iny
    dex
    bpl :-

    rts
.endproc

.proc scroll_next
    rts
.endproc

.macro  lda_line_addr_lo addr
;;lda imm
;;0xA9, imm
    .byte $A9
    .lobytes addr
.endmacro

.macro  lda_line_addr_hi addr
;;lda imm
;;0xA9, imm
    .byte $A9
    .hibytes addr
.endmacro

.proc shl_disp_move_next
    ldx output_pos+1
    lda output_pos
    cmp #$22
    beq @pg3
    cmp #$21
    beq @pg2
@pg1:

    ldy #5  ;;line=6
    ;;load address of high(line_end_arr1)
    lda_line_addr_lo line_end_arr1
    sta $05
    lda_line_addr_hi line_end_arr1
    sta $06
    jmp @line_check

@pg2:
    ldy #7  ;;line=8
    lda_line_addr_lo line_end_arr2
    sta $05
    lda_line_addr_hi line_end_arr2
    sta $06
    jmp @line_check

@pg3:
;pg3 end needs scroll up.
    lda line_end_arr3
    cmp output_pos+1
    bne :+
    jsr scroll_next
;;last line doesn't move. just cursor pos goes to head.
    lda #02
    sta output_pos+1
    rts
:

@line_check:

:
    lda ($05), y
    sta $07
    cpx $07
    beq @line_end1
    dey
    bpl :-

;;no line/page crossing.
    inc output_pos+1
    jmp @pg_done


@line_end1:
;;new line.
    lda $02
    sta $2006
    lda $03
    sta $2006
    lda $2007

    clc
    lda #5
    adc output_pos+1
    sta output_pos+1
    bcc @pg_done
    inc output_pos

@pg_done:

    rts
.endproc

.proc linefeed
;;if it is last line, scroll_next
    lda #$22
    cmp output_pos
    bne :+
    lda #$02
    sta output_pos+1
    jsr scroll_next
    rts
:

;;goto next line.
;;high half byte is odd num, +1x. (left half pos)
;;high half byte is even num, +2x. (right half pos)
    lda #$10
    and output_pos+1
    bne @odd
@evn:
    lda #$20
    jmp :+
@odd:
    lda #$10
:
    clc
    adc output_pos+1
    bcc :+
    inc output_pos
:
;;low half byte is x2.
    sta $09
    lda #$f0
    and $09
    sta $09
    lda #$02
    ora $09
    sta output_pos+1

    rts
.endproc

.proc print_i2c
;;pop i2c char from fifo..
    lda $fff9
    sta $0

;;check if input is new line char '\n'
    lda #$0a
    cmp $0
    bne :+
    jsr linefeed
    jmp @new_line_ok
:

;;set cursor pos.
    lda output_pos
    sta $02
    lda output_pos+1
    sta $03

    jsr print_chr

    jsr shl_disp_move_next
@new_line_ok:

    ;;loop until fifo is empty or display area is full.
    lda #$10
    and $fff8
    beq print_i2c

    rts
.endproc

.proc inet_screen_init
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
    lda top_menu_internet
    sta $00
    lda top_menu_internet+1
    sta $01
    jsr print_str

    lda #$20
    sta $02
    lda #$83
    sta $03
    lda inet_menu_bookmark
    sta $00
    lda inet_menu_bookmark+1
    sta $01
    jsr print_str

    lda #$20
    sta $02
    lda #$a3
    sta $03
    lda inet_menu_search
    sta $00
    lda inet_menu_search+1
    sta $01
    jsr print_str

    lda #$20
    sta $02
    lda #$c3
    sta $03
    lda inet_menu_direct
    sta $00
    lda inet_menu_direct+1
    sta $01
    jsr print_str

    lda #$20
    sta $02
    lda #$e3
    sta $03
    lda menu_return
    sta $00
    lda menu_return+1
    sta $01
    jsr print_str

    lda #$20
    sta $02
    sta inet_menu_cur_pos
    lda #$82
    sta $03
    sta inet_menu_cur_pos+1
    
    lda select_cursor
    sta $00
    lda select_cursor+1
    sta $01
    jsr print_str

    lda #4
    sta inet_menu_select
    lda #1
    sta screen_status

    rts
.endproc

.proc inet_bmark_scr_init
    ;;create box.
    lda #$20
    sta $00
    lda #$6d
    sta $01
    lda #$20
    sta $02
    lda #$79
    sta $03
    lda #$21
    sta $04
    lda #$ad
    sta $05
    lda #$21
    sta $06
    lda #$b9
    sta $07
    jsr create_rect

    ;;set message.
    lda #$20
    sta $02
    lda #$8f
    sta $03
    lda bm_msn
    sta $00
    lda bm_msn+1
    sta $01
    jsr print_str

    lda #$20
    sta $02
    lda #$af
    sta $03
    lda bm_abc
    sta $00
    lda bm_abc+1
    sta $01
    jsr print_str

    lda #$20
    sta $02
    lda #$cf
    sta $03
    lda bm_cnn
    sta $00
    lda bm_cnn+1
    sta $01
    jsr print_str

    lda #$20
    sta $02
    lda #$ef
    sta $03
    lda bm_bbc
    sta $00
    lda bm_bbc+1
    sta $01
    jsr print_str

    lda #$21
    sta $02
    lda #$0f
    sta $03
    lda menu_return
    sta $00
    lda menu_return+1
    sta $01
    jsr print_str


    lda #$20
    sta $02
    sta bmark_menu_cur_pos
    lda #$8e
    sta $03
    sta bmark_menu_cur_pos+1
    
    lda select_cursor
    sta $00
    lda select_cursor+1
    sta $01
    jsr print_str

    lda #0
    sta bmark_menu_select
    lda #4
    sta screen_status

    rts
.endproc

.proc inet_srch_scr_init
    rts
.endproc

.proc inet_dirct_scr_init
    rts
.endproc

.proc game_screen_init
    rts
.endproc

.proc shell_screen_init
    ;;create box.
    lda #$20
    sta $00
    lda #$21
    sta $01
    lda #$20
    sta $02
    lda #$3e
    sta $03
    lda #$22
    sta $04
    lda #$21
    sta $05
    lda #$22
    sta $06
    lda #$3e
    sta $07
    jsr create_rect

    ;;create box.
    lda #$22
    sta $00
    lda #$83
    sta $01
    lda #$22
    sta $02
    lda #$9d
    sta $03
    lda #$23
    sta $04
    lda #$83
    sta $05
    lda #$23
    sta $06
    lda #$9d
    sta $07
    jsr create_rect

    ;;top right back button
    lda #$22
    sta $02
    lda #$a2
    sta $03
    lda shell_back_btn
    sta $00
    lda shell_back_btn+1
    sta $01
    jsr print_str


    ;;show keyboard first row.
    lda #$22
    sta $02
    lda #$a5
    sta $03
    lda kb_1
    sta $00
    lda kb_1+1
    sta $01
    jsr print_str

    lda #$22
    sta $02
    lda #$e5
    sta $03
    lda kb_2
    sta $00
    lda kb_2+1
    sta $01
    jsr print_str

    lda #$23
    sta $02
    lda #$25
    sta $03
    lda kb_3
    sta $00
    lda kb_3+1
    sta $01
    jsr print_str

    lda #$23
    sta $02
    lda #$65
    sta $03
    lda kb_4
    sta $00
    lda kb_4+1
    sta $01
    jsr print_str

    ;;draw blank text w/ carret.
    lda #$22
    sta $02
    sta carret_pos
    lda #$41
    sta carret_pos+1
    sta $03
    lda #0
    sta in_text_carret
    lda in_text_buf_addr
    sta $00
    lda in_text_buf_addr+1
    sta $01
    lda #$8a
    ldy #0
    sta ($00), y
    ldx #61
    lda #' '
    iny
:
    sta ($00), y
    iny
    dex
    bne :-
    jsr print_str

    lda #$22
    sta $02
    sta kb_cur_pos
    lda #$a4
    sta $03
    sta kb_cur_pos+1
    lda select_cursor
    sta $00
    lda select_cursor+1
    sta $01
    jsr print_str

    lda #3
    sta screen_status

    lda #0
    sta kb_sft_status

    rts
.endproc

.proc main_screen_init
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
    lda #$83
    sta $03
    lda top_menu_internet
    sta $00
    lda top_menu_internet+1
    sta $01
    jsr print_str

    lda #$20
    sta $02
    lda #$a3
    sta $03
    lda top_menu_game
    sta $00
    lda top_menu_game+1
    sta $01
    jsr print_str

    lda #$20
    sta $02
    lda #$c3
    sta $03
    lda top_menu_shell
    sta $00
    lda top_menu_shell+1
    sta $01
    jsr print_str

;;show build ver.
    lda #$23
    sta $02
    lda #$42
    sta $03
    lda build_msg
    sta $00
    lda build_msg+1
    sta $01
    jsr print_str

    lda #$20
    sta $02
    sta top_menu_cur_pos
    lda #$82
    sta $03
    sta top_menu_cur_pos+1

    lda select_cursor
    sta $00
    lda select_cursor+1
    sta $01
    jsr print_str

    ;;set screen status
    lda #1
    sta top_menu_select
    lda #0
    sta screen_status

    ;;ready to input.
    lda #$01
    sta jp_status
    rts
.endproc


;;;param $00, $01 = top left.
;;;param $02, $03 = top right
;;;param $04, $05 = bottom left.
;;;param $06, $07 = bottom right
.proc delete_rect

    ;;calc width
    sec
    lda $03
    sbc $01
    sta $08 ;;$08=width

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

    ldy $09
@y_loop:
    lda $00
    sta $2006
    lda $01
    sta $2006
    ldx $08
    lda #' '
:
    sta $2007
    dex
    bpl :-

    lda #$20
    clc
    adc $01
    bcc :+
    inc $00
:
    sta $01
    dey
    bpl @y_loop

    rts
.endproc


;;;param $00, $01 = top left.
;;;param $02, $03 = top right
;;;param $04, $05 = bottom left.
;;;param $06, $07 = bottom right
.proc create_rect

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


.proc char_test
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


;;;param $00 = char to display.
;;;param $02, $03 = vram pos
;;;print character at the pos specified in the parameter.
.proc print_chr
    lda $02
    sta $2006
    lda $03
    sta $2006

    lda $00
    sta $2007

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
    beq @print_done
    sta $2007
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


;;init menu items.
.proc init_menu
    lda #0
    sta screen_status
    lda #1
    sta top_menu_select
    lda #4
    sta inet_menu_select

    lda #0
    sta bmark_menu_select
    rts
.endproc

;;ppu initialize
.proc init_ppu

;;init vram...
;;2000 - 3000 (16 pages.)
    ldx #16
    lda #$20
    sta $0
@xloop:
    lda $0
    sta $2006
    lda #$00
    sta $2006

    lda #' '
    ldy #0
:
    sta $2007
    iny
    beq :+
    jmp :-
:
    inc $0
    dex
    bne @xloop

;;init attr.
    lda #$23
    sta $2006
    lda #$c0
    sta $2006

    lda #0
    ldy #0
:
    sta $2007
    iny
    beq :+
    jmp :-
:

;;init sprite.
    lda #0
    sta $2003

    ldy #0
:
    sta $2004
    iny
    bne :-


;;vram pos start from the top left.
    lda #$20
    sta vram_current
    lda #$00
    sta vram_current + 1

    ;;init shell i2c display pos.
    lda #$20
    sta output_pos
    lda #$42
    sta output_pos+1

    ;ppu register initialize.
    lda    #$00
    sta    $2000
    sta ppu_ctl
    sta    $2001
    sta ppu_mask

    ;;load palette.
    lda    #$3f
    sta    $2006
    lda    #$00
    sta    $2006

    ldx    #$00
    ldy    #$20
@copypal:
    lda    @palettes, x
    sta    $2007
    inx
    dey
    bne    @copypal
    rts

@palettes:
;;;bg palette
    .byte    $0f, $00, $10, $20
    .byte    $0f, $04, $14, $24
    .byte    $0f, $08, $18, $28
    .byte    $0f, $0c, $1c, $2c
;;;spr palette
    .byte    $0f, $00, $10, $20
    .byte    $0f, $06, $16, $26
    .byte    $0f, $08, $18, $28
    .byte    $0f, $0a, $1a, $2a

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

select_cursor:
    .addr   :+
:
    .byte   $8b
    .byte   $00

un_select_cursor:
    .addr   :+
:
    .byte   " "
    .byte   $00

inet_menu_bookmark:
    .addr   :+
:
    .byte   "Bookmark"
    .byte   $00

inet_menu_search:
    .addr   :+
:
    .byte   "Search"
    .byte   $00

inet_menu_direct:
    .addr   :+
:
    .byte   "Direct"
    .byte   $00

inet_menu_history:
    .addr   :+
:
    .byte   "History"
    .byte   $00

menu_return:
    .addr   :+
:
    .byte   "Return"
    .byte   $00

bm_msn:
    .addr   :+
:
    .byte   "MSN"
    .byte   $00

bm_abc:
    .addr   :+
:
    .byte   "ABC"
    .byte   $00

bm_cnn:
    .addr   :+
:
    .byte   "CNN"
    .byte   $00

bm_bbc:
    .addr   :+
:
    .byte   "BBC"
    .byte   $00

kb_1:
    .addr   :+
:
    .byte   "1 2 3 4 5 6 7 8 9 0 - ="
    .byte   $00

kb_2:
    .addr   :+
:
    .byte   "q w e r t y u i o p [ ]"
    .byte   $00

kb_3:
    .addr   :+
:
    .byte   "a s d f g h j k l ; ' "
    .byte   $88
    .byte   $00

kb_4:
    .addr   :+
:
    .byte   $87
    .byte   " z x c v b n m , . / "
    .byte   $89
    .byte   $00

kb_1_s:
    .addr   :+
:
    .byte   "! @ # $ % ^ & * ( ) _ +"
    .byte   $00

kb_2_s:
    .addr   :+
:
    .byte   "Q W E R T Y U I O P { }"
    .byte   $00

kb_3_s:
    .addr   :+
:
    .byte   "A S D F G H J K L : "
    .byte   '"'
    .byte   ' '
    .byte   $88
    .byte   $00

kb_4_s:
    .addr   :+
:
    .byte   $86
    .byte   " Z X C V B N M < > ? "
    .byte   $89
    .byte   $00

in_text_buf_addr:
    .addr   in_text_buf

shell_back_btn:
    .addr   :+
:
    .byte   $8c
    .byte   $00

text_kb_matrix:
    .addr   :+
:
    .byte   "1234567890-="
    .byte   "qwertyuiop[]"
    .byte   "asdfghjkl;' "
    .byte   " zxcvbnm,./ "

text_kb_matrix_s:
    .addr   :+
:
    .byte   "!@#$%^&*()_+"
    .byte   "QWERTYUIOP{}"
    .byte   "ASDFGHJKL:"
    .byte   '"'
    .byte   $0
    .byte   " ZXCVBNM<>? "


;;page 2042 - 20fd
line_end_arr1:
    .byte   $5d, $7d, $9d, $bd, $dd, $fd

;;page 2102 - 21fd
line_end_arr2:
    .byte   $1d, $3d, $5d, $7d, $9d, $bd, $dd, $fd

;;page 2202 - 221d
line_end_arr3:
    .byte   $1d


;;;;r/w global variables.
.segment "BSS"
vram_current:
    .byte   $00
    .byte   $00

;;screen status
;   0: top page
;   1: internet top page
;   2: game top page
;   3: shell top page
;   4: bookmakr page
;   5: search page
;   6: direct page
screen_status:
    .byte   $00

;1 - 3
top_menu_select:
    .byte   $00

;4 - 6
inet_menu_select:
    .byte   $00

;0 - 4
bmark_menu_select:
    .byte   $00

; 0 - 11
;12 - 23
;24 - 35
;36 - 47
kb_select:
    .byte   $00

top_menu_cur_pos:
    .byte   $00
    .byte   $00

inet_menu_cur_pos:
    .byte   $00
    .byte   $00

bmark_menu_cur_pos:
    .byte   $00
    .byte   $00

kb_cur_pos:
    .byte   $00
    .byte   $00

carret_pos:
    .byte   $00
    .byte   $00

;;in_text_carret is the offset in from the text buffer top.
in_text_carret:
    .byte   $00

;;input text buffer is 2 lines (60 char + null char.)
in_text_buf:
    .byte   $8a     ;; 0x8a is carret chr code.
.repeat 63
    .byte   $00
.endrepeat

output_pos:
    .byte   $00
    .byte   $00

;;input ready: 1
;;input suspend: 0
jp_status:
    .byte   $00

kb_sft_status:
    .byte   $00
