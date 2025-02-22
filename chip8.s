; 5E-5F holds the current keypad state, 58-59 holds the old vector to the keyboard
; $60-$67 are 16 bit registers, $68-$6E are 8 bit registers, $6F is the jiffy clock, $7C-$7F are pointers
; $70-$71 is the instruction register, $72-$75 are the splitter locations, $76-78 are the randByte parameters
*= $801
dcb $0B $08 $01 $00 $9E $34 $30 $39 $36 $00 $00 $00
*= $1000
; Data table, registers start at $1080, pc is $7E-7F, I is $1092, timer is $1094, sound is $1095, sp is $1096, speed is $1097, sound toggle is $1098
	jmp start
;Font data
	dcb $F0 $90 $90 $90 $F0
	dcb $20 $60 $20 $20 $70
	dcb $F0 $10 $F0 $80 $F0
	dcb $F0 $10 $F0 $10 $F0
	dcb $90 $90 $F0 $10 $10
	dcb $F0 $80 $F0 $10 $F0
	dcb $F0 $80 $F0 $90 $F0
	dcb $F0 $10 $20 $40 $40
	dcb $F0 $90 $F0 $90 $F0
	dcb $F0 $90 $F0 $10 $F0
	dcb $F0 $90 $F0 $90 $90
	dcb $E0 $90 $E0 $90 $E0
	dcb $F0 $80 $80 $80 $F0
	dcb $E0 $90 $90 $90 $E0
	dcb $F0 $80 $F0 $80 $F0
	dcb $F0 $80 $F0 $80 $80
*= $1060
	dcb $2F $02 $03 $04 $11 $12 $13 $1F $20 $21 $2E $30 $05 $14 $22 $31
*= $1100
keyboard:
	and #$FF
	bmi keyUp
keyDown:
	cmp #$F
	bne notBackspace
	lda #$1
	sta $50
	rts
notBackspace:
	cmp #$2B
	bne notEnter
	jsr clearScr
	lda #$32
	sta $7F
	lda #$0
	sta $7E
	rts
notEnter:
	cmp #$D
	bne notEquals
	dec $1097
	lda $1097
	and #$F
	sta $1097
	rts
notEquals:
	cmp #$C
	bne notMinus
	inc $1097
	lda $1097
	and #$F
	sta $1097
	rts
notMinus:
	cmp #$B
	bne dontQuit
	lda $1098
	eor #$1
	sta $1098
	rts
dontQuit:
	jsr keyDecode
	bcs exitKeyboard
	lda $5E
	ora $5C
	sta $5E
	lda $5F
	ora $5D
	sta $5F
keyUp:
	and #$7F
	jsr keyDecode
	bcs exitKeyboard
	lda #$FF
	sec
	sbc $5C
	sta $5C
	lda #$FF
	sec
	sbc $5D
	sta $5D
	lda $5E
	and $5C
	sta $5E
	lda $5F
	and $5D
	sta $5F
exitKeyboard:
	rts
keyboardInit:
	sei
	lda $32E
	sta $58
	lda $32F
	sta $59
	lda #$00
	sta $32E
	sta $5F
	sta $5E
	lda #$11
	sta $32F
	cli
	rts
keyDecode:
	ldy #$0
decodeLoop:
	cmp $1060,y
	beq foundKey
	iny
	cpy #$10
	bne decodeLoop
	sec
	rts
foundKey:
	lda #$1
	sta $5C
	sta $5D
	dec $5D
shiftLoop:
	cpy #$0
	beq doneShifting
	clc
	rol $5C
	rol $5D
	dey
	jmp shiftLoop
doneShifting:
	clc
	rts
keyboardRestore:
	lda $58
	sta $32E
	lda $59
	sta $32F
	rts
mult:
	lda #$0
	sta $6A
	ldx #$8
multLoop:
	lda $69
	and #$1
	beq noAdd
	lda $6A
	clc
	adc $68
	sta $6A
noAdd:
	asl $68
	lsr $69
	dex
	bne multLoop
	rts
randinit:
	jsr $FECF
	stx $77
	and #$FC
	bne multiplierNotZero
	txa
	and #$FC
multiplierNotZero:
	ora #$1
	sta $76
	tya
	ora #$1
	sta $78
	rts
randbyte:
	lda $76
	sta $68
	lda $77
	sta $69
	jsr mult
	lda $6A
	clc
	adc $78
	sta $77
	rts
pcplus2:
	inc $7E
	inc $7E
	lda $7E
	beq plusCarry
	cmp #$1
	beq plusCarry
	rts
plusCarry:
	inc $7F
	lda $7F
	and #$F
	ora #$30
	sta $7F
	rts
pcminus2:
	dec $7E
	dec $7E
	lda $7E
	cmp #$FE
	bcs minusBorrow
	rts
minusBorrow:
	dec $7F
	lda $7F
	and #$F
	ora #$30
	sta $7F
	rts
blockCopy:
	dey
	lda ($60),y
	sta ($62),y
	cpy #$0
	bne blockCopy
	rts
stall:
	dey
	bne stall
	rts
superStall:
	ldy #$FF
	jsr stall
	dex
	bne superStall
	rts
drawBorder:
	lda #$21
	sta $9F22
	lda #$BD
	sta $9F21
borderLoopFull:
	lda #$F
	sta $9F20
borderLineLoop:
	lda #$55
	sta $9F23
	lda $9F20
	cmp #$93
	bne borderLineLoop
	inc $9F21
	lda $9F21
	cmp #$DF
	bne borderLoopFull
clearScr:
	lda #$21
	sta $9F22
	lda #$BE
	sta $9F21
clrLoopFull:
	lda #$11
	sta $9F20
clrLineLoop:
	lda #$0
	sta $9F23
	lda $9F20
	cmp #$91
	bne clrLineLoop
	inc $9F21
	lda $9F21
	cmp #$DE
	bne clrLoopFull
nothingToDraw:
	rts
drawSprite:
	lda #$0
	sta $6C
	cmp $75
	beq nothingToDraw
	lda #$1
	sta $9F22
	lda $1092
	sta $69
	lda $1093
	sta $6A
	lda $1080,x
	and #$3F
	asl
	clc
	adc #$11
	sta $68
	lda $1080,y
	and #$1F
	clc
	adc #$BE
	sta $9F21
	ldy #$0
	ldx #$8
spriteLine:
	lda $68
	sta $9F20
	lda ($69),y
spriteLineLoop:
	asl
	sta $6B
	bcc noFlip
	lda #$11
	eor $9F23
	sta $9F23
	bne noFlip
	lda #$1
	sta $6C
noFlip:
	inc $9F20
	inc $9F20
	lda $9F20
	cmp #$91
	bne notEndOfLine
	lda #$11
	sta $9F20
notEndOfLine:
	lda $6B
	dex
	bne spriteLineLoop
	dec $75
	beq endDrawSprite
	inc $9F21
	lda $9F21
	cmp #$DE
	bne noYOverflow
	lda #$BE
	sta $9F21
noYOverflow:
	inc $69
	bne noIRollover
	inc $6A
	lda $6A
	and #$F
	ora #$30
	sta $6A
noIRollover:
	jmp spriteLine
endDrawSprite:
	lda $6C
	sta $108F
	rts
start:
	lda #$0
	sta $50
	clc
	jsr $FF5F
	jsr keyboardInit
;Draws black background
	lda #$B0
	sta $9F21
	lda #$11
	sta $9F22
drawRows:
	jsr drawLine
	inc $9F21
	lda $9F21
	cmp #$EC
	bne drawRows
	beq ramSetup
drawLine:
	lda #$0
	sta $9F20
drawLineLoop:
	lda #$0
	sta $9F23
	lda $9F20
	cmp #$A0
	bne drawLineLoop
	rts
ramSetup:
	jsr drawBorder
	lda #$03
	sta $60
	lda #$10
	sta $61
	ldy #$50
	lda #$00
	sta $62
	lda #$30
	sta $63
	jsr blockCopy
	lda #$10
	sta $7D
	lda #$90
	sta $7C
	lda #$32
	sta $7F
	lda #$0
	sta $7E
	lda #$30
	sta $1093
	lda #$6
	sta $1097
	lda #$1
	sta $1098
	lda #$FF
	sta $1096
	jsr randinit
	jsr $FFDE
	sta $6F
cpuLoop:
	ldy #$00
	lda ($7E),y
	sta $70
	iny
	lda ($7E),y
	sta $71
splitter:
	and #$F
	sta $75
	lda $71
	lsr
	lsr
	lsr
	lsr
	sta $74
	lda $70
	and #$F
	sta $73
	lda $70
	lsr
	lsr
	lsr
	lsr
	sta $72
	lda $72
	bne IN1NNN
	lda $73
	bne IN0NNN
	lda $71
	cmp #$E0
	bne IN00EE
	jsr clearScr
	jmp inFinish
IN00EE:
	cmp #$EE
	bne IN0NNN
	ldy $1096
	cpy #$FF
	bne validStackPop
	ldy #$9F
validStackPop:
	iny
	lda $1000,y
	and #$F
	ora #$30
	sta $7F
	iny
	lda $1000,y
	sta $7E
	sty $1096
IN0NNN:
	jmp inFinish
IN1NNN:
	lda $72
	cmp #$1
	bne IN2NNN
	lda $73
	ora #$30
	sta $7F
	lda $71
	sta $7E
	jsr pcminus2
	jmp inFinish
IN2NNN:
	cmp #$2
	bne IN3XKK
	ldy $1096
	cpy #$9F
	bne validStackPush
	ldy #$FF
validStackPush:
	lda $7E
	sta $1000,y
	dey
	lda $7F
	sta $1000,y
	dey
	sty $1096
	lda $73
	ora #$30
	sta $7F
	lda $71
	sta $7E
	jsr pcminus2
	jmp inFinish
IN3XKK:
	cmp #$3
	bne IN4XKK
	ldy $73
	lda $1080,y
	cmp $71
	bne XNEKK
	jsr pcplus2
XNEKK:
	jmp inFinish
IN4XKK:
	cmp #$4
	bne IN5XY0
	ldy $73
	lda $1080,y
	cmp $71
	beq XEKK
	jsr pcplus2
XEKK:
	jmp inFinish
IN5XY0:
	cmp #$5
	bne IN6XKK
	lda $75
	bne XNEY
	ldy $73
	lda $1080,y
	ldy $74
	cmp $1080,y
	bne XNEY
	jsr pcplus2
XNEY:
	jmp inFinish
IN6XKK:
	cmp #$6
	bne IN7XKK
	ldy $73
	lda $71
	sta $1080,y
	jmp inFinish
IN7XKK:
	cmp #$7
	bne IN8NNN
	ldx $73
	lda $1080,x
	clc
	adc $71
	sta $1080,x
	clc
	jmp inFinish
IN8NNN:
	cmp #$8
	beq IN8XY0
	jmp IN9XY0
IN8XY0:
	ldx $73
	ldy $74
	lda $75
	bne IN8XY1
	lda $1080,y
	sta $1080,x
	jmp inFinish
IN8XY1:
	cmp #$1
	bne IN8XY2
	lda $1080,x
	ora $1080,y
	sta $1080,x
	jmp inFinish
IN8XY2:
	cmp #$2
	bne IN8XY3
	lda $1080,x
	and $1080,y
	sta $1080,x
	jmp inFinish
IN8XY3:
	cmp #$3
	bne IN8XY4
	lda $1080,x
	eor $1080,y
	sta $1080,x
	jmp inFinish
IN8XY4:
	cmp #$4
	bne IN8XY5
	lda $1080,x
	clc
	adc $1080,y
	sta $1080,x
	lda #$0
	adc #$0
	sta $108F
	jmp inFinish 
IN8XY5:
	cmp #$5
	bne IN8XY6
	lda $1080,x
	sec
	sbc $1080,y
	sta $1080,x
	lda #$0
	adc #$0
	sta $108F
	jmp inFinish
IN8XY6:
	cmp #$6
	bne IN8XY7
	clc
	lda $1080,x
	lsr
	sta $1080,x
	lda #$0
	adc #$0
	sta $108F
	jmp inFinish
IN8XY7:
	cmp #$7
	bne IN8XYE
	lda $1080,y
	sec
	sbc $1080,x
	sta $1080,x
	lda #$0
	adc #$0
	sta $108F
	jmp inFinish
IN8XYE:
	cmp #$E
	bne IN8XYN
	clc
	lda $1080,x
	asl
	sta $1080,x
	lda #$0
	adc #$0
	sta $108F
IN8XYN:
	jmp inFinish
IN9XY0:	
	cmp #$9
	bne INANNN
	lda $75
	bne XEY
	ldy $73
	lda $1080,y
	ldy $74
	cmp $1080,y
	beq XEY
	jsr pcplus2
XEY:
	jmp inFinish
INANNN:
	cmp #$A
	bne INBNNN
	lda $71
	sta $1092
	lda $70
	and #$F
	ora #$30
	sta $1093
	jmp inFinish
INBNNN:
	cmp #$B
	bne INCXKK
	lda $71
	clc
	adc $1080
	sta $7E
	lda $70
	adc #$0
	and #$F
	ora #$30
	sta $7F
	jsr pcminus2
	jmp inFinish
INCXKK:
	cmp #$C
	bne INDXYN
	jsr randbyte
	and $71
	ldy $73
	sta $1080,y
	jmp inFinish
INDXYN:
	cmp #$D
	bne INEXNN
	ldx $73
	ldy $74
	jsr drawSprite
	jmp inFinish
INEXNN:
	cmp #$E
	bne INFXNN
	lda $5E
	sta $68
	lda $5F
	sta $69
	ldx $73
	lda $1080,x
	tax
	clc
bitSelection:
	cpx #$0
	beq foundBit
	clc
	ror $69
	ror $68
	dex
	jmp bitSelection
foundBit:
	lda $68
	and #$1
	tax
	lda $71
	cmp #$9E
	bne INEXA1
	txa
	bne doInputSkip
	jmp inFinish
INEXA1:
	cmp #$A1
	bne INENNN
	txa
	beq doInputSkip
INENNN:
	jmp inFinish
doInputSkip:
	jsr pcplus2
	jmp inFinish
INFXNN:
	lda $71
	cmp #$7
	bne INFX0A
	lda $1094
	ldx $73
	sta $1080,x
	jmp inFinish
INFX0A:
	cmp #$A
	bne INFX15
	ldy #$1
waitForKey:
	dey
	lda $5E
	bne foundKeyPress
	iny
	lda $5F
	bne foundKeyPress
	beq waitForKey
foundKeyPress:
	ldx #$0
	stx $68
tryNextKey:
	cmp #$1
	beq identifiedKey
	inc $68
	asl
	jmp tryNextKey
identifiedKey:
	lda $68
	cpy #$1
	bne skipAddEight
	clc
	adc #$8
skipAddEight:
	ldx $73
	sta $1080,x
	jmp inFinish
INFX15:
	cmp #$15
	bne INFX18
	ldx $73
	lda $1080,x
	sta $1094
	jmp inFinish
INFX18:
	cmp #$18
	bne INFX1E
	ldx $73
	lda $1080,x
	sta $1095
	jmp inFinish
INFX1E:
	cmp #$1E
	bne INFX29
	ldx $73
	lda $1080,x
	clc
	adc $1092
	sta $1092
	lda $1093
	adc #$0
	and #$F
	ora #$30
	sta $1093
	jmp inFinish
INFX29:
	cmp #$29
	bne INFX33
	lda #$5
	sta $68
	ldx $73
	lda $1080,x
	sta $69
	jsr mult
	lda $6A
	sta $1092
	lda #$30
	sta $1093
	jmp inFinish
INFX33:
	cmp #$33
	bne INFX55
	lda $1092
	sta $68
	lda $1093
	sta $69
	ldy #$0
	sty $6A
	ldx $73
	lda $1080,x
hundredLoop:
	cmp #$64
	bcc noMoreHundreds
	inc $6A
	sec
	sbc #$64
	jmp hundredLoop
noMoreHundreds:
	tax
	lda $6A
	sta ($68),y
	sty $6A
	txa
tenLoop:
	cmp #$A
	bcc noMoreTens
	inc $6A
	sec
	sbc #$A
	jmp tenLoop
noMoreTens:
	iny
	iny
	sta ($68),y
	dey
	lda $6A
	sta ($68),y
	jmp inFinish
INFX55:
	cmp #$55
	bne INFX65
	lda #$80
	sta $60
	lda #$10
	sta $61
	lda $1092
	sta $62
	lda $1093
	sta $63
	ldy $73
	iny
	jsr blockCopy
	jmp inFinish
INFX65:
	cmp #$65
	bne inFinish
	lda #$80
	sta $62
	lda #$10
	sta $63
	lda $1092
	sta $60
	lda $1093
	sta $61
	ldy $73
	iny
	jsr blockCopy
inFinish:
	jsr pcplus2
	lda $50
	bne exit
	jsr $FFDE
	sta $6E
	sec
	sbc $6F
	beq skipTimers
	sta $6D
	lda $1094
	beq skipDelay
	cmp $6D
	bcs noDelayOverflow
	lda $6D
noDelayOverflow:
	sec
	sbc $6D
	sta $1094
skipDelay:
	lda $1095
	beq skipSound
	cmp $6D
	bcs noSoundOverflow
	lda $6D
noSoundOverflow:
	sec
	sbc $6D
	sta $1095
skipSound:
	lda $6E
	sta $6F
skipTimers:
	lda $1095
	beq dontBeep
	lda $1098
	beq dontBeep
	lda #$7
	jsr $FFD2
dontBeep:
	jsr randbyte
	ldx $1097
	jsr superStall
	jmp cpuLoop
exit:
	jsr keyboardRestore
	lda #$0
	clc
	jsr $FF5F
	rts
	


