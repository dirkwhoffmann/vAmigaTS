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
	lea	level2InterruptHandler(pc),a3
 	move.l	a3,LVL2_INT_VECTOR
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	;; install copper list and enable DMA
	lea CUSTOM,a1
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	
.mainLoop:
	bra.b	.mainLoop

level2InterruptHandler:
	movem.l	d0-a6,-(sp)

.checkLv2:
	lea	CUSTOM,a5

	; Change the background color to visualize where we are
	move.w  #$F00,COLOR00(a5) 
		
	; In this test, we try to acknowledge the interrupt only by clearing the corresponding IRQ bit in
	; the CIA's ICR register. The test shows that this is not enough. The interrupt retriggers 
	; immediately, thus producing white and red stripes on the screen. 

	; Acknowledge the IRQ by reading the CIA ICR reg
	move.b  $BFED01,d0 

    ; Acknowledge the IRQ by clearing the IRQ bit in INTREQ
	move.w	#$8,INTREQ(a5)

	; Change the background color again
	move.w  #$FFF,COLOR00(a5) 
	
.lv2InterruptComplete:
	movem.l	(sp)+,d0-a6
	rte


level3InterruptHandler:
	movem.l	d0-a6,-(sp)

.checkVerticalBlank:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_VERTB,d0	
	beq.w	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; Clear interrupt bit	
	move.w  #$0F0,COLOR00(a5)       ; Clear background color
	move.w	#$2000,INTENA(a5)       ; Disable CIA B interrupts
	move.w  #$8008,INTENA(a5)       ; Enable CIA A interrupts

	;; Perform a timer test
	lea $bfe001,a0                  ; CIA A base address 
	move.b #$12,$700(a0)            ; TBHI 
	move.b #$00,$600(a0)            ; TBLO   
	move.b #$82,$C00(a0)            ; Enable CIA timer interrupt
	move.b #$09,$F00(a0)            ; CRB (Start timer in one shot mode)

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
	move.w  #$123,COLOR00(a5)
	move.w	INTREQR(a5),d0
	and.w	#INTF_COPER,d0	
	beq.s	.interruptComplete
.copperInterrupt:
	move.w  #$456,COLOR00(a5)
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
 
 	include	"image-copper-list-cropped.s"

	dc.w	$ffdf,$fffe ; Cross vertical boundary
	dc.l	$fffffffe

bitplanes:
	incbin	"out/image.bin"
	