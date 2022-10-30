	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
CIAAPRA             equ $BFE001	
CIABPRB             equ $BFD100	
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
entry:	
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	lea	level4InterruptHandler(pc),a3
 	move.l	a3,LVL4_INT_VECTOR
	lea	level5InterruptHandler(pc),a3
 	move.l	a3,LVL5_INT_VECTOR

	; Install copper list and enable DMA
	lea CUSTOM,a1
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	
	; move.w	#$8090,INTENA(a1) ; Enable Copper and Audio interrupts
	
.mainLoop:

	bra.b	.mainLoop

level3InterruptHandler:
	move.w  #$00F,$DFF180 
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
	move.w  #$FFF,$DFF180
	movem.l	(sp)+,d0-a6
	move.w  #$234,$DFF180
	rte

level4InterruptHandler:
	move.w  #$FF0,$DFF180 
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.w  #$555,$DFF180 
	rte

level5InterruptHandler:
	move.w  #$F00,$DFF180 
	move.w  #$0F0,$DFF180 
	move.w  #$00F,$DFF180 
	rte

copper:
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPLCON0,(1<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"image-copper-list-cropped.s"

	dc.w    $6141, $FFFE         ; WAIT
	dc.w	INTENA,$8880         ; Enable interrupts
	dc.w 	INTREQ,$8080         ; Trigger a level 4 interrupt to let the CPU process NOP's
	dc.w    $6141, $FFFE         ; WAIT
	dc.w    $6141, $FFFE         ; WAIT
	dc.w    $6141, $FFFE         ; WAIT
	dc.w    $6141, $FFFE         ; WAIT
	dc.w 	INTREQ,$8800         ; Trigger a level 5 interrupt
	dc.w 	INTENA,$0800         ; Disable level 5 interrupts

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.w	INTENA,$0880         ; Disable Copper and Audio interrupts
	dc.w 	INTREQ,$0880         ; 
	dc.w    COLOR00,$000

bitplanes:
	incbin	"out/image.bin"
	