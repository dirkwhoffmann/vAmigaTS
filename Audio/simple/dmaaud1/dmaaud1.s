	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
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

entry:
	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)

	; Disable Copper DMA 
	move.w #$0080,DMACON(a1)

	; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Configure CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A
	move.b  #$84,$BFED01  ; CIA A

	; Install interrupt handlers
	lea	irq2(pc),a2
 	move.l	a2,LVL2_INT_VECTOR
	lea	irq4(pc),a2
 	move.l	a2,LVL4_INT_VECTOR

	; Enable audio and CIAA interrupts
	move.w	#$C788,INTENA(a1) 

	; Initial IRQ4 acknowledge mask
	move.w  #$0080,d4
;
; Main program
;

main: 

	; Set a timer (to turn off audio later)
	move.b  #$80,CIAA_CRB        ; Write alarm
	move.b  #$00,CIAA_TODHI
	move.b  #$00,CIAA_TODMID
	move.b  #100,CIAA_TODLO

	move.b  #$00,CIAA_CRB        ;Write tod
	move.b  #$00,CIAA_TODHI
	move.b  #$00,CIAA_TODMID
	move.b  #$00,CIAA_TODLO

	; Configure channel 0
	move.l #channel0,AUD0LCH(a1)
	move.w #(channel0end-channel0)/2,AUD0LEN(a1)
	move.w #32,AUD0VOL(a1)
	move.w #1016,AUD0PER(a1)
	move.w #$8201,DMACON(a1)   ; Enable DMA for channel 0

.loop:
	bra .loop

irq2:
	move.w  #$F00,COLOR00(a1)   
	move.b  CIAA_ICR,d0        ; Clear CIAA::ICR
	move.w  #$0008,INTREQ(a1)  ; Acknowledge	
	move.w  #$0001,DMACON(a1)  ; Disable DMA for channel 0
	clr     d4                 ; irq4 handler will no longer acknowledge the IRQ
	rte

irq4:
	btst    #7,(INTREQR+1)(a1)
	beq     .irq4_channel1

	move.w  #$FF0,COLOR00(a1)                
	move.w  d4,INTREQ(a1)     ; Acknowledge
    bra     .exit

.irq4_channel1
	move.w  #$00F,COLOR00(a1)	                
	move.w  #$0100,INTREQ(a1) ; Acknowledge

.exit:               
	move.w  #$000,COLOR00(a1)	 
	rte


channel0: ; Sine wave
	dc.b    0,49
	dc.b    90,117
	dc.b    127,117
	dc.b    90,49
	dc.b    0,-49
	dc.b    -90,-117
	dc.b    -127,-117
	dc.b    -90,-49
channel0end:
