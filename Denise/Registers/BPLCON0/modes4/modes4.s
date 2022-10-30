	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

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
	move.w  #8000,d0
.l1: move.w  #$C000,(a0)+
	dbra    d0,.l1

	lea     bitplane2,a0
	move.w  #8000,d0
.l2: move.w  #$3000,(a0)+
	dbra    d0,.l2

	lea     bitplane3,a0
	move.w  #8000,d0
.l3: move.w  #$0C00,(a0)+
	dbra    d0,.l3

	lea     bitplane4,a0
	move.w  #8000,d0
.l4: move.w  #$0300,(a0)+
	dbra    d0,.l4

	lea     bitplane5,a0
	move.w  #8000,d0
.l5: move.w  #$00C0,(a0)+
	dbra    d0,.l5

	lea     bitplane6,a0
	move.w  #8000,d0
.l6: move.w  #$0030,(a0)+
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

	dc.w    COLOR00,$888
	dc.w    COLOR01,$888
	dc.w    COLOR02,$888
	dc.w    COLOR03,$888
	dc.w    COLOR04,$888
	dc.w    COLOR05,$888
	dc.w    COLOR06,$888
	dc.w    COLOR07,$888
	dc.w    COLOR08,$888
	dc.w    COLOR09,$888
	dc.w    COLOR10,$888
	dc.w    COLOR11,$888
	dc.w    COLOR12,$888
	dc.w    COLOR13,$888
	dc.w    COLOR14,$888
	dc.w    COLOR15,$888
	dc.w    COLOR16,$888
	dc.w    COLOR17,$888
	dc.w    COLOR18,$888
	dc.w    COLOR19,$888
	dc.w    COLOR20,$888
	dc.w    COLOR21,$888
	dc.w    COLOR22,$888
	dc.w    COLOR23,$888
	dc.w    COLOR24,$888
	dc.w    COLOR25,$888
	dc.w    COLOR26,$888
	dc.w    COLOR27,$888
	dc.w    COLOR28,$888
	dc.w    COLOR29,$888
	dc.w    COLOR30,$888
	dc.w    COLOR31,$888

	dc.w    DDFSTRT,$0068
	dc.w	DDFSTOP,$00A8
	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPL1MOD,$0
	dc.w	BPL2MOD,$0
	dc.w	BPLCON0,$6E00

	dc.w    $3001,$FFFE ; Wait
	dc.w    COLOR01,$FFF
	dc.w    $3801,$FFFE ; Wait
	dc.w    COLOR02,$FFF
	dc.w    $4001,$FFFE ; Wait
	dc.w    COLOR03,$FFF
	dc.w    $5001,$FFFE ; Wait
	dc.w    COLOR04,$FFF
	dc.w    $5801,$FFFE ; Wait
	dc.w    COLOR05,$FFF
	dc.w    $6001,$FFFE ; Wait
	dc.w    COLOR06,$FFF
	dc.w    $6801,$FFFE ; Wait
	dc.w    COLOR07,$FFF
	dc.w    $7001,$FFFE ; Wait
	dc.w    COLOR08,$FFF
	dc.w    $7801,$FFFE ; Wait
	dc.w    COLOR09,$FFF
	dc.w    $8001,$FFFE ; Wait
	dc.w    COLOR10,$FFF
	dc.w    $8801,$FFFE ; Wait
	dc.w    COLOR11,$FFF
	dc.w    $9001,$FFFE ; Wait
	dc.w    COLOR12,$FFF
	dc.w    $9801,$FFFE ; Wait
	dc.w    COLOR13,$FFF
	dc.w    $A001,$FFFE ; Wait
	dc.w    COLOR14,$FFF
	dc.w    $A801,$FFFE ; Wait
	dc.w    COLOR15,$FFF
	dc.w    $B001,$FFFE ; Wait
	dc.w    COLOR16,$FFF
	dc.w    $B801,$FFFE ; Wait
	dc.w    COLOR17,$FFF
	dc.w    $C001,$FFFE ; Wait
	dc.w    COLOR18,$FFF
	dc.w    $C801,$FFFE ; Wait
	dc.w    COLOR19,$FFF
	dc.w    $D001,$FFFE ; Wait
	dc.w    COLOR20,$FFF
	dc.w    $D801,$FFFE ; Wait
	dc.w    COLOR21,$FFF
	dc.w    $E001,$FFFE ; Wait
	dc.w    COLOR22,$FFF
	dc.w    $E801,$FFFE ; Wait
	dc.w    COLOR23,$FFF
	dc.w    $F001,$FFFE ; Wait
	dc.w    COLOR24,$FFF
	dc.w    $F801,$FFFE ; Wait
	dc.w    COLOR25,$FFF

	dc.w    $ffdf,$fffe ; Cross vertical boundary

	dc.w    $0001,$FFFE ; Wait
	dc.w    COLOR26,$FFF
	dc.w    $0801,$FFFE ; Wait
	dc.w    COLOR27,$FFF
	dc.w    $1001,$FFFE ; Wait
	dc.w    COLOR28,$FFF
	dc.w    $1801,$FFFE ; Wait
	dc.w    COLOR29,$FFF
	dc.w    $2001,$FFFE ; Wait
	dc.w    COLOR30,$FFF
	dc.w    $2801,$FFFE ; Wait
	dc.w    COLOR31,$FFF

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