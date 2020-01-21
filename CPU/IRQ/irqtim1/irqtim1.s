	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
CIAAPRA             equ $BFE001	
CIABPRB             equ $BFD100	
LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
entry:	

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Install interrupt handlers
	lea	level1InterruptHandler(pc),a3
 	move.l	a3,LVL1_INT_VECTOR
	lea	level2InterruptHandler(pc),a3
 	move.l	a3,LVL2_INT_VECTOR
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	lea	level4InterruptHandler(pc),a3
 	move.l	a3,LVL4_INT_VECTOR
	lea	level5InterruptHandler(pc),a3
 	move.l	a3,LVL5_INT_VECTOR
	lea	level6InterruptHandler(pc),a3
 	move.l	a3,LVL6_INT_VECTOR

	; Install copper list
	lea CUSTOM,a1
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_MASTER),dmacon(a1)

	lea     mainLoop(pc),a3	
mainLoop:
	jmp     (a3)          ; 8 cycles

level1InterruptHandler:

	move.w  #$FF0,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	move.w  #$F00,$DFF180

	move.w  #$000,$DFF180
	move.w  #$000,$DFF182
	move.w  #$000,$DFF184

	move.l  #$DFF184,a7   ; Redirect stack pointer to color registers
	                      ; Causes level2InterruptHandler to write PC_HI into DFF180
	move    #$F,SR        ; Restore SR manually  
	bra.s	mainLoop      ; Exit IRQ handler manually

level2InterruptHandler:

	move.w  #$FF0,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	move.w  #$F00,$DFF180

	move.w  #$000,$DFF180
	move.w  #$000,$DFF182
	move.w  #$000,$DFF184

	move.l  #$DFF182,a7   ; Redirect stack pointer to color registers
		                  ; Causes level3InterruptHandler to write PC_LO into DFF180
	move    #$F,SR        ; Restore SR manually  
	bra.s	mainLoop      ; Exit IRQ handler manually

level3InterruptHandler:

	move.w  #$FF0,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	move.w  #$F00,$DFF180

	move.w  #$000,$DFF180
	move.w  #$000,$DFF182
	move.w  #$000,$DFF184

	; move.l  bitplanes(pc),a7   ; Redirect stack pointer to an unused area
	move.l  #$DFF186,a7   ; Redirect stack pointer to color registers
		                  ; Causes level1InterruptHandler to write SR into DFF180
	move    #$F,SR        ; Restore SR manually  
	bra 	mainLoop      ; Exit IRQ handler manually

level4InterruptHandler:

	move.w  #$F0F,$DFF180
	lea     $DFF006,a4
sync:
	andi.w  #$7,(a4)      ; 16 cycles
	bne     sync          ; 10 cycles
	move.w  #$000,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	move.l  #$DFF186,a7   ; Redirect stack pointer to color registers
		                  ; Causes level1InterruptHandler to write SR into DFF180
	move    #$F,SR        ; Restore SR manually  
	bra 	mainLoop      ; Exit IRQ handler manually				  

level5InterruptHandler:

	move.w  #$F00,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge

	move.w  #$000,$DFF180
	move.w  #$000,$DFF182
	move.w  #$000,$DFF184
	move.w  #$000,$DFF186
	rte

level6InterruptHandler:
	move.w  #$F00,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge

	move.w  #$000,$DFF180
	move.w  #$000,$DFF182
	move.w  #$000,$DFF184
	move.w  #$000,$DFF186
	rte

copper:

	dc.w	BPLCON0,(0<<12)|$200 ; Disable all bitplanes and enable COLOR

	dc.w    $3F39, $FFFE         ; WAIT
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

	dc.w	INTENA,$E89C         ; Enable interrupts

	dc.w    $4139, $FFFE         ; Wait
	;dc.w    COLOR00,$0F0
	dc.w 	INTREQ,$8080         ; Level 4 interrupt (Sync CPU)

	dc.w    $4339, $FFFE         ; Wait
	dc.w    COLOR00,$0F0
	dc.w 	INTREQ,$8004         ; Level 1 interrupt

	dc.w    $4539, $FFFE         ; Wait
	dc.w    COLOR00,$0F0
	dc.w 	INTREQ,$8008         ; Level 2 interrupt

	dc.w    $4739, $FFFE         ; Wait
	dc.w    COLOR00,$0F0
	dc.w 	INTREQ,$8010         ; Level 3 interrupt

	;dc.w    $4739, $FFFE         ; Wait
	;dc.w    COLOR00,$00F
	;dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;dc.w    $4939, $FFFE         ; Wait
	;dc.w    COLOR00,$00F
	;dc.w 	INTREQ,$8800         ; Level 5 interrupt

	;dc.w    $4B39, $FFFE         ; Wait
	;dc.w    COLOR00,$00F
	;dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.w	INTENA,$3FFF         ; Disable interrupts

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
	