	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

CHK_EXC_VECTOR		equ $18

LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78

MAIN:

	; Load OCS base address
	lea CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Install exception handlers
	lea	irq2(pc),a3
 	move.l	a3,LVL2_INT_VECTOR
	lea	irq3_1(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	; Setup bitplane pointers
	lea     bitplanes(pc),a2
	lea     copper(pc),a3
	moveq	#5,d0
.bitplaneloop:
	move.l 	a2,d1
	move.w	d1,2(a3)
	swap	d1
	move.w  d1,6(a3)
	addq	#8,a3
	dbra	d0,.bitplaneloop
	
	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Setup the Blitter
	jsr prepareblit

	; Enable Interrupts
	move.w 	#$8008,INTENA(a1)   ; Level 2 (Soft)
	move.w 	#$8020,INTENA(a1)   ; Level 3 (Blitter)
	move.w 	#$C000,INTENA(a1)   ; INTEN

	; Enable DMA
	move.w	#$8040,DMACON(a1)   ; Blitter DMA 	
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 
	move.w	#$8400,DMACON(a1)   ; BlitPri = 1 

	; Enable interrupts
	move.w	#$C044,INTENA(a1)  

	; IRQ3 handlers
	lea	irq3_1(pc),a3
	lea	irq3_2(pc),a4           

.mainLoop:
	bra.s	.mainLoop

blitWait:
	tst DMACONR(a1)		;for compatibility
.waitblit:
	btst #6,DMACONR(a1)
	bne.s .waitblit
	rts

prepareblit:	
	movem.l d0-a6,-(sp)
	bsr blitWait
	move.w #0,BLTCON0(A6)
	move.w #0,BLTCON1(a1) 
	move.l #$ffffffff,BLTAFWM(a1)
	move.w #0,BLTAMOD(a1)
	move.w #0,BLTBMOD(a1)
	move.w #0,BLTCMOD(a1)
	move.w #0,BLTDMOD(a1)
	movem.l (sp)+,d0-a6
	rts

irq2: ; Runs the test program (triggered by the Copper)
	
	move.w  #$FF0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge

 	move.l	a3,LVL3_INT_VECTOR  ; Set IRQ3 handler to irq3_1

	move.w  #$0041,BLTSIZE(a1)  ; Start Blit
	nop
	nop
	nop
	nop
	nop
	
 	move.l	a4,LVL3_INT_VECTOR  ; Redirect IRQ3 handler to irq3_2
	move.w  #$00F,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	rte

irq3_1:
	move.w  #$F00,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$000,COLOR00(a1)
	rte

irq3_2:
	move.w  #$0F0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$000,COLOR00(a1)
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

	dc.w	BPLCON0,(0<<12)|$200 

	dc.w    $4F39, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000

	dc.w    $5001, $FFFE         ; Wait
	dc.w	BPLCON0,(0<<12)|$200 

	dc.w    $5139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $5337, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $5535, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $5733, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $5931, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt

	dc.w    $6001, $FFFE         ; Wait
	dc.w	BPLCON0,(1<<12)|$200 

	dc.w    $6139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $6337, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $6535, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $6733, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $6931, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	
	dc.w    $7001, $FFFE         ; Wait
	dc.w	BPLCON0,(2<<12)|$200 

	dc.w    $7139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $7337, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $7535, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $7733, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $7931, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt

	dc.w    $8001, $FFFE         ; Wait
	dc.w	BPLCON0,(3<<12)|$200 

	dc.w    $8139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $8337, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $8535, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $8733, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $8931, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt

	dc.w    $9001, $FFFE         ; Wait
	dc.w	BPLCON0,(4<<12)|$200 

	dc.w    $9139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $9337, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $9535, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $9733, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $9931, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	
	dc.w    $A001, $FFFE         ; Wait
	dc.w	BPLCON0,(5<<12)|$200 

	dc.w    $A139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $A337, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $A535, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $A733, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $A931, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt

	dc.w    $B001, $FFFE         ; Wait
	dc.w	BPLCON0,(6<<12)|$200 

	dc.w    $B139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $B337, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $B535, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $B733, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $B931, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
	