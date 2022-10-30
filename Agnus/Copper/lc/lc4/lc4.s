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
	
MAIN:	
	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable interrupts and DMA
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)

	; Disable all bitplanes 
	move.w  #$200,BPLCON0(a1)

	; Install interrupt handlers
	lea	    irq3(pc),a2
 	move.l	a2,LVL3_INT_VECTOR

	; Install Copper list
	lea    	copper1(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable Copper DMA
	move.w  #$8280,DMACON(a1)

	; Enable innterrupts
	move.w	#$C020,INTENA(a1) 

.mainLoop:
	lea     VHPOSR(a1),a3 
.loop1                           
	move.w  (a3),d2             ; Wait for rasterline
	and     #$FF00,d2
	cmp.w   #$7000,d2
	bne     .loop1
	and     #1,VPOSR(a1)
	bne     .loop1

	move.w  #$0080,DMACON(a1)   
	lea    	copper2(pc),a0      ; Redirect to list 2
	move.l	a0,COP1LC(a1)
	move.w  #$8080,DMACON(a1) 

.loop2                          ; Wait for a rasterline
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$E000,d2
	bne     .loop2
	and     #1,VPOSR(a1)
	bne     .loop2

	move.w  #$0080,DMACON(a1)   
	lea    	copper3(pc),a0      ; Try to redirect a second time (which fails)
	move.l	a0,COP1LC(a1)
	move.w  #$8080,DMACON(a1)  

.loop3                          ; Wait for a rasterline
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$F000,d2
	bne     .loop3
	and     #1,VPOSR(a1)
	bne     .loop3

	move.w  #$0080,DMACON(a1)   ; Copper DMA off
	lea    	copper1(pc),a0
	move.l	a0,COP1LC(a1)

	bra.b	.mainLoop
	
irq3:
	move.w  #$0020,INTREQ(a1)   ; Acknowledge

	movem.l	d0-a6,-(sp)
	move.w  #$000,COLOR00(a1)
	movem.l	(sp)+,d0-a6
	rte

;
; Copper list
;

copper1:

	dc.w	COLOR00,$800
	dc.w	$6031,$FFFE
	dc.w	COLOR00,$F00
	dc.w    $FFFF,$FFFE
	
copper2:

	dc.w    COLOR00,$0F0
	dc.w    $FFFF,$FFFE

copper3:

	dc.w    COLOR00,$00F
	dc.w    $FFFF,$FFFE
