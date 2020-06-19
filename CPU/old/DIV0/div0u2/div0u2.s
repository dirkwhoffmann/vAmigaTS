	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
CIAAPRA             equ $BFE001	
CIABPRB             equ $BFD100	
DIV0_VECTOR         equ $14
CHK_VECTOR          equ $18
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
	bra.s	.mainLoop

divHandler1:
	bmi     .Nflag
	move.w  #$00F,$DFF180
	rte
.Nflag:
	move.w  #$FF0,$DFF180
	rte

divHandler2:
	beq     .Zflag
	move.w  #$00F,$DFF180
	rte
.Zflag:
	move.w  #$FF0,$DFF180
	rte

divHandler3:
	bvs     .Vflag
	move.w  #$00F,$DFF180
	rte
.Vflag:
	move.w  #$FF0,$DFF180
	rte

divHandler4:
	bcs     .Cflag
	move.w  #$00F,$DFF180
	rte
.Cflag:
	move.w  #$FF0,$DFF180
	rte

level1InterruptHandler:

	move.w  #$3FFF,$DFF09C ; Acknowledge
	lea	divHandler1(pc),a3
 	move.l	a3,DIV0_VECTOR
	moveq #$0,d0
	and #$00,CCR 
	divu d0,d0 
	ds.w 16,$4E71 ; NOP (4 cycles each)
	move.w  #$000,$DFF180
	rte

level2InterruptHandler:

	move.w  #$3FFF,$DFF09C ; Acknowledge
	lea	divHandler2(pc),a3
 	move.l	a3,DIV0_VECTOR
	moveq #$0,d0
	and #$00,CCR 
	divu d0,d0 
	ds.w 16,$4E71 ; NOP (4 cycles each)
	move.w  #$000,$DFF180
	rte

level3InterruptHandler:

	move.w  #$3FFF,$DFF09C ; Acknowledge
	lea	divHandler3(pc),a3
 	move.l	a3,DIV0_VECTOR
	moveq #$0,d0
	and #$00,CCR 
	divu d0,d0 
	ds.w 16,$4E71 ; NOP (4 cycles each)
	move.w  #$000,$DFF180
	rte

level4InterruptHandler:

	move.w  #$3FFF,$DFF09C ; Acknowledge
	lea	divHandler4(pc),a3
 	move.l	a3,DIV0_VECTOR
	moveq #$0,d0
	and #$00,CCR 
	divu d0,d0 
	ds.w 16,$4E71 ; NOP (4 cycles each)
	move.w  #$000,$DFF180
	rte

level5InterruptHandler:

	move.w  #$3FFF,$DFF09C ; Acknowledge
	
	ds.w 16,$4E71 ; NOP (4 cycles each)
	move.w  #$000,$DFF180
	rte

level6InterruptHandler:

	move.w  #$3FFF,$DFF09C ; Acknowledge
	
	ds.w 16,$4E71 ; NOP (4 cycles each)
	move.w  #$000,$DFF180
	rte

copper:
	;dc.w    DIWSTRT,$2c81
	;dc.w	DIWSTOP,$2cc1
	dc.w	BPLCON0,(0<<12)|$200 ; Disable all bitplanes and enable COLOR
	;dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	;dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES

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
	dc.w    COLOR00,$F00
	dc.w 	INTREQ,$8004         ; Level 1 interrupt

	dc.w    $4339, $FFFE         ; Wait
	dc.w    COLOR00,$F00
	dc.w 	INTREQ,$8008         ; Level 2 interrupt

	dc.w    $4539, $FFFE         ; Wait
	dc.w    COLOR00,$F00
	dc.w 	INTREQ,$8010         ; Level 3 interrupt

	dc.w    $4739, $FFFE         ; Wait
	dc.w    COLOR00,$F00
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $4939, $FFFE         ; Wait
	dc.w    COLOR00,$F00
	dc.w 	INTREQ,$8800         ; Level 5 interrupt

	dc.w    $4B39, $FFFE         ; Wait
	dc.w    COLOR00,$F00
	dc.w 	INTREQ,$A000         ; Level 6 interrupt

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.w	INTENA,$3FFF         ; Disable interrupts

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
	