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
	moveq   #$00,D0        ; Setup
	move.w  #$FF0,$DFF180
	ds.w 16,$4E71 ; NOP (4 cycles each)
	move.w  #$000,$DFF180
	rte

level2InterruptHandler:

	move.w  #$F00,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	moveq   #$00,D0        ; Setup
	move.w  #$FF0,$DFF180
	ds.w 28,$4E71 ; NOP (4 cycles each)
	move.w  #$000,$DFF180
	rte

level3InterruptHandler:

	move.w  #$F00,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	moveq   #$00,D0        ; Setup
	move.w  #$FF0,$DFF180
	add.b   (A0),D0 ; 1
	add.b   (A0),D0 ; 2
	add.b   (A0),D0 ; 3
	add.b   (A0),D0 ; 4
	add.b   (A0),D0 ; 5
	add.b   (A0),D0 ; 6
	add.b   (A0),D0 ; 7
	add.b   (A0),D0 ; 8
	move.w  #$000,$DFF180
	rte

level4InterruptHandler:

	move.w  #$F00,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	moveq   #$10,D0        ; Setup
	move.w  #$FF0,$DFF180
	dc.w $9090 ; Same as sub.l (A0), D0
	dc.w $9090 ; 2
	dc.w $9090 ; 3
	dc.w $9090 ; 4
	dc.w $9090 ; 5
	dc.w $9090 ; 6
	dc.w $9090 ; 7
	dc.w $9090 ; 8
	move.w #$000,$DFF180
	rte

level5InterruptHandler:

	move.w  #$F00,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	moveq   #$00,D0        ; Setup
	move.w  #$FF0,$DFF180
	add.w   (A0),D0 ; 1
	add.w   (A0),D0 ; 2
	add.w   (A0),D0 ; 3
	add.w   (A0),D0 ; 4
	add.w   (A0),D0 ; 5
	add.w   (A0),D0 ; 6
	add.w   (A0),D0 ; 7
	add.w   (A0),D0 ; 8
	move.w  #$000,$DFF180
	rte

level6InterruptHandler:
	move.w  #$F00,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	moveq   #$10,D0        ; Setup
	move.w  #$FF0,$DFF180
	add.l   (A0),D0 ; 1
	add.l   (A0),D0 ; 2
	add.l   (A0),D0 ; 3
	add.l   (A0),D0 ; 4
	add.l   (A0),D0 ; 5
	add.l   (A0),D0 ; 6
	add.l   (A0),D0 ; 7
	add.l   (A0),D0 ; 8
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
	