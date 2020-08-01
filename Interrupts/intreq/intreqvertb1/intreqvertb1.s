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
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 6
	
MAIN:	

	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Disable DMA
	move.w  #$7FFF,DMACON(a1)

	; Install interrupt handlers
	lea	irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	; move.w  #$8080,DMACON(a1)  ; Copper DMA
	; move.w  #$8100,DMACON(a1)  ; Bitplane DMA
	; move.w  #$8200,DMACON(a1)  ; DMA enable

	; Enable interrupts
	move.w  #$C020,INTENA(a1)

;
; Main loop
;
.mainLoop: 
    move.w  #$F00,COLOR00(a1)
.check:
    btst    #5,$DFF01F
    beq     .check
	move.w  #$0F0,COLOR00(a1)
	bra.s   .check

;
; IRQ handlers
;

irq3:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	rte

;
; Copper
;

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

	dc.l	$fffffffe
