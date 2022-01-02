	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
entry:	
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	;; install copper list and enable DMA
	lea 	CUSTOM,a1
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	
.mainLoop:
	bra.b	.mainLoop

level3InterruptHandler:
	movem.l	d0-a6,-(sp)

.checkVerticalBlank:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_VERTB,d0	
	beq.s	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; clear interrupt bit	

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
	movem.l	(sp)+,d0-a6
	rte

copper:
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPLCON0,(3<<12)|$200 ; 
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"out/image-copper-list.s"

	;
	; Switching from 4 to 3
	;

	dc.w	$2E47,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$3047,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$3249,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$3449,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$364B,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$384B,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$3A4D,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$3C4D,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$3E4F,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$404F,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$4251,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$4451,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$4653,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$4853,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$4A55,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$4C55,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$4E57,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$5057,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$5259,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$5459,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$565B,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$585B,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$5A5D,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$5C5D,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200


	;
	; Switching from 3 to 4
	;

	dc.w	$6847,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$6A47,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$6C49,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$6E49,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$704B,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$724B,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$744D,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$764D,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$784F,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$7A4F,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$7C51,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$7E51,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$8053,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$8253,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$8455,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$8655,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$8857,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$8A57,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$8C59,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$8E59,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$905B,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$925B,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$945D,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$965D,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$985F,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$9A5F,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$9C61,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$9E61,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$A063,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	;
	;
	;

	dc.w	$C263,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$C465,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$C665,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	dc.w	$C867,$FFFE ; WAIT 
	dc.w    BPLCON0,(4<<12)|$200

	dc.w	$CA67,$FFFE ; WAIT 
	dc.w    BPLCON0,(3<<12)|$200

	;dc.w    $5401,$FFFE ; WAIT 
	;dc.w    COLOR00,$F00
	;dc.w    $54C1,$FFFE
	;dc.w    COLOR00,$000

	;dc.w	$5555,$FFFE ; WAIT 
	;dc.w    BPLCON0,(4<<12)|$200

	dc.w	$ffdf,$fffe ; Cross vertical boundary

	dc.l	$fffffffe

bitplanes:
	incbin	"out/image.bin"
	