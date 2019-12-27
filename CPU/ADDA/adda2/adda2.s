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
	; move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_MASTER),dmacon(a1)
	
.mainLoop:
	; ds.w 500,$4E71 ; NOP field
	bra.s	.mainLoop

level1InterruptHandler:

	move.w  #$F00,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	suba.l  A0,A0          ; Setup
	move.w  #$FF0,$DFF180
	ds.w 28,$4E71 ; NOP (4 cycles each)
	move.w  #$000,$DFF180
	rte

level2InterruptHandler:

	move.w  #$F00,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	suba.l  A0,A0          ; Setup
	move.w  #$FF0,$DFF180
	ds.w 36,$4E71 ; NOP (4 cycles each)
	move.w  #$000,$DFF180
	rte

level3InterruptHandler:

	move.w  #$F00,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	suba.l  A0,A0          ; Setup
	move.w  #$FF0,$DFF180
	adda.w  -(A0),A1 ; 1
	adda.w  -(A0),A1 ; 2
	adda.w  -(A0),A1 ; 3
	adda.w  -(A0),A1 ; 4
	adda.w  -(A0),A1 ; 5
	adda.w  -(A0),A1 ; 6
	adda.w  -(A0),A1 ; 7
	adda.w  -(A0),A1 ; 8
	move.w  #$000,$DFF180
	rte

level4InterruptHandler:

	move.w  #$F00,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	suba.l  A0,A0          ; Setup
	move.w  #$FF0,$DFF180
	adda.w  2(A0),A1 ; 1
	adda.w  2(A0),A1 ; 2
	adda.w  2(A0),A1 ; 3
	adda.w  2(A0),A1 ; 4
	adda.w  2(A0),A1 ; 5
	adda.w  2(A0),A1 ; 6
	adda.w  2(A0),A1 ; 7
	adda.w  2(A0),A1 ; 8
	move.w #$000,$DFF180
	rte

level5InterruptHandler:

	move.w  #$F00,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	suba.l  A0,A0          ; Setup
	move.w  #$FF0,$DFF180
	adda.w  2(A0,A1),A2 ; 1
	adda.w  2(A0,A1),A2 ; 2
	adda.w  2(A0,A1),A2 ; 3
	adda.w  2(A0,A1),A2 ; 4
	adda.w  2(A0,A1),A2 ; 5
	adda.w  2(A0,A1),A2 ; 6
	adda.w  2(A0,A1),A2 ; 7
	adda.w  2(A0,A1),A2 ; 8
	move.w  #$000,$DFF180
	rte

level6InterruptHandler:
	move.w  #$F00,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	suba.l  A0,A0          ; Setup
	move.w  #$FF0,$DFF180
	adda.w  $FE,A0 ; 1
	adda.w  $FE,A0 ; 2
	adda.w  $FE,A0 ; 3
	adda.w  $FE,A0 ; 4
	adda.w  $FE,A0 ; 5
	adda.w  $FE,A0 ; 6
	adda.w  $FE,A0 ; 7
	adda.w  $FE,A0 ; 8
	move.w  #$000,$DFF180
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
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt

	dc.w    $4339, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt

	dc.w    $4539, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt

	dc.w    $4739, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $4939, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$8800         ; Level 5 interrupt

	dc.w    $4B39, $FFFE         ; Wait
	dc.w    COLOR00,$00F
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.w	INTENA,$3FFF         ; Disable interrupts

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
	