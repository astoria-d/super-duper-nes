.setcpu		"6502"
.autoimport	on

.export nmi_proc
.export jp1_data
.export jp_suspend_cnt
.export fifo_stat

.segment "STARTUP"

.proc	nmi_proc
    ;;stop nmi
    lda #$80
    eor ppu_ctl
    sta ppu_ctl
    sta $2000
    
    ;;hide bg/sprite.
	lda	#$18
	eor ppu_mask
	sta	$2001
	sta	ppu_mask

    ;;read controller button status.
    lda #$00
    sta jp1_data

    ;;check joypad button stat.
    lda #$01
    sta $4016
    lda #$00
    sta $4016

    ;;a button
    lda #$01
    bit $4016
    beq :+
    ora #$01
    sta jp1_data
:
    ;;b button
    lda #$01
    bit $4016
    beq :+
    ora #$02
    sta jp1_data
:
    ;;select button
    lda #$01
    bit $4016
    beq :+
    ora #$04
    sta jp1_data
:
    ;;start button
    lda #$01
    bit $4016
    beq :+
    ora #$08
    sta jp1_data
:
    ;;up button
    lda #$01
    bit $4016
    beq :+
    ora #$10
    sta jp1_data
:
    ;;down button
    lda #$01
    bit $4016
    beq :+
    ora #$20
    sta jp1_data
:
    ;;left button
    lda #$01
    bit $4016
    beq :+
    ora #$40
    sta jp1_data
:
    ;;right button
    lda #$01
    bit $4016
    beq :+
    ora #$80
    sta jp1_data
:

    ;;check i2c queue.

;;0xfff9	w: push fifo register
;;	r: pop fifo register
;;0xfff8	fifo status register

;;firo status register
;;bit	
;;0	write fifo empty
;;1	write fifo full
;;2	always 0
;;3	always 0
;;4	read fifo empty
;;5	read fifo full
;;6	always 0
;;7	always 0

    lda #$10
    and $fff8
    sta fifo_stat
    bne :+
    jmp @need_update
:

    ;;check jp1 status...
    lda jp_status
    beq @no_update
    
@need_update:
    jsr update_screen
    jmp @update_done

@no_update:
    inc jp_suspend_cnt
    lda jp_suspend_rate
    cmp jp_suspend_cnt
    bne @update_done
    lda #$00
    sta jp_suspend_cnt
    lda #$01
    sta jp_status
@update_done:
    ;;clear ppu reg.
    lda $2002

    ;;scroll reg set.
    lda #$00
    ;;clear ppu addr reg.
    sta $2006
    sta $2006
    ;set scroll reg.
    sta $2005
    sta $2005

    ;;show bg/sprite.
	lda	#$18
	ora ppu_mask
	sta	$2001
	sta	ppu_mask

    ;;enable nmi
    lda #$80
    ora ppu_ctl
    sta ppu_ctl
    sta $2000
    rti
.endproc

jp_suspend_rate:
    .byte   10


;;;;r/w global variables.
.segment "BSS"

;;;jp1_data bit
;;0: a button
;;1: b button
;;2: select button
;;3: start button
;;4: up button
;;5: down button
;;6: left button
;;7: right button
jp1_data:
    .byte   $00

jp_suspend_cnt:
    .byte   $00

fifo_stat:
    .byte   $00
