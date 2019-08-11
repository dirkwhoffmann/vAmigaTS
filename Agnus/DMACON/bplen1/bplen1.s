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

.enableDMA:
	move.w  #$8200,DMACON(a5)

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
	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"out/image-copper-list.s"


    ; Set number of bitplanes to 4, so Copper cannot be blocked by bitplane DMA.
	dc.w	BPLCON0,(4<<12)|$200

    ; First color block (toggle on and off at the beginning of a DMA line)
	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$3101,$FFFE  ; WAIT 
	dc.w    DMACON,$0100
	dc.w	$31D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$3801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$3901,$FFFE  ; WAIT 
	dc.w    DMACON,$8100
	dc.w	$39D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$4103,$FFFE  ; WAIT 
	dc.w    DMACON,$0100
	dc.w	$41D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$4903,$FFFE  ; WAIT 
	dc.w    DMACON,$8100
	dc.w	$49D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$5001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$5105,$FFFE  ; WAIT 
	dc.w    DMACON,$0100 
	dc.w	$51D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$5801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$5905,$FFFE  ; WAIT 
	dc.w    DMACON,$8100 
	dc.w	$59D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
 
	; Second color block (toggle on and off in the middle of a DMA line)
	dc.w    $7001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $7081,$FFFE  ; WAIT 
  	dc.w    DMACON,$8100
    dc.w    $7081,$FFFE  ; WAIT (2nd wait at same position as seen in "The Pawn")
  	dc.w    DMACON,$0100
    dc.w    $70D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $7801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $7881,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
    dc.w    $78D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $8001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $8085,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
    dc.w    $8085,$FFFE  ; WAIT (2nd wait at same position as seen in "The Pawn")
  	dc.w    DMACON,$0100
    dc.w    $80D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $8801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $8885,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
    dc.w    $88D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $9001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $9087,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
    dc.w    $90D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $9801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $9887,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
    dc.w    $98D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $A001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $A089,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
    dc.w    $A0D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

 	dc.w    $B001,$FFFE  ; WAIT
  	dc.w    DMACON,$8100

	; Third color block (toggle on and off at the end of a DMA line)
	dc.w    $B801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $B9E1,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $BA01,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $C001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $C1E1,$FFFE  ; WAIT
	dc.w    DMACON,$8100
	dc.w    $C201,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $C801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $C9E1,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $CA01,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $D001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $D1E1,$FFFE  ; WAIT
	dc.w    DMACON,$8100
	dc.w    $D201,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $D801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $D9E1,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $DA01,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $E001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $E1E1,$FFFE  ; WAIT
	dc.w    DMACON,$8100
	dc.w    $E201,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	;dc.w    $E801,$FFFE  ; WAIT
	;dc.w	COLOR00, $F00
	;dc.w    $E8D9,$FFFE  ; WAIT
	;dc.w	COLOR00, $000

	dc.w    $ffdf,$fffe ; Cross vertical boundary

; Fourth color block (toggle on and off multiple times in a rasterline, switch DMA off gliobally)
	dc.w    $0001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $0081,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
	dc.w    $0083,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $0085,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
	dc.w    $0087,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $0089,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $0801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $0881,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
	dc.w    $0885,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $0889,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
	dc.w    $088D,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $0891,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $1001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $1081,$FFFE  ; WAIT
	dc.w    $1081,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
	dc.w    $1091,$FFFE  ; WAIT
	dc.w    $1091,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $10A1,$FFFE  ; WAIT
	dc.w    $10A1,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
	dc.w    $10B1,$FFFE  ; WAIT
	dc.w    $10B1,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $10D9,$FFFE  ; WAIT
	dc.w    $10D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $1801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $1881,$FFFE  ; WAIT
	dc.w    $1881,$FFFE  ; WAIT
	dc.w    $1881,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
	dc.w    $1891,$FFFE  ; WAIT
	dc.w    $1891,$FFFE  ; WAIT
	dc.w    $1891,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $18A1,$FFFE  ; WAIT
	dc.w    $18A1,$FFFE  ; WAIT
	dc.w    $18A1,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
	dc.w    $18B1,$FFFE  ; WAIT
	dc.w    $18B1,$FFFE  ; WAIT
	dc.w    $18B1,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $18D9,$FFFE  ; WAIT
	dc.w    $18D9,$FFFE  ; WAIT
	dc.w    $18D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $2001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $2081,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
	dc.w    $2091,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $20A1,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
	dc.w    $20B1,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $20D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $2001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $2081,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
	dc.w    $2081,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $2081,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
	dc.w    $2081,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $2081,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.l	$fffffffe

bitplanes:
	incbin	"out/image.bin"
	