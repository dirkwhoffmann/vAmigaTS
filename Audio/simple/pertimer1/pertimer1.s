	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR	    equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78

CIAA_PRA            equ $BFE001	
CIAA_PRB            equ $BFE101
CIAA_DDRA           equ $BFE201
CIAA_DDRB           equ $BFE301
CIAA_TALO           equ $BFE401
CIAA_TAHI           equ $BFE501
CIAA_TBLO           equ $BFE601
CIAA_TBHI           equ $BFE701
CIAA_TODLO          equ $BFE801
CIAA_TODMID         equ $BFE901
CIAA_TODHI          equ $BFEA01
CIAA_SDR            equ $BFEC01
CIAA_ICR            equ $BFED01
CIAA_CRA            equ $BFEE01
CIAA_CRB            equ $BFEF01

MAIN:
	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)

	; Disable all DMA
	move.w  #$7FFF,DMACON(a1)

	; Install interrupt handlers
	;lea	irq4(pc),a2
 	;move.l	a2,LVL4_INT_VECTOR

	; Install Copper list
	;lea	copper(pc),a0
	;move.l	a0,COP1LC(a1)
	;move.w  COPJMP1(a1),d0

	; Enable Copper DMA
	;move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_MASTER),DMACON(a1)

	; Enable audio and CIAA interrupts
	; move.w	#$C788,INTENA(a1) 

;
; Main program
;

	move.w #$0080,INTREQ(a1) ; Clear aud0 irq
	
	move.w #2220,AUD0PER(a1) ; Timer value

	move.w #$8201,DMACON(a1) ; Aud0 DMA on
	move.w #$0201,DMACON(a1) ; Aud0 DMA off

	move.w #300,d0
.l0:
	dbra   d0,.l0

	move.w #$8200,DMACON(a1) ; DMA enable

	; move.w #$0000,AUD0DAT(a1)

	move.w #$000,d2
	move.w #$F0F,d1

.l1:	
	move.w INTREQR(a1),d0
	btst   #7,d0             ; Aud0 IRQ?
	beq.s  .l2
	move.w #$0080,INTREQ(a1) ; Clear bit
	exg    d1,d2             ; Swap background color values
.l2:	
	move.w d2,COLOR00(a1)  
	btst   #6,$bfe001
	bne.s  .l1

	move.w #$c000,INTENA(a1) 
	rts

.loop:
	bra .loop

irq4:
	btst    #7,(INTREQR+1)(a1)
	beq     .irq4_channel1

	move.w  #$FF0,COLOR00(a1)                
    bra     .exit

.irq4_channel1
	move.w  #$00F,COLOR00(a1)	                
	move.w  #$0100,INTREQ(a1) ; Acknowledge

.exit:               
	move.w  #$000,COLOR00(a1)	 
	rte

;
; Copper
;

	copper:

	dc.w    $60A1,$FFFE       ; Wait
	dc.w    COLOR00,$0F0
	dc.w 	DMACON,$8001      ; Audio DMA on

	dc.w    $61A1,$FFFE     ; Wait
	dc.w 	DMACON,$0001      ; Audio DMA off

	dc.w	$ffdf,$fffe       ; Cross vertical boundary
	dc.l	$fffffffe

;
; Data
; 

channel0: ; Sine wave
	dc.b    127,-127
	dc.b    127,-127
channel0end:
