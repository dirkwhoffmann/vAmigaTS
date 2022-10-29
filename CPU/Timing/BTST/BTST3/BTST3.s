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

	move.l  #$000F000F,d4
	move.l  #$00F000F0,d5
	moveq   #0,d6
	lea     $DFF180,a4
	lea     $DFF170,a5

.mainLoop:
	bra.s	.mainLoop

color0:
	dc.w   $FF0
	dc.w   $FF0
color1:
	dc.w   $4F4
	dc.w   $4F4

irq1:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	btst    #$5,$DFF180
	move.w  #$FFF,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	rte

irq2:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	btst    #$5,$DFF181
	move.w  #$FFF,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	rte

irq4:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	btst    #$5,$DFF180
	btst    #$5,$DFF181
	move.w  #$FFF,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	rte

irq5:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	nop
	btst    #$5,$DFF181
	move.w  #$FFF,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	rte

irq6:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	nop
	nop
	btst    #$5,$DFF181
	move.w  #$FFF,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	rte

irq3:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge

synccpu:
	lea     VHPOSR(a1),a3     ; VHPOSR     

	; Wait until we have reached the middle of a frame
.loop 
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$3000,d2
	bne     .loop
	and     #1,VPOSR(a1)
	bne     .loop

	; Sync horizontally
	move.w  #$F0F,COLOR00(a1)
.synccpu1:
	andi.w  #$F,(a3)          ; 16 cycles
	bne     .synccpu1         ; 10 cycles
	move.w  #$606,COLOR00(a1)
.synccpu2:
	andi.w  #$1F,(a3)         ; 16 cycles
	bne     .synccpu2         ; 10 cycles
	move.w  #$A0A,COLOR00(a1)
.synccpu3:
	andi.w  #$FF,(a3)         ; 16 cycles
	nop                       ;  4 cycles
	nop                       ;  4 cycles
	nop                       ;  4 cycles
	bne     .synccpu3         ; 10 cycles (if taken)

	; Adust horizontally
  	moveq #10,d2
.adjust:
    dbra d2,.adjust

	; Sync vertically
.synccpu4:
	nop 
	move.w  #$404,COLOR00(a1)
	ds.w    96,$4E71          ; NOPs to keep the horizontal position in each iteration
	move.w  (a3),d2     
	move.w  #$F0F,COLOR00(a1)  
	and     #$FF00,d2
	cmp.w   #$4000,d2
	bne     .synccpu4
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
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $5339, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $5539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $5739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $5939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $6001, $FFFE         ; Wait
	dc.w	BPLCON0,(1<<12)|$200 

	dc.w    $6139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $6339, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $6539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $6739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $6939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$A000         ; Level 6 interrupt
	
	dc.w    $7001, $FFFE         ; Wait
	dc.w	BPLCON0,(2<<12)|$200 

	dc.w    $7139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $7339, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $7539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $7739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $7939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $8001, $FFFE         ; Wait
	dc.w	BPLCON0,(3<<12)|$200 

	dc.w    $8139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $8339, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $8539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $8739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $8939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $9001, $FFFE         ; Wait
	dc.w	BPLCON0,(4<<12)|$200 

	dc.w    $9139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $9339, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $9539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $9739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $9939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$A000         ; Level 6 interrupt
	
	dc.w    $A001, $FFFE         ; Wait
	dc.w	BPLCON0,(5<<12)|$200 

	dc.w    $A139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $A339, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $A539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $A739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $A939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $B001, $FFFE         ; Wait
	dc.w	BPLCON0,(6<<12)|$200 

	dc.w    $B139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $B339, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $B539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $B739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $B939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
	