	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"
	
LVL3_INT_VECTOR		equ $6c 
IMAGE_WIDTH      	equ (320/8)
IMAGE_DEPTH      	equ 5

MAIN:	

	; Load OCS base address
	lea CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Install interrupt handlers
	lea	    irq3(pc),a2
 	move.l	a2,LVL3_INT_VECTOR

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

irq3:
	move.w  #$0020,INTREQ(a1)   ; Acknowledge
	move.w  #$8200,DMACON(a1)   ; Enable DMA

.bitplanePointers:
	lea	    bitplanes(pc),a4
	lea     BPL1PTH(a1),a2
	moveq	#IMAGE_DEPTH-1,d0
.bitplaneloop:
	move.l	a4,(a2)
	lea	    IMAGE_WIDTH(a4),a4 ; Bit plane data is interleaved
	addq	#4,a2
	dbra	d0,.bitplaneloop

	rte

copper:
	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPLCON0,(IMAGE_DEPTH<<12)|$200 
	dc.w	BPL1MOD,IMAGE_WIDTH*IMAGE_DEPTH-IMAGE_WIDTH
	dc.w	BPL2MOD,IMAGE_WIDTH*IMAGE_DEPTH-IMAGE_WIDTH
 
 	include	"../image-colors.s"

    ; Only enable 4 bitplanes to prevent the Copper being stopped by bitplane DMA
	dc.w	BPLCON0,(4<<12)|$200

    ; First color block
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
 
	; Second color block
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

	; Third color block
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

; Fourth color block
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
	incbin	"../image.bin"
	