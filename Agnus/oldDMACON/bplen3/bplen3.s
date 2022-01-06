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
	dc.w    DDFSTRT,$0028 
	dc.w	DDFSTOP,$00C0
	dc.w    DMACON,$0100
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$311B,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$3801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$38D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$391D,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$4001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$40D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$411F,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$4921,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$5001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$50D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$5123,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$5801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$58D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$5925,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$60D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$6127,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	; Second color block
	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$0030 
	dc.w	DDFSTOP,$00C8
	dc.w    DMACON,$0100
	dc.w	$78D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$7923,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$8001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$80D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$8125,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$8801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$88D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$8927,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$9001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$90D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$9129,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$9801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$98D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$992B,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$A001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$A0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$A12D,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$A801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$A8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$A92F,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$B001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$B0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$B131,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	; Third color block
	dc.w	$D001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w    DMACON,$0100
	dc.w	$D0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$D12B,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$D801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$D8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$D92D,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$E001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$E0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$E12F,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$E801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$E8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$E931,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$F001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$F0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$F133,$FFFE  ; WAIT 
	dc.w    DMACON,$8100

	dc.w	$F801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DMACON,$0100
	dc.w	$F8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$F935,$FFFE  ; WAIT 
	dc.w    DMACON,$8100
	
	dc.w    $ffdf,$fffe ; Cross vertical boundary

; Fourth color block: Set DIWSTRT too late

	;dc.w    DDFSTRT,$0038 ; Reset normal values
	;dc.w	DDFSTOP,$00D0

	dc.l	$fffffffe

bitplanes:
	incbin	"../image.bin"
	