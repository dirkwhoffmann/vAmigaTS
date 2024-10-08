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
	dc.w	$3051,$FFFE  ; WAIT 
	dc.w    DMACON,$0100
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$3801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$3861,$FFFE  ; WAIT 
	dc.w    DMACON,$8100
	dc.w	$38D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$4071,$FFFE  ; WAIT 
	dc.w    DMACON,$0100
	dc.w	$40D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$4881,$FFFE  ; WAIT 
	dc.w    DMACON,$8100
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$5001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$5091,$FFFE  ; WAIT 
	dc.w    DMACON,$0100 
	dc.w	$50D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$5101,$FFFE  ; WAIT 

	dc.w	$5801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$58A1,$FFFE  ; WAIT 
	dc.w    DMACON,$8100 
	dc.w	$58D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; Second color block
	dc.w    $7001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $7081,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
    dc.w    $7081,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
    dc.w    $70D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $7801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $7883,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
    dc.w    $78D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $8001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $8085,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
    dc.w    $8085,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
    dc.w    $80D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $8801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $8887,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
    dc.w    $88D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $9001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $9089,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
    dc.w    $9089,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
    dc.w    $90D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $9801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $988B,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
    dc.w    $98D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $A001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
    dc.w    $A08D,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
    dc.w    $A08D,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
    dc.w    $A0D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	; Third color block
	dc.w    $B801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $B8D9,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
	dc.w	COLOR00, $000

	dc.w    $C001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $C081,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
	dc.w    $C091,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $C0A1,$FFFE  ; WAIT
  	dc.w    DMACON,$8100
	dc.w    $C0B1,$FFFE  ; WAIT
  	dc.w    DMACON,$0100
	dc.w    $C0D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $C801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $C8D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $D001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $D0D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $D801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $D8D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $E001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $E0D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $E801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $E8D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $ffdf,$fffe ; Cross vertical boundary

; Fourth color block: Set DIWSTRT too late
	dc.w    $0001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $0085,$FFFE  ; WAIT
	dc.w    DMACON,$8100 
	dc.w    $00D7,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $0801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $0887,$FFFE  ; WAIT
 	;dc.w    DMACON,$0300 
	dc.w    $08D5,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $1001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $1089,$FFFE  ; WAIT
 	dc.w    DMACON,$8300 
	dc.w    $10D3,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $1801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $188B,$FFFE  ; WAIT
 	dc.w    DMACON,$8200 
	dc.w    $18D1,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $2001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $208D,$FFFE  ; WAIT
 	dc.w    DMACON,$0200 ; DMA off (from here on, we see a blank (red) screen)
	dc.w    $20CF,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	dc.w    $2801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $288F,$FFFE  ; WAIT
 	dc.w    DMACON,$8200 
	dc.w    $28CD,$FFFE  ; WAIT
	dc.w	COLOR00, $000

	;dc.w    DDFSTRT,$0038 ; Reset normal values
	;dc.w	DDFSTOP,$00D0

	dc.l	$fffffffe
	
bitplanes:
	incbin	"../image.bin"
	