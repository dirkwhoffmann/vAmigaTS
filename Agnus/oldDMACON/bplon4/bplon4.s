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
	; move.w  #$8200,DMACON(a1)   ; Enable DMA

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
	dc.w    BPLCON1,$AA
	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPLCON0,(IMAGE_DEPTH<<12)|$200 
	dc.w	BPL1MOD,IMAGE_WIDTH*IMAGE_DEPTH-IMAGE_WIDTH
	dc.w	BPL2MOD,IMAGE_WIDTH*IMAGE_DEPTH-IMAGE_WIDTH
 
 	include	"../image-colors.s"

	dc.w    DPL1DATA,0
	dc.w    DPL2DATA,0
	dc.w    DPL3DATA,0
	dc.w    DPL4DATA,0
	dc.w    DPL5DATA,0
	dc.w    DPL6DATA,0

    ; Only enable 4 bitplanes to prevent the Copper being stopped by bitplane DMA
	dc.w	BPLCON0,(4<<12)|$200

	dc.w	$3001,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$3101,$FFFE
	dc.w    DMACON,$8100      ; DMA on (at beginning of the line!!)
	dc.w	COLOR00, $000
	dc.w	$3801,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$3901,$FFFE
	dc.w    DMACON,$0100      ; DMA off  
	dc.w	COLOR00, $000

	dc.w	$5001,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$5161,$FFFE
	dc.w    DMACON,$8100      ; DMA on  
	dc.w	COLOR00, $000
	dc.w	$5801,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$5901,$FFFE
	dc.w    DMACON,$0100      ; DMA off  
	dc.w	COLOR00, $000

	dc.w	$6001,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$6163,$FFFE
	dc.w    DMACON,$8100      ; DMA on  
	dc.w	COLOR00, $000
	dc.w	$6801,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$6901,$FFFE
	dc.w    DMACON,$0100      ; DMA off  
	dc.w	COLOR00, $000

	dc.w	$7001,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$7165,$FFFE
	dc.w    DMACON,$8100      ; DMA on  
	dc.w	COLOR00, $000
	dc.w	$7801,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$7901,$FFFE
	dc.w    DMACON,$0100      ; DMA off  
	dc.w	COLOR00, $000

	dc.w	$8001,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$8167,$FFFE
	dc.w    DMACON,$8100      ; DMA on  
	dc.w	COLOR00, $000
	dc.w	$8801,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$8901,$FFFE
	dc.w    DMACON,$0100      ; DMA off  
	dc.w	COLOR00, $000

	dc.w	$9001,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$9169,$FFFE
	dc.w    DMACON,$8100      ; DMA on  
	dc.w	COLOR00, $000
	dc.w	$9801,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$9901,$FFFE
	dc.w    DMACON,$0100      ; DMA off  
	dc.w	COLOR00, $000

	dc.w	$A001,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$A16B,$FFFE
	dc.w    DMACON,$8100      ; DMA on  
	dc.w	COLOR00, $000
	dc.w	$A801,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$A901,$FFFE
	dc.w    DMACON,$0100      ; DMA off  
	dc.w	COLOR00, $000

	dc.w	$B001,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$B16D,$FFFE
	dc.w    DMACON,$8100      ; DMA on  
	dc.w	COLOR00, $000
	dc.w	$B801,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$B901,$FFFE
	dc.w    DMACON,$0100      ; DMA off  
	dc.w	COLOR00, $000

	dc.w	$C001,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$C16F,$FFFE
	dc.w    DMACON,$8100      ; DMA on  
	dc.w	COLOR00, $000
	dc.w	$C801,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$C901,$FFFE
	dc.w    DMACON,$0100      ; DMA off  
	dc.w	COLOR00, $000

	dc.w	$D001,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$D171,$FFFE
	dc.w    DMACON,$8100      ; DMA on  
	dc.w	COLOR00, $000
	dc.w	$D801,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$D901,$FFFE
	dc.w    DMACON,$0100      ; DMA off  
	dc.w	COLOR00, $000

	dc.w	$E001,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$E173,$FFFE
	dc.w    DMACON,$8100      ; DMA on  
	dc.w	COLOR00, $000
	dc.w	$E801,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$E901,$FFFE
	dc.w    DMACON,$0100      ; DMA off  
	dc.w	COLOR00, $000

	dc.w    $ffdf,$fffe ; Cross vertical boundary

	dc.w	$2001,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$2101,$FFFE
	dc.w    DMACON,$8100      ; DMA on  
	dc.w	COLOR00, $000
	dc.w	$2801,$FFFE     
	dc.w	COLOR00, $F00
	dc.w	$2901,$FFFE       ; We purposely switch off at the beginning of the line here!!!
	dc.w    DMACON,$0100      ; DMA off  
	dc.w	COLOR00, $000
	
	dc.l	$fffffffe

bitplanes:
	incbin	"../image.bin"
	