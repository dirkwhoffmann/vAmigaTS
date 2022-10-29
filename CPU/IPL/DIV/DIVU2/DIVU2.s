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
	lea     CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Install exception handlers
	lea	    irq1(pc),a3
 	move.l	a3,LVL1_INT_VECTOR
	lea	    irq2(pc),a3
 	move.l	a3,LVL2_INT_VECTOR
	lea	    irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	lea	    irq4(pc),a3
 	move.l	a3,LVL4_INT_VECTOR
	lea	    irq5(pc),a3
 	move.l	a3,LVL5_INT_VECTOR
	lea	    irq6(pc),a3
 	move.l	a3,LVL6_INT_VECTOR
	
	lea     srcval,a4
	move.w  #4,(a4)
	lea     spare1,a4
	move.w  #4,(a4)

	; Install copper list
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 

	; Enable Interrupts
	move.w 	#$8004,INTENA(a1)   ; Level 1
	move.w 	#$8008,INTENA(a1)   ; Level 2
	move.w 	#$8010,INTENA(a1)   ; Level 3
	move.w 	#$8080,INTENA(a1)   ; Level 4
	move.w 	#$8800,INTENA(a1)   ; Level 5
	move.w 	#$A000,INTENA(a1)   ; Level 6
	move.w 	#$C000,INTENA(a1)   ; INTEN

mainloop: 
	jsr     synccpu
	lea     spare1,a4
	lea     spare1,a5
	moveq   #42,d4
	moveq   #24,d5
   	move.w  #8000,d3
loop1:
	dbra    d3,loop1
   	move.w  #300,d3
	move.w  #$888,d4
	move.w  #$000,d5
loop2:
	move.w  d4,COLOR00(a1)
	move.w  d5,COLOR00(a1)
    dbra    d3,loop2
	bra.s   mainloop

srcval: 
	dc.w   0

color0:
	dc.w    $FF0
	dc.w    $FF0
color1:
	dc.w    $4F4
	dc.w    $4F4

irq1:
	move.w  #$0F0,COLOR00(a1)
	divu    d4,d5
	move.w  #$FF0,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	moveq   #42,d4
	move.w  #128,(a4)
	rte

irq2:
	move.w  #$0F0,COLOR00(a1)
	divu    (a4),d4
	move.w  #$FF0,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	moveq   #42,d4
	move.w  #128,(a4)
	rte

irq3:
	move.w  #$0F0,COLOR00(a1)
	divu    (a4)+,d4
	move.w  #$FF0,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	moveq   #42,d4
	move.w  #128,(a4)
	rte

irq4:
	move.w  #$0F0,COLOR00(a1)
	divu    -(a4),d4
	move.w  #$FF0,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	moveq   #42,d4
	move.w  #128,(a4)
	rte

irq5:
	move.w  #$0F0,COLOR00(a1)
	divu    srcval,d4
	move.w  #$FF0,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	moveq   #42,d4
	moveq   #24,d5
	move.w  #128,(a4)
	rte

irq6:
	move.w  #$F00,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$000,COLOR00(a1)
	rte 

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
  	moveq   #10,d2
.adjust:
    dbra    d2,.adjust

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
	rts
	
copper:
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

	; Test section 1
	dc.w    $5139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $51A1, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt
	
	dc.w    $5339, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $53A1, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $5539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $55A1, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $5739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $57A1, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $5939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $59A1, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	; Test section 2
	dc.w    $6001, $FFFE         ; Wait

	dc.w    $6139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $61A3, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $6339, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $63A3, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $6539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $65A3, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $6739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $67A3, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $6939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $69A3, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	; Test section 3
	dc.w    $7001, $FFFE         ; Wait

	dc.w    $7139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $71A5, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $7339, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $73A5, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $7539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $75A5, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $7739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $77A5, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $7939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $79A5, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	; Test section 4
	dc.w    $8001, $FFFE         ; Wait

	dc.w    $8139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $81A7, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $8339, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $83A7, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $8539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $85A7, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $8739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $87A7, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $8939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $89A7, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	; Test section 5
	dc.w    $9001, $FFFE         ; Wait

	dc.w    $9139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $91A9, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $9339, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $93A9, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $9539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $95A9, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $9739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $97A9, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $9939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $99A9, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	; Test section 6
	dc.w    $A001, $FFFE         ; Wait

	dc.w    $A139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $A1AB, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $A339, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $A3AB, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $A539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $A5AB, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $A739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $A7AB, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $A939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $A9AB, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	; Test section 7
	dc.w    $B001, $FFFE         ; Wait

	dc.w    $B139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $B1AD, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $B339, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $B3AD, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $B539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $B5AD, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $B739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $B7AD, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $B939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $B9AD, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	; Test section 8
	dc.w    $C001, $FFFE         ; Wait

	dc.w    $C139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $C1AF, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $C339, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $C3AF, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $C539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $C5AF, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $C739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $C7AF, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $C939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $C9AF, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	; Test section 9
	dc.w    $D001, $FFFE         ; Wait

	dc.w    $D139, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $D1B1, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $D339, $FFFE         ; Wait
	dc.w    COLOR00,$00F	
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $D3B1, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $D539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $D5B1, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $D739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $D7B1, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w    $D939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt
	dc.w    $D9B1, $FFFE         ; Wait
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.l	$fffffffe


	ds.b 128,$00
spare:	
	ds.b 128,$00
spare1:
	ds.b 128,$00