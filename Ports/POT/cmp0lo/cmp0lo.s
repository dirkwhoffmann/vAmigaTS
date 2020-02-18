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
	move.w  VHPOSR(a1),d0
	sub.w   #$800,d0
	move.w  POT0DAT(a1),d1
	lsl.w   #$8,d1              ; Shift lo byte to the right
	and.w   #$FF00,d0
	and.w   #$FF00,d1
	cmp.w   d0,d1
	beq     .equal  
	move.w  #$F00,COLOR00(a1)
	bra.b   .mainLoop 
.equal:
	move.w  #$0F0,COLOR00(a1)
	bra.b	.mainLoop

irq3:
	move.w  #$0020,INTREQ(a1)   ; Acknowledge	
	move.w  #$1,POTGO(a1)       ; Restart measurement
	rte

	