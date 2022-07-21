INSTRUCTION	MACRO
        	move.l	(a4),(a5)+
            ENDM

	include "../../../../include/registers.i"
	include "../../../include/ministartup.i"

PRIVILEGE_VECTOR 	equ $20
LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78

COPCOL				equ $FFF

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
	lea priv(pc),a3
	move.l	a3,PRIVILEGE_VECTOR

	; Install interrupt handlers
	lea	irq1(pc),a3
 	move.l	a3,LVL1_INT_VECTOR
	lea	irq2(pc),a3
 	move.l	a3,vectable1+LVL1_INT_VECTOR
	lea	irq3(pc),a3
 	move.l	a3,vectable2+LVL1_INT_VECTOR
	lea	irq4(pc),a3
 	move.l	a3,vectable3+LVL1_INT_VECTOR
	lea	irq5(pc),a3
 	move.l	a3,vectable4+LVL1_INT_VECTOR
	lea	irq6(pc),a3
 	move.l	a3,vectable5+LVL1_INT_VECTOR
	
	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 
	
	moveq   #0,d4
	move.w  #$44F,d5			; Color used in 68000 mode
	move.w	SR,d0			 	; Trigger a privilege exception in 68010 mode
error:
	move.w  #$F00,COLOR00(a1)
	bra.s	error
	
mainLoop:
	bra.s	mainLoop

priv:
	; Enable Interrupts
	move.w 	#$8004,INTENA(a1)   ; Level 1
	move.w 	#$C000,INTENA(a1)   ; INTEN

	jmp 	mainLoop

irq1:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$000,COLOR00(a1)
	lea 	vectable1,a3
	move.l  a3,d4
	movec	d4,VBR
	rte

irq2:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$303,COLOR00(a1)
	lea 	vectable2,a3
	move.l  a3,d4
	movec	d4,VBR
	rte

irq3:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$606,COLOR00(a1)
	lea 	vectable3,a3
	move.l  a3,d4
	movec	d4,VBR
	rte

irq4:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$909,COLOR00(a1)
	lea 	vectable4,a3
	move.l  a3,d4
	movec	d4,VBR
	rte

irq5:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$C0C,COLOR00(a1)
	lea 	vectable5,a3
	move.l  a3,d4
	movec	d4,VBR
	rte

irq6:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$F0F,COLOR00(a1)
	moveq   #0,d4
	movec	d4,VBR
	rte

copper:
	dc.w	BPLCON0,(0<<12)|$200 

	dc.w    $01D9, $FFFE         ; Wait
	dc.w 	INTREQ,$8004         ; Level 1 interrupt

	dc.w    $81D9, $FFFE         ; Wait
	dc.w 	INTREQ,$8004         ; Level 1 interrupt

	dc.w    $91D9, $FFFE         ; Wait
	dc.w 	INTREQ,$8004         ; Level 1 interrupt

	dc.w    $A1D9, $FFFE         ; Wait
	dc.w 	INTREQ,$8004         ; Level 1 interrupt

	dc.w    $B1D9, $FFFE         ; Wait
	dc.w 	INTREQ,$8004         ; Level 1 interrupt

	dc.w    $C1D9, $FFFE         ; Wait
	dc.w 	INTREQ,$8004         ; Level 1 interrupt

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.l	$fffffffe

	align	10
	
vectable1: 
	ds.b 1024,0
vectable2: 
	ds.b 1024,0
vectable3: 
	ds.b 1024,0
vectable4: 
	ds.b 1024,0
vectable5: 
	ds.b 1024,0
