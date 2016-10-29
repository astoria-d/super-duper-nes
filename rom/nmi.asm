.setcpu		"6502"
.autoimport	on

.export nmi_proc

.segment "STARTUP"

.proc	nmi_proc
    ;;stop nmi
    lda #$80
    eor ppu_ctl
    sta ppu_ctl
    sta $2000
    
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

    jsr update_screen

    ;;enable nmi
    lda #$80
    ora ppu_ctl
    sta ppu_ctl
    sta $2000
    rti
.endproc


;;;;r/w global variables.
.segment "BSS"

;;;jp1_data bit 0 to 7
;;a button
;;b button
;;select button
;;start button
;;up button
;;down button
;;left button
;;right button
jp1_data:
    .byte   $00
