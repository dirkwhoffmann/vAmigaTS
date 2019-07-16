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
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"out/image-copper-list.s"

	dc.w	BPLCON0,(0<<12)|$200 ; set number of enabled bitplanes

	; First mask combination
	dc.w	$2541,$FFFE  ; WAIT 

	dc.w	$7FFF,$8F3E  ; WAIT 
	dc.w    COLOR00, $FF0
	dc.w	$7FFF,$8F3E  ; WAIT 
	dc.w    COLOR00, $00F

	dc.w	$7FFF,$8F3E  ; WAIT 
	dc.w    COLOR00, $FF0
	dc.w	$7FFF,$8F3E  ; WAIT 
	dc.w    COLOR00, $00F

	dc.w	$7FFF,$8F3E  ; WAIT 
	dc.w    COLOR00, $FF0
	dc.w	$7FFF,$8F3E  ; WAIT 
	dc.w    COLOR00, $00F

	dc.w	$7FFF,$8F3E  ; WAIT 
	dc.w    COLOR00, $FF0
	dc.w	$7FFF,$8F3E  ; WAIT 
	dc.w    COLOR00, $00F

	; Second mask combination
	dc.w	$5541,$FFFE  ; WAIT 

	dc.w	$7FFF,$8F1E  ; WAIT 
	dc.w    COLOR00, $FF0
	dc.w	$7FFF,$8F1E  ; WAIT 
	dc.w    COLOR00, $00F

	dc.w	$7FFF,$8F1E  ; WAIT 
	dc.w    COLOR00, $FF0
	dc.w	$7FFF,$8F1E  ; WAIT 
	dc.w    COLOR00, $00F

	dc.w	$7FFF,$8F1E  ; WAIT 
	dc.w    COLOR00, $FF0
	dc.w	$7FFF,$8F1E  ; WAIT 
	dc.w    COLOR00, $00F

	dc.w	$7FFF,$8F1E  ; WAIT 
	dc.w    COLOR00, $FF0
	dc.w	$7FFF,$8F1E  ; WAIT 
	dc.w    COLOR00, $00F

	; Third mask combination
	dc.w	$8541,$FFFE  ; WAIT 

	dc.w	$8FFF,$8F0E  ; WAIT 
	dc.w    COLOR00, $FF0
	dc.w	$8FFF,$8F0E  ; WAIT 
	dc.w    COLOR00, $00F

	dc.w	$8FFF,$8F0E  ; WAIT 
	dc.w    COLOR00, $FF0
	dc.w	$8FFF,$8F0E  ; WAIT 
	dc.w    COLOR00, $00F

	dc.w	$8FFF,$8F0E  ; WAIT 
	dc.w    COLOR00, $FF0
	dc.w	$8FFF,$8F0E  ; WAIT 
	dc.w    COLOR00, $00F

	dc.w	$8FFF,$8F0E  ; WAIT 
	dc.w    COLOR00, $FF0
	dc.w	$8FFF,$8F0E  ; WAIT 
	dc.w    COLOR00, $00F

	; Fourth mask combination
	dc.w	$B541,$FFFE  ; WAIT 

	dc.w	$8FFF,$8F07  ; WAIT 
	dc.w    COLOR00, $FF0
	dc.w	$8FFF,$8F07  ; WAIT 
	dc.w    COLOR00, $00F

	dc.w	$8FFF,$8F07  ; WAIT 
	dc.w    COLOR00, $FF0
	dc.w	$8FFF,$8F07  ; WAIT 
	dc.w    COLOR00, $00F

	dc.w	$8FFF,$8F07  ; WAIT 
	dc.w    COLOR00, $FF0
	dc.w	$8FFF,$8F07  ; WAIT 
	dc.w    COLOR00, $00F

	dc.w	$8FFF,$8F07  ; WAIT 
	dc.w    COLOR00, $FF0
	dc.w	$8FFF,$8F07  ; WAIT 
	dc.w    COLOR00, $00F

	; Fifth mask combination
	dc.w	$E541,$FFFE  ; WAIT 

	dc.w	$8FE1,$8FFE  ; WAIT 
	dc.w    COLOR00, $0F0
	dc.w	$8FE1,$8FFE  ; WAIT 
	dc.w    COLOR00, $88F

	dc.w	$0FE1,$8FFE  ; WAIT 
	dc.w    COLOR00, $0F0
	dc.w	$0FE1,$8FFE  ; WAIT 
	dc.w    COLOR00, $88F

	dc.w	$0FDF,$8FFE  ; WAIT 
	dc.w    COLOR00, $0F0
	dc.w	$0FDF,$8FFE  ; WAIT 
	dc.w    COLOR00, $88F

	dc.w	$0FDF,$8FFE  ; WAIT 
	dc.w    COLOR00, $0F0
	dc.w	$0FDF,$8FFE  ; WAIT 
	dc.w    COLOR00, $88F

	;dc.w	$ffdf,$fffe ; Cross vertical boundary

	dc.l	$fffffffe

bitplanes:
	incbin	"out/image.bin"
	