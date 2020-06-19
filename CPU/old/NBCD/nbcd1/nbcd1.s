	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 1
	
entry:	
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	;; install copper list and enable DMA
	lea 	CUSTOM,a1
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	
.mainLoop:

    ;  1: a0 := start position in bitplane area
	;  2: for d1 := 0 .. 15 { // rows 
	;  3:   for d2 := 0 .. 8 { // rows
	;  4:     for d3 := 0 .. 15 { // cols
	;  5:       d0 := d1 << 4 | d3 // payload
	;  6:       <do something with d0>
	;  7:       *a0++ = d0
	;  8:     }
	;  9:   a0 += offset // goto next line
	; 10:   }
	; 11: } 

	lea bitplanes+360,a0 ; (1)
	moveq #15,d1         ; (2)
.loopd1:
	moveq #7,d2          ; (3)
.loopd2:
	moveq #15,d3         ; (4)
.loopd3:
    move.b d1,d0
	lsl #4,d0
	or.b   d3,d0         ; (5)

	move #0,CCR          ; (6)      
	nbcd d0             

    move.b d0,(a0)+      ; (7)
    dbra d3,.loopd3      ; (8)
	lea (24,a0),a0       ; (9)
	dbra d2,.loopd2      ; (10)
	dbra d1,.loopd1      ; (11)    

    ; Second test
	lea bitplanes+380,a0 ; (1)
	moveq #15,d1         ; (2)
.loopd1b:
	moveq #7,d2          ; (3)
.loopd2b:
	moveq #15,d3         ; (4)
.loopd3b:
    move.b d1,d0
	lsl #4,d0
	or.b   d3,d0         ; (5)

	move #$FF,CCR        ; (6)      
	nbcd d0             

    move.b d0,(a0)+      ; (7)
    dbra d3,.loopd3b     ; (8)
	lea (24,a0),a0       ; (9)
	dbra d2,.loopd2b     ; (10)
	dbra d1,.loopd1b     ; (11)    


	bra.b	.mainLoop

level3InterruptHandler:
	movem.l	d0-a6,-(sp)

.checkVerticalBlank:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_VERTB,d0	
	beq.s	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; clear interrupt bit	

.resetBitplanePointers:
	lea	    bitplanes(pc),a1
	move.l	a1,BPL1PTH(a5)
	
.checkCopper:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_COPER,d0	
	beq.s	.interruptComplete
.copperInterrupt:
	move.w	#INTF_COPER,INTREQ(a5)	; clear interrupt bit	
	
.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte

copper:
	dc.w    DDFSTRT,$0038 
	dc.w	DDFSTOP,$00D0
	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPLCON0,(1<<12)|$200 
	dc.w	BPL1MOD,0
	dc.w	BPL2MOD,0
	dc.w    COLOR00,$000
	dc.w    COLOR01,$FF0

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
	