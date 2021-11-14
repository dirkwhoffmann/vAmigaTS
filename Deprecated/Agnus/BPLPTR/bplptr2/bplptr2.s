	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"
	
LVL3_INT_VECTOR		equ $6c
IMAGE_WIDTH      	equ (320/8)
IMAGE_DEPTH      	equ 5
	
MAIN:	
	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Install interrupt handler
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	
	; Setup bitplane pointers
	lea     bitplanes(pc),a4
	lea     copper(pc),a2
	moveq	#IMAGE_DEPTH-1,d0
.bitplaneloop:
	move.l 	a4,d1
	move.w	d1,2(a2)
	swap	d1
	move.w  d1,6(a2)
	addq	#8,a2
	lea	    IMAGE_WIDTH(a4),a4 ; Bit plane data is interleaved
	dbra	d0,.bitplaneloop

	lea     bitplanes(pc),a4
	move.l 	a4,d1
	move.l  a4,d2
	swap	d2
	lea     bpl1a(pc),a2
	move.w	d1,2(a2)
	move.w  d2,6(a2)
	lea     bpl1b(pc),a2
	move.w	d1,2(a2)
	move.w  d2,6(a2)
	lea     bpl1c(pc),a2
	move.w	d1,2(a2)
	move.w  d2,6(a2)
	lea     bpl2a(pc),a2
	move.w	d1,2(a2)
	move.w  d2,6(a2)
	lea     bpl2b(pc),a2
	move.w	d1,2(a2)
	move.w  d2,6(a2)
	lea     bpl2c(pc),a2
	move.w	d1,2(a2)
	move.w  d2,6(a2)
	lea     bpl3a(pc),a2
	move.w	d1,2(a2)
	move.w  d2,6(a2)
	lea     bpl3b(pc),a2
	move.w	d1,2(a2)
	move.w  d2,6(a2)
	lea     bpl3c(pc),a2
	move.w	d1,2(a2)
	move.w  d2,6(a2)

	; Install copper list
	lea    	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d2

	; Enable DMA
	move.w  #$8080,DMACON(a1)   ; Copper
	move.w  #$8100,DMACON(a1)   ; Bitplane
	move.w  #$8200,DMACON(a1)   ; EN

	; Enable innterrupts
	move.w	#$8020,INTENA(a1)   ; VBLANK
	move.w	#$C000,INTENA(a1)   ; EN

.mainLoop:
	bra.b	.mainLoop

level3InterruptHandler:

	movem.l	d0-a6,-(sp)
	lea 	CUSTOM,a1
	move.w	#$3FFF,INTREQ(a1)	; Acknowledge
	movem.l	(sp)+,d0-a6
	rte

copper:
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0

	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPL1MOD,IMAGE_WIDTH*IMAGE_DEPTH-IMAGE_WIDTH
	dc.w	BPL2MOD,IMAGE_WIDTH*IMAGE_DEPTH-IMAGE_WIDTH
 
 	dc.w    DDFSTRT,$0030
	dc.w	DDFSTOP,$00C8

 	include	"../image-colors.s"

	dc.w	BPLCON0,(4<<12)|$200 

	dc.w    $60BF,$FFFE
bpl1a:
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0

	dc.w    $64C1,$FFFE
bpl2a:
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0

	dc.w    $68C3,$FFFE
bpl3a:
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0

	dc.w    $6CC5,$FFFE
bpl1b:
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0

	dc.w    $70C7,$FFFE
bpl2b:
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0

	dc.w    $74C9,$FFFE
bpl3b:
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0

	dc.w    $78CB,$FFFE
bpl1c:
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0

	dc.w    $7CCD,$FFFE
bpl2c:
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0

	dc.w    $80CF,$FFFE
bpl3c:
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0

	dc.w	$FFDF,$FFFE  ; Cross vertical boundary

	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off

	dc.l	$fffffffe

bitplanes:
	incbin	"../image.bin"
