	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

BPL5DAT             equ $118
BPL6DAT             equ $11A

TESTMODE            equ $0C00    ; Test combination for the HAM and DPF bits

MAIN:	
	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

    ; Setup bitplane data
	lea     bitplane1,a0
	move.w  #4000,d0
.l1: move.w  #$FFFF,(a0)+
	move.w  #$0000,(a0)+
	dbra    d0,.l1

	lea     bitplane2,a0
	move.w  #4000,d0
.l2: move.w  #$FFFF,(a0)+
	move.w  #$0000,(a0)+
	dbra    d0,.l2

	lea     bitplane3,a0
	move.w  #4000,d0
.l3: move.w  #$FFFF,(a0)+
	move.w  #$0000,(a0)+
	dbra    d0,.l3

	lea     bitplane4,a0
	move.w  #4000,d0
.l4: move.w  #$FFFF,(a0)+
	move.w  #$0000,(a0)+
	dbra    d0,.l4

	lea     bitplane5,a0
	move.w  #8000,d0
.l5: move.w  #$0000,(a0)+
	dbra    d0,.l5

	lea     bitplane6,a0
	move.w  #8000,d0
.l6: move.w  #$0000,(a0)+
	dbra    d0,.l6

 	; Setup bitplane pointers
	lea     copper(pc),a2
	lea     bitplane1,a3
	move.l 	a3,d3
	move.w	d3,2(a2)
	swap	d3
	move.w  d3,6(a2)
	lea     bitplane2,a3
	move.l 	a3,d3
	move.w	d3,10(a2)
	swap	d3
	move.w  d3,14(a2)
	lea     bitplane3,a3
	move.l 	a3,d3
	move.w	d3,18(a2)
	swap	d3
	move.w  d3,22(a2)
	lea     bitplane4,a3
	move.l 	a3,d3
	move.w	d3,26(a2)
	swap	d3
	move.w  d3,30(a2)
	lea     bitplane5,a3
	move.l 	a3,d3
	move.w	d3,34(a2)
	swap	d3
	move.w  d3,38(a2)
	lea     bitplane6,a3
	move.l 	a3,d3
	move.w	d3,42(a2)
	swap	d3
	move.w  d3,46(a2)

	; Install Copper list and enable DMA
	lea 	CUSTOM,a1
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 

.mainLoop:
	bra.b	.mainLoop


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
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0

	dc.w    COLOR00,$000
	dc.w    COLOR01,$FFF
	dc.w    COLOR02,$FFF
	dc.w    COLOR03,$FFF
	dc.w    COLOR04,$FFF
	dc.w    COLOR05,$FFF
	dc.w    COLOR06,$FFF
	dc.w    COLOR07,$FFF
	dc.w    COLOR08,$FFF
	dc.w    COLOR09,$FFF
	dc.w    COLOR10,$FFF
	dc.w    COLOR11,$FFF
	dc.w    COLOR12,$FFF
	dc.w    COLOR13,$FFF
	dc.w    COLOR14,$FFF
	dc.w    COLOR15,$FFF
	dc.w    COLOR16,$FFF
	dc.w    COLOR17,$FFF
	dc.w    COLOR18,$FFF
	dc.w    COLOR19,$FFF
	dc.w    COLOR20,$FFF
	dc.w    COLOR21,$FFF
	dc.w    COLOR22,$FFF
	dc.w    COLOR23,$FFF
	dc.w    COLOR24,$FFF
	dc.w    COLOR25,$FFF
	dc.w    COLOR27,$FFF
	dc.w    COLOR28,$FFF
	dc.w    COLOR29,$FFF
	dc.w    COLOR30,$FFF
	dc.w    COLOR31,$FFF

	dc.w    DDFSTRT,$0068
	dc.w	DDFSTOP,$00A0
	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPL1MOD,$0
	dc.w	BPL2MOD,$0

    ; Block 0 (0 bitplanes)
	dc.w    $3001,$FFFE ; Wait
	dc.w	BPLCON0,$0200|TESTMODE
	dc.w    BPL5DAT,$0000
	dc.w    BPL6DAT,$0000
	dc.w    $3875,$FFFE ; Wait
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    $3A75,$FFFE ; Wait
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF

	; Block 1 (1 bitplane)
	dc.w    $4001,$FFFE ; Wait
	dc.w	BPLCON0,$1200|TESTMODE
	dc.w    BPL5DAT,$0000
	dc.w    BPL6DAT,$0000
	dc.w    $4875,$FFFE ; Wait
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    $4A75,$FFFE ; Wait
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF

	; Block 2 (2 bitplanes)
	dc.w    $5001,$FFFE ; Wait
	dc.w	BPLCON0,$2200|TESTMODE
	dc.w    BPL5DAT,$0000
	dc.w    BPL6DAT,$0000
	dc.w    $5875,$FFFE ; Wait
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    $5A75,$FFFE ; Wait
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF

	; Block 3 (3 bitplanes)
	dc.w    $6001,$FFFE ; Wait
	dc.w	BPLCON0,$3200|TESTMODE
	dc.w    BPL5DAT,$0000
	dc.w    BPL6DAT,$0000
	dc.w    $6875,$FFFE ; Wait
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    $6A75,$FFFE ; Wait
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF

	; Block 4 (4 bitplanes)
	dc.w    $7001,$FFFE ; Wait
	dc.w	BPLCON0,$4200|TESTMODE
	dc.w    BPL5DAT,$0000
	dc.w    BPL6DAT,$0000
	dc.w    $7875,$FFFE ; Wait
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    $7A75,$FFFE ; Wait
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF

	; Block 5 (5 bitplanes)
	dc.w    $8001,$FFFE ; Wait
	dc.w	BPLCON0,$5200|TESTMODE
	dc.w    BPL5DAT,$0000
	dc.w    BPL6DAT,$0000
	dc.w    $8875,$FFFE ; Wait
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    $8A75,$FFFE ; Wait
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF

	; Block 6 (6 bitplanes)
	dc.w    $9001,$FFFE ; Wait
	dc.w	BPLCON0,$6200|TESTMODE
	dc.w    BPL5DAT,$0000
	dc.w    BPL6DAT,$0000
	dc.w    $9875,$FFFE ; Wait
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    $9A75,$FFFE ; Wait
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF

	; Block 7 (7 bitplanes)
	dc.w    $A001,$FFFE ; Wait
	dc.w	BPLCON0,$7200|TESTMODE
	dc.w    BPL5DAT,$0000
	dc.w    BPL6DAT,$0000
	dc.w    $A875,$FFFE ; Wait
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    $AA75,$FFFE ; Wait
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF

	; Block 8 (0 bitplanes, hires)
	dc.w    $B001,$FFFE ; Wait
	dc.w	BPLCON0,$8200|TESTMODE
	dc.w    BPL5DAT,$0000
	dc.w    BPL6DAT,$0000
	dc.w    $B875,$FFFE ; Wait
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    $BA75,$FFFE ; Wait
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF

	; Block 9 (1 bitplanes, hires)
	dc.w    $C001,$FFFE ; Wait
	dc.w	BPLCON0,$9200|TESTMODE
	dc.w    BPL5DAT,$0000
	dc.w    BPL6DAT,$0000
	dc.w    $C871,$FFFE ; Wait
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    $CA75,$FFFE ; Wait
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF

	; Block 10 (2 bitplanes, hires)
	dc.w    $D001,$FFFE ; Wait
	dc.w	BPLCON0,$A200|TESTMODE
	dc.w    BPL5DAT,$0000
	dc.w    BPL6DAT,$0000
	dc.w    $D871,$FFFE ; Wait
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    $DA75,$FFFE ; Wait
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF

	; Block 11 (3 bitplanes, hires)
	dc.w    $E001,$FFFE ; Wait
	dc.w	BPLCON0,$B200|TESTMODE
	dc.w    BPL5DAT,$0000
	dc.w    BPL6DAT,$0000
	dc.w    $E871,$FFFE ; Wait
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    $EA75,$FFFE ; Wait
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF

	; Block 12 (4 bitplanes, hires)
	dc.w    $F001,$FFFE ; Wait
	dc.w	BPLCON0,$C200|TESTMODE
	dc.w    BPL5DAT,$0000
	dc.w    BPL6DAT,$0000
	dc.w    $F871,$FFFE ; Wait
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    $FA75,$FFFE ; Wait
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF

	dc.w    $ffdf,$fffe ; Cross vertical boundary

	; Block 13 (5 bitplanes, hires)
	dc.w    $0001,$FFFE ; Wait
	dc.w	BPLCON0,$D200|TESTMODE
	dc.w    BPL5DAT,$0000
	dc.w    BPL6DAT,$0000
	dc.w    $0871,$FFFE ; Wait
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    $0A75,$FFFE ; Wait
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF

	; Block 14 (6 bitplanes, hires)
	dc.w    $1001,$FFFE ; Wait
	dc.w	BPLCON0,$E200|TESTMODE
	dc.w    BPL5DAT,$0000
	dc.w    BPL6DAT,$0000
	dc.w    $1871,$FFFE ; Wait
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    $1A75,$FFFE ; Wait
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF

	; Block 15 (7 bitplanes, hires)
	dc.w    $2001,$FFFE ; Wait
	dc.w	BPLCON0,$F200|TESTMODE
	dc.w    BPL5DAT,$0000
	dc.w    BPL6DAT,$0000
	dc.w    $2871,$FFFE ; Wait
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    BPL5DAT,$FFFF
	dc.w    $2A75,$FFFE ; Wait
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF
	dc.w    BPL6DAT,$FFFF

	dc.l	$fffffffe

bitplane1:
	ds.b    8000
bitplane2:
	ds.b    8000
bitplane3:
	ds.b    8000
bitplane4:
	ds.b    8000
bitplane5:
	ds.b    8000
bitplane6:
	ds.b    8000
	ds.b    8000