	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

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

	; Install interrupt handlers
	lea	irq1(pc),a3
 	move.l	a3,LVL1_INT_VECTOR
	lea	irq2(pc),a3
 	move.l	a3,LVL2_INT_VECTOR
	lea	irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	lea	irq4(pc),a3
 	move.l	a3,LVL4_INT_VECTOR
	lea	irq5(pc),a3
 	move.l	a3,LVL5_INT_VECTOR
	lea	irq6(pc),a3
 	move.l	a3,LVL6_INT_VECTOR
	
	; Setup bitplane data
	lea bitplanes(pc),a0 
	move.w #51201,d0
.loop:
	move.b #$AA,(a0)+
	dbra d0,.loop

	; Setup colors
	move.w #$000,COLOR00(a1)
	move.w #$FF0,COLOR01(a1)

	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 

	; Enable Interrupts
	move.w 	#$8004,INTENA(a1)   ; Level 1
	move.w 	#$8008,INTENA(a1)   ; Level 2
	move.w 	#$8020,INTENA(a1)   ; Level 3 (VERTB)
	move.w 	#$8080,INTENA(a1)   ; Level 4
	move.w 	#$8800,INTENA(a1)   ; Level 5
	move.w 	#$A000,INTENA(a1)   ; Level 6
	move.w 	#$C000,INTENA(a1)   ; INTEN
	
	lea     $DFF170,a4
	lea     $DFF180,a5
	moveq   #5,d4

.mainLoop:
	bra.b	.mainLoop

irq1:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.l  #$0F000FF0,(a5)
	move.l  #$0,$DFF180
	rte

irq2:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.l  #$0F000FF0,(a5)+
	move.l  #$0,$DFF180
	rte

irq4:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.l  #$0F000FF0,-(a5)
	move.l  #$0,$DFF180
	rte

irq5:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.l  #$0F000FF0,$10(a4)
	move.l  #$0,$DFF180
	rte

irq6:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.l  #$0F000FF0,$5(a4,d4)
	move.l  #$0,$DFF180
	rte

irq3:
	movem.l	d0-a6,-(sp)
	lea 	CUSTOM,a1
	move.w	#$3FFF,INTREQ(a1)	; Acknowledge
	lea     bitplanes(pc),a2
	lea     BPL1PTH(a1),a3
	move.l	a2,(a3)
	movem.l	(sp)+,d0-a6
	rte

copper:
	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPL1MOD,0
	dc.w	BPL2MOD,0
 
    ; 
	; Block 1 (LORES)
	;

	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	BPLCON0,(1<<12)|$200 ; 1 bitplanes, lores mode
	;dc.w    COLOR01,$66F
	dc.w    COLOR00,$000
	dc.w    COLOR01,$000
	
	dc.w    $5139, $FFFE         ; Wait
	dc.w    COLOR00,$000	
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $5339, $FFFE         ; Wait
	dc.w    COLOR00,$000	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $5539, $FFFE         ; Wait
	dc.w    COLOR00,$000
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $5739, $FFFE         ; Wait
	dc.w    COLOR00,$000
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $5939, $FFFE         ; Wait
	dc.w    COLOR00,$000
	dc.w 	INTREQ,$A000         ; Level 6 interrupt


	dc.w	$FFDF,$FFFE  ; Cross vertical boundary

	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off
	dc.w    DDFSTRT,$0038 ; Reset normal values
	dc.w	DDFSTOP,$00D0

	dc.l	$fffffffe

bitplanes:
	ds.b    51201
	