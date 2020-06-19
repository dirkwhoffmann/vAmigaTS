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
	;  2: a1 := start of divisors
	;  3: for d1 := 0 .. 15 { // rows 
	;  4:   d4 := a1[d1] // payload
	;  5:   for d2 := 0 .. 7 { // rows
	;  6:     a3 := start of dividends
	;  7:     for d3 := 0 .. 3 { // cols
	;  8:       d5 := a3[d3]
	;  9:       d5 := d5 / d4
	; 10:       *a0++ = d5 // write result and select next divisor
	; 11:     }
	; 12:   a0 += offset // select next dividend
	; 13:   }
	; 14: } 

	lea (bitplanes+360)(pc),a0 ; (1) 
	lea divisors(pc),a1        ; (2)
	moveq #15,d1               ; (3)
.loopd1:
	move.w (a1)+,d4            ; (4)
	moveq #7,d2                ; (5)
.loopd2:
	lea dividends(pc),a3       ; (6)
	moveq #3,d3                ; (7)
.loopd3:
    move.l (a3)+,d5            ; (8)
	divu d4,d5                 ; (9)  The actual test
	move.l d5,(a0)+            ; (10)
    dbra d3,.loopd3            ; (11)
	lea (24,a0),a0             ; (12)
	dbra d2,.loopd2            ; (13)
	lea (40,a0),a0             ; Blank line
	dbra d1,.loopd1            ; (14)    

    ; Second test
	; lea bitplanes+380,a0 ; (1)
      
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

divisors:
	dc.w    $ffff ; 0
	dc.w    $8fff ; 1
	dc.w    $8888 ; 2
	dc.w    $8000 ; 3
	dc.w    $4fff ; 4
	dc.w    $4000 ; 5
	dc.w    $1001 ; 6
	dc.w    $1000 ; 7 
	dc.w    $0fff ; 8
	dc.w    $0800 ; 9
	dc.w    $0100 ; 10
	dc.w    $00ff ; 11
	dc.w    $0080 ; 12
	dc.w    $0010 ; 13
	dc.w    $0002 ; 14
	dc.w    $0001 ; 15

dividends:
	dc.l    $ffffffff ; 0
	dc.l    $80000000 ; 1
	dc.l    $0000ffff ; 2
	dc.l    $00008000 ; 3

bitplanes:
	ds.b 61440,$00
	
