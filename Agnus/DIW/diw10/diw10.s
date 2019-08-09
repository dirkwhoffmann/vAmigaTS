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
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"out/image-copper-list.s"

	; In this block, we switch to unmatchable coordinates which means that the H flop does 
	; not change any more. Before we reach here, the H flop did not toggle either, because  
	; unmatchable coordinates have been set at the end of the Copper list. 
	; Because the H flop is set at the beginning of a frame (this is the hypothesis we want to 
	; prove with this test), the H flop was on all the time. Hence, we see the screen before 
	; and after the following WAIT statement.
	
	dc.w	$8001,$FFFE    ; WAIT 
	dc.w    DIWSTRT,$2801  ; Unmatchable H coordinate
	dc.w    DIWSTOP,$30FF  ; Unmatchable H coordinate

	dc.w    $A001,$FFFE    ; WAIT
	dc.w    DIWSTRT,$28A0  ; Matchable coordinate
	dc.w    DIWSTOP,$30A0  ; Matchable coordinate 

    ; When we reach the following WAIT statement, the H flop is off. Because we switch
	; to unmatchable coordinates, the flop stays off all the time and the screen gets blank.
	
	dc.w    $C101,$FFFE    ; WAIT
	dc.w    DIWSTRT,$2801  ; Unmatchable H coordinate 
	dc.w    DIWSTOP,$30FF  ; Unmatchable H coordinate
	
	dc.l	$fffffffe

bitplanes:
	incbin	"out/image.bin"
	