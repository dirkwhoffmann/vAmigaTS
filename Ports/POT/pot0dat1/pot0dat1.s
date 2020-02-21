	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"

LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR	    equ $68
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
	lea	    irq3(pc),a2
 	move.l	a2,LVL3_INT_VECTOR

	; Enable innterrupts
	move.w	#$C020,INTENA(a1) 

.mainLoop:
	move.w  POT0DAT(a1),COLOR00(a1)
	bra.b   .mainLoop 

irq3:
	move.w  #$0020,INTREQ(a1)   ; Acknowledge
	
	; Clear potentiometer counters
	move.w  #$0001,POTGO(a1)
	rte

	