	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
CIAAPRA             equ $BFE001	
CIABPRB             equ $BFD100	
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
entry:	
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	lea	level4InterruptHandler(pc),a3
 	move.l	a3,LVL4_INT_VECTOR
	lea	level5InterruptHandler(pc),a3
 	move.l	a3,LVL5_INT_VECTOR
	lea	level6InterruptHandler(pc),a3
 	move.l	a3,LVL6_INT_VECTOR

	; Install copper list and enable DMA
	lea CUSTOM,a1
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	
	; move.w	#$8090,INTENA(a1) ; Enable Copper and Audio interrupts
	move.b  #$7F,$BFDD00  ; Disable CIA B interrupts
	move.b  #$7F,$BFED01  ; Disable CIA A interrupts

	
.mainLoop:

	ds.w 500,$4E71 ; NOP field
	bra	.mainLoop

level3InterruptHandler:
	movem.l	d0-a6,-(sp)

.checkVerticalBlank:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_VERTB,d0	
	beq.w	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; Clear interrupt bit	
	move.w  #$000,COLOR00(a5)       ; Clear background color

.resetBitplanePointers:
	lea	bitplanes(pc),a1
	lea     BPL1PTH(a5),a2
	moveq	#SCREEN_BIT_DEPTH-1,d0

.bitplaneloop:
	move.l	a1,(a2)
	lea	SCREEN_WIDTH_BYTES(a1),a1 ; bit plane data is interleaved
	addq	#4,a2
	dbra	d0,.bitplaneloop
	
.checkCopper:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_COPER,d0	
	beq.s	.interruptComplete

.copperInterrupt:
	move.w	#INTF_COPER,INTREQ(a5)	; clear interrupt bit	
	
.interruptComplete:
	move.w	#$70,INTREQ(a5)
	movem.l	(sp)+,d0-a6
	rte

level4InterruptHandler:
	move.w  #$F00,$DFF180 
	nop
	move.w  #$0F0,$DFF180 
	nop
	move.w  #$00F,$DFF180 
	nop
	move.w  #$000,$DFF180 
	move.w  #$0080,$DFF09C ; Acknowledge level 4 interrupt
	rte

level5InterruptHandler:
	move.w  #$00F,$DFF180 
	nop
	move.w  #$FFF,$DFF180 
	nop
	move.w  #$F00,$DFF180 
	nop
	move.w  #$000,$DFF180 
	move.w  #$0800,$DFF09C ; Acknowledge level 5 interrupt
	rte

level6InterruptHandler:
	move.w  #$FF0,$DFF180 
	nop
	move.w  #$0F0,$DFF180 
	nop
	move.w  #$0FF,$DFF180 
	nop
	move.w  #$000,$DFF180 
	move.w  #$2000,$DFF09C  ; Acknowledge level 6 interrupt
	rte

copper:
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPLCON0,(0<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES

	dc.w    $1F39, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000

	dc.w	INTENA,$A880         ; Enable level 4, level 5, level 6 interrupts

	dc.w    $3139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8880         ; Trigger level 4 + level 5 interrupt
	dc.w 	INTREQ,$0800         ; Delete level 5 interrupt
	dc.w    COLOR00,$000

	dc.w    $413B, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8880         ; Trigger level 4 + level 5 interrupt
	dc.w 	INTREQ,$0800         ; Delete level 5 interrupt
	dc.w    COLOR00,$000

	dc.w    $513D, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8880         ; Trigger level 4 + level 5 interrupt
	dc.w 	INTREQ,$0800         ; Delete level 5 interrupt
	dc.w    COLOR00,$000

	dc.w    $6139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8880         ; Trigger level 4 + level 5 interrupt
	dc.w 	INTREQ,$0080         ; Delete level 4 interrupt
	dc.w    COLOR00,$000

	dc.w    $713B, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8880         ; Trigger level 4 + level 5 interrupt
	dc.w 	INTREQ,$0080         ; Delete level 4 interrupt
	dc.w    COLOR00,$000

	dc.w    $813D, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8880         ; Trigger level 4 + level 5 interrupt
	dc.w 	INTREQ,$0080         ; Delete level 4 interrupt
	dc.w    COLOR00,$000

	dc.w    $9139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Trigger level 4 interrupt
	dc.w 	INTREQ,$8800         ; Trigger level 5 interrupt
	dc.w 	INTREQ,$0800         ; Delete level 5 interrupt
	dc.w    COLOR00,$000

	dc.w    $A13B, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Trigger level 4 interrupt
	dc.w 	INTREQ,$8800         ; Trigger level 5 interrupt
	dc.w 	INTREQ,$0800         ; Delete level 5 interrupt
	dc.w    COLOR00,$000

	dc.w    $B13D, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Trigger level 4 interrupt
	dc.w 	INTREQ,$8800         ; Trigger level 5 interrupt
	dc.w 	INTREQ,$0800         ; Delete level 5 interrupt
	dc.w    COLOR00,$000

	dc.w    $C139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Trigger level 4 interrupt
	dc.w 	INTREQ,$8800         ; Trigger level 5 interrupt
	dc.w 	INTREQ,$A000         ; Trigger level 6 interrupt
	dc.w 	INTREQ,$A880         ; Delete all interrupt
	dc.w    COLOR00,$000

	dc.w    $D139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8800         ; Trigger level 5 interrupt
	dc.w 	INTREQ,$8080         ; Trigger level 4 interrupt
	dc.w 	INTREQ,$A000         ; Trigger level 6 interrupt
	dc.w 	INTREQ,$A880         ; Delete all interrupt
	dc.w    COLOR00,$000

	dc.w    $E139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$A000         ; Trigger level 6 interrupt
	dc.w 	INTREQ,$8800         ; Trigger level 5 interrupt
	dc.w 	INTREQ,$2000         ; Delete level 6 interrupt
	dc.w 	INTREQ,$8080         ; Trigger level 4 interrupt
	
	dc.w    COLOR00,$000

	dc.w    $F139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$A000         ; Trigger level 6 interrupt
	dc.w 	INTREQ,$8800         ; Trigger level 5 interrupt	
	dc.w 	INTREQ,$2000         ; Delete level 6 interrupt
	dc.w 	INTREQ,$0800         ; Delete level 5 interrupt
	dc.w    COLOR00,$000

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.w    $0139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$A000         ; Trigger level 6 interrupt
	dc.w 	INTREQ,$8800         ; Trigger level 5 interrupt
	dc.w 	INTREQ,$8080         ; Trigger level 4 interrupt
	dc.w    COLOR00,$000

	dc.w    $1139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w    COLOR00,$000

	dc.w    $2139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w    COLOR00,$000

	dc.w    $3139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w    COLOR00,$000

	dc.w	INTENA,$2880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
	