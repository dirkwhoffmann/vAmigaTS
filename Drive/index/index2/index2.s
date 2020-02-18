	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"

CIAB_PRA            equ $BFD000	
CIAB_PRB            equ $BFD100
CIAB_DDRA           equ $BFD200
CIAB_DDRB           equ $BFD300
CIAB_TALO           equ $BFD400
CIAB_TAHI           equ $BFD500
CIAB_TBLO           equ $BFD600
CIAB_TBHI           equ $BFD700
CIAB_TODLO          equ $BFD800
CIAB_TODMID         equ $BFD900
CIAB_TODHI          equ $BFDA00
CIAB_SDR            equ $BFDC00
CIAB_ICR            equ $BFDD00
CIAB_CRA            equ $BFDE00
CIAB_CRB            equ $BFDF00

LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78
	
entry:	
	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)

	; Disable Copper DMA 
	move.w  #$0080,DMACON(a1)

	; Disable all bitplanes 
	move.w  #$200,BPLCON0(a1)

	; Install interrupt handlers
	lea	    irq6(pc),a2
 	move.l	a2,LVL6_INT_VECTOR

	; Install copper list
	lea    	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable Copper DMA
	move.w  #(DMAF_SETCLR!DMAF_COPPER),DMACON(a1)

	; Configure CIAs
	move.b #$90,CIAB_ICR  ; Enable FLAG pin interrupt
	move.b #$FF,CIAB_TALO
	move.b #$10,CIAB_TAHI
	move.b #$01,CIAB_CRA  ; Start timer A in continous mode

	; Enable CIAB interrupts
	move.w  #$E000,INTENA(a1)

	; Turn df0 drive motor on
	move.b  #$FF,CIAB_PRB
	move.b  #$77,CIAB_PRB

	; Deselect df0
	move.b  #$7F,CIAB_PRB

.mainLoop:
	bra.b	.mainLoop

irq6:
	move.w  #$FF0,COLOR00(a1) 
	movem.l	d0-a6,-(sp)
	move.b  CIAB_ICR,d0         ; Acknowledge the IRQ by reading ICR
	move.w	#$2000,INTREQ(a1)   ; Acknowledge 
	movem.l	(sp)+,d0-a6
	move.w  #$00F,COLOR00(a1)   
	rte

copper:	

	; dc.w    COLOR00,$0F0
	dc.l	$fffffffe

	