	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
CIAAPRA             equ $BFE001	
CIABPRB             equ $BFD100	
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
entry:	
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	; Install copper list and enable DMA
	lea CUSTOM,a1
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)

	; Enable Copper interrupt
	move.w	#$8010,INTENA(a1)
	
.mainLoop:

	bra.b	.mainLoop

level3InterruptHandler:
	move.w  #$FFF,$DFF180 
	movem.l	d0-a6,-(sp)
	move.w  #$44B,$DFF180 

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

copper:
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPLCON0,(5<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"image-copper-list-cropped.s"

	dc.w    $6141, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
	dc.w 	INTREQ,$8010         ; Trigger Copper interrupt 
	dc.w    COLOR00,$0F0

	dc.w    $6443, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
	dc.w 	INTREQ,$8010         ; Trigger Copper interrupt 
	dc.w    COLOR00,$0F0

	dc.w    $AA45, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
	dc.w 	INTREQ,$8010         ; Trigger Copper interrupt 
	dc.w    COLOR00,$0F0

	dc.w    $AD47, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
	dc.w 	INTREQ,$8010         ; Trigger Copper interrupt 
	dc.w    COLOR00,$0F0

	dc.w    $F349, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
	dc.w 	INTREQ,$8010         ; Trigger Copper interrupt 
	dc.w    COLOR00,$0F0

	dc.w    $F64B, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
	dc.w 	INTREQ,$8010         ; Trigger Copper interrupt 
	dc.w    COLOR00,$0F0

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

bitplanes:
	incbin	"out/image.bin"
	