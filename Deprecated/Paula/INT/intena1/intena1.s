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

	move.w INTENAR(a1),COLOR00(a1)
	move.w INTENAR(a1),COLOR00(a1)
	move.w INTENAR(a1),COLOR00(a1)
	move.w INTENAR(a1),COLOR00(a1)
	move.w INTENAR(a1),COLOR00(a1)
	move.w INTENAR(a1),COLOR00(a1)
	move.w INTENAR(a1),COLOR00(a1)
	move.w INTENAR(a1),COLOR00(a1)
	move.w INTENAR(a1),COLOR00(a1)
	move.w INTENAR(a1),COLOR00(a1)
	move.w INTENAR(a1),COLOR00(a1)
	move.w INTENAR(a1),COLOR00(a1)
	move.w INTENAR(a1),COLOR00(a1)
	move.w INTENAR(a1),COLOR00(a1)
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
	dc.w    INTENA,$7FFF
	dc.w    INTREQ,$7FFF
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

	dc.w    $3139, $FFFE         ; Wait
	dc.w    INTENA,$8800
	dc.w    $31A9, $FFFE         ; Wait
	dc.w    INTENA,$0800
	dc.w    $3239, $FFFE         ; Wait
	dc.w    INTENA,$8800
	dc.w    $32A9, $FFFE         ; Wait
	dc.w    INTENA,$0800
	dc.w    $3339, $FFFE         ; Wait
	dc.w    INTENA,$8800
	dc.w    $33A9, $FFFE         ; Wait
	dc.w    INTENA,$0800
	dc.w    $3439, $FFFE         ; Wait
	dc.w    INTENA,$8800
	dc.w    $34A9, $FFFE         ; Wait
	dc.w    INTENA,$0800
	dc.w    $3539, $FFFE         ; Wait
	dc.w    INTENA,$8800
	dc.w    $35A9, $FFFE         ; Wait
	dc.w    INTENA,$0800
	dc.w    $3639, $FFFE         ; Wait
	dc.w    INTENA,$8800
	dc.w    $36A9, $FFFE         ; Wait
	dc.w    INTENA,$0800
	dc.w    $3739, $FFFE         ; Wait
	dc.w    INTENA,$8800
	dc.w    $37A9, $FFFE         ; Wait
	dc.w    INTENA,$0800
	dc.w    $3839, $FFFE         ; Wait
	dc.w    INTENA,$8800
	dc.w    $38A9, $FFFE         ; Wait
	dc.w    INTENA,$0800

	dc.w    $41A9, $FFFE         ; Wait
	dc.w    INTENA,$8080
	dc.w    $4239, $FFFE         ; Wait
	dc.w    INTENA,$0080
	dc.w    $42A9, $FFFE         ; Wait
	dc.w    INTENA,$8080
	dc.w    $4339, $FFFE         ; Wait
	dc.w    INTENA,$0080
	dc.w    $43A9, $FFFE         ; Wait
	dc.w    INTENA,$8080
	dc.w    $4439, $FFFE         ; Wait
	dc.w    INTENA,$0080
	dc.w    $44A9, $FFFE         ; Wait
	dc.w    INTENA,$8080
	dc.w    $4539, $FFFE         ; Wait
	dc.w    INTENA,$0080
	dc.w    $45A9, $FFFE         ; Wait
	dc.w    INTENA,$8080
	dc.w    $4639, $FFFE         ; Wait
	dc.w    INTENA,$0080
	dc.w    $46A9, $FFFE         ; Wait
	dc.w    INTENA,$8080
	dc.w    $4739, $FFFE         ; Wait
	dc.w    INTENA,$0080
	dc.w    $47A9, $FFFE         ; Wait
	dc.w    INTENA,$8080
	dc.w    $4839, $FFFE         ; Wait
	dc.w    INTENA,$0080
	dc.w    $48A9, $FFFE         ; Wait
	dc.w    INTENA,$8080
	dc.w    $4939, $FFFE         ; Wait
	dc.w    INTENA,$0080

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
	