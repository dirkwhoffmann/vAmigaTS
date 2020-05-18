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
	
;
; Main
;

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
	move.b  #$FF,CIAB_DDRA      ; Configure PA pins as outputs
	move.b  #$82,CIAB_ICR       ; Enable timer B interrupts, ony
	move.w  #$E000,INTENA(a1)

;
; Main loop
;

main: 
	jsr     synccpu

	move.b  #$00,CIAB_CRA       ; Stop and set timer A
	move.b  #$80,CIAB_TALO
	move.b  #$00,CIAB_TAHI 

	move.b  #$00,CIAB_CRB       ; Stop and set timer B
	move.b  #$04,CIAB_TBLO
	move.b  #$00,CIAB_TBHI 

	move.b  #$21,CIAB_CRA       ; Start timer A in "CNT pin" couting mode (continous)
	move.b  #$49,CIAB_CRB       ; Start timer B in "underflow A" counting mode (one shot)

   	move.w  #$1FF,d3
.loop1:
	move.b  CIAB_TBLO,(COLOR00+1)(a1)
	move.b  #$00,CIAB_PRA       ; Generate CNT pulses
	move.b  #$FF,CIAB_PRA
	move.w  #$000,COLOR00(a1) 
	dbra    d3,.loop1

	bra.s   main

;
; IRQ handlers
;

irq6:
	;move.w  #$880,COLOR00(a1) 
	movem.l	d0-a6,-(sp)
	move.b  CIAB_ICR,d0         ; Acknowledge the IRQ by reading ICR
	move.w	#$2000,INTREQ(a1)   ; Acknowledge 
	nop
	nop
	nop
	nop
	movem.l	(sp)+,d0-a6
	rte

synccpu:
	lea     VHPOSR(a1),a3       ; VHPOSR     

	; Wait until we have reached the top of a frame
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
	rts

copper:
	; dc.w    COLOR00,$0F0	
	dc.w	$ffdf,$fffe          ; Cross vertical boundary
	dc.l	$fffffffe
