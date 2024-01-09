	include "../../../../include/registers.i"
	
LVL3_INT_VECTOR		equ $6c

MAIN:	
	; Load OCS base address
	lea CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Install interrupt handlers
	lea	    irq3(pc),a2
 	move.l	a2,LVL3_INT_VECTOR

	; Setup playfield
	move.w  #$1200,BPLCON0(a1) ; 1 bitplane
	move.w  #$0000,BPL1MOD(a1) 
	move.w  #$0000,BPLCON1(a1) ; No scroll
	move.w  #$0024,BPLCON2(a1) ; Sprites have priority over playfields
	move.w  #$0038,DDFSTRT(a1)
	move.w  #$00D0,DDFSTOP(a1)
	move.w  #$2C81,DIWSTRT(a1) 
	move.w  #$F4C1,DIWSTOP(a1)

	; Setup bitplane data
	move.l  #25000,d0
	lea     bitplanes,a0
.loop:
	move.w  #$8080,(a0)+ 
	dbra    d0,.loop

	; Setup colors
	move.w  #$0000,COLOR00(a1)
	move.w  #$0444,COLOR01(a1)
	;move.w  #$0FF0,COLOR17(a1)
	;move.w  #$00FF,COLOR18(a1)
	;move.w  #$0F0F,COLOR19(a1)

	; Install Copper list
	lea    	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable Copper, bitplane, and sprite DMA
	move.w  #$8100,DMACON(a1) ; Bitplane DMA
	move.w  #$8080,DMACON(a1) ; Copper DMA
	move.w  #$8020,DMACON(a1) ; Sprite DMA
	move.w  #$8200,DMACON(a1) ; DMA enable

	; Enable interrupts
	move.w	#$C020,INTENA(a1) 

.mainLoop:
	bra.b	.mainLoop

irq3:
	movem.l	d0-a6,-(sp)
	move.w  #$0020,INTREQ(a1)   ; Acknowledge
	move.w  #$000,COLOR00(a1)

	; Reset bitplane pointers
	lea     bitplanes(pc),a2
	move.l	a2,BPL1PTH(a1)

	; Reset sprite pointers
	lea	  	SPRITE0(pc),a2
 	move.l	a2,SPR0PTH(a1)
	lea	    SPRITE1(pc),a2
 	move.l	a2,SPR1PTH(a1)
	lea	    SPRITE2(pc),a2
 	move.l	a2,SPR2PTH(a1)
	lea	    SPRITE3(pc),a2
 	move.l	a2,SPR3PTH(a1)
	lea	    SPRITE4(pc),a2
 	move.l	a2,SPR4PTH(a1)
	lea	    SPRITE5(pc),a2
 	move.l	a2,SPR5PTH(a1)
	lea	    SPRITE6(pc),a2
 	move.l	a2,SPR6PTH(a1)
	lea	    SPRITE7(pc),a2
 	move.l	a2,SPR7PTH(a1)

	movem.l	(sp)+,d0-a6
	rte

;
; Copper list
;

copper:

	; Setup sprite colors
	DC.W    COLOR17,$FF8 
	DC.W    COLOR18,$444 
	DC.W    COLOR19,$F00 

	DC.W    COLOR21,$8FF 
	DC.W    COLOR22,$444 
	DC.W    COLOR23,$F00 

	DC.W    COLOR25,$8F8 
	DC.W    COLOR26,$444 
	DC.W    COLOR27,$F00 

	DC.W    COLOR29,$F8F 
	DC.W    COLOR30,$444 
	DC.W    COLOR31,$00F 

	; dc.w    BPLCON2,$0B	
	dc.w    BPLCON0,$1200

	PAYLOAD

	dc.w    $ffdf,$fffe ; Cross vertical boundary
	dc.w	BPLCON0,$0200
	dc.l	$fffffffe

	;
	;  Sprite data 
	;

SPRITE0:
			DC.W    $3D80+OFFSET,$4D00 ;VSTART, HSTART, VSTOP
	        DC.W    $AAAA,$0000 ; 0
	        DC.W    $AAAA,$0000 ; 1
	        DC.W    $AAAA,$0000 ; 2
	        DC.W    $AAAA,$0000 ; 3
	        DC.W    $AAAA,$0000 ; 4
	        DC.W    $AAAA,$0000 ; 5
	        DC.W    $AAAA,$0000 ; 6
	        DC.W    $AAAA,$0000 ; 7
	        DC.W    $AAAA,$0000 ; 8
	        DC.W    $AAAA,$0000 ; 9
	        DC.W    $AAAA,$0000 ; 10
	        DC.W    $AAAA,$0000 ; 11
	        DC.W    $AAAA,$0000 ; 13
	        DC.W    $AAAA,$0000 ; 14
	        DC.W    $AAAA,$0000 ; 14
	        DC.W    $AAAA,$0000 ; 15
	        DC.W    $0000,$0000 ; End of sprite data
SPRITE1:
			DC.W    $4D80+OFFSET,$5D01 ;VSTART, HSTART, VSTOP
	        DC.W    $AAAA,$0000 ; 0
	        DC.W    $AAAA,$0000 ; 1
	        DC.W    $AAAA,$0000 ; 2
	        DC.W    $AAAA,$0000 ; 3
	        DC.W    $AAAA,$0000 ; 4
	        DC.W    $AAAA,$0000 ; 5
	        DC.W    $AAAA,$0000 ; 6
	        DC.W    $AAAA,$0000 ; 7
	        DC.W    $AAAA,$0000 ; 8
	        DC.W    $AAAA,$0000 ; 9
	        DC.W    $AAAA,$0000 ; 10
	        DC.W    $AAAA,$0000 ; 11
	        DC.W    $AAAA,$0000 ; 13
	        DC.W    $AAAA,$0000 ; 14
	        DC.W    $AAAA,$0000 ; 14
	        DC.W    $AAAA,$0000 ; 15
			DC.W    $0000,$0000 ; End of sprite data
SPRITE2:
			DC.W    $5D81+OFFSET,$6D00 ;VSTART, HSTART, VSTOP
	        DC.W    $AAAA,$0000 ; 0
	        DC.W    $AAAA,$0000 ; 1
	        DC.W    $AAAA,$0000 ; 2
	        DC.W    $AAAA,$0000 ; 3
	        DC.W    $AAAA,$0000 ; 4
	        DC.W    $AAAA,$0000 ; 5
	        DC.W    $AAAA,$0000 ; 6
	        DC.W    $AAAA,$0000 ; 7
	        DC.W    $AAAA,$0000 ; 8
	        DC.W    $AAAA,$0000 ; 9
	        DC.W    $AAAA,$0000 ; 10
	        DC.W    $AAAA,$0000 ; 11
	        DC.W    $AAAA,$0000 ; 13
	        DC.W    $AAAA,$0000 ; 14
	        DC.W    $AAAA,$0000 ; 14
	        DC.W    $AAAA,$0000 ; 15
			DC.W    $0000,$0000 ; End of sprite data
SPRITE3:
			DC.W    $6D81+OFFSET,$7D01 ;VSTART, HSTART, VSTOP
	        DC.W    $AAAA,$0000 ; 0
	        DC.W    $AAAA,$0000 ; 1
	        DC.W    $AAAA,$0000 ; 2
	        DC.W    $AAAA,$0000 ; 3
	        DC.W    $AAAA,$0000 ; 4
	        DC.W    $AAAA,$0000 ; 5
	        DC.W    $AAAA,$0000 ; 6
	        DC.W    $AAAA,$0000 ; 7
	        DC.W    $AAAA,$0000 ; 8
	        DC.W    $AAAA,$0000 ; 9
	        DC.W    $AAAA,$0000 ; 10
	        DC.W    $AAAA,$0000 ; 11
	        DC.W    $AAAA,$0000 ; 13
	        DC.W    $AAAA,$0000 ; 14
	        DC.W    $AAAA,$0000 ; 14
	        DC.W    $AAAA,$0000 ; 15
			DC.W    $0000,$0000 ; End of sprite data
SPRITE4:
			DC.W    $7D82+OFFSET,$8D00 ;VSTART, HSTART, VSTOP
	        DC.W    $AAAA,$0000 ; 0
	        DC.W    $AAAA,$0000 ; 1
	        DC.W    $AAAA,$0000 ; 2
	        DC.W    $AAAA,$0000 ; 3
	        DC.W    $AAAA,$0000 ; 4
	        DC.W    $AAAA,$0000 ; 5
	        DC.W    $AAAA,$0000 ; 6
	        DC.W    $AAAA,$0000 ; 7
	        DC.W    $AAAA,$0000 ; 8
	        DC.W    $AAAA,$0000 ; 9
	        DC.W    $AAAA,$0000 ; 10
	        DC.W    $AAAA,$0000 ; 11
	        DC.W    $AAAA,$0000 ; 13
	        DC.W    $AAAA,$0000 ; 14
	        DC.W    $AAAA,$0000 ; 14
	        DC.W    $AAAA,$0000 ; 15
			DC.W    $0000,$0000 ; End of sprite data
SPRITE5:
			DC.W    $8D82+OFFSET,$9D01 ;VSTART, HSTART, VSTOP
	        DC.W    $AAAA,$0000 ; 0
	        DC.W    $AAAA,$0000 ; 1
	        DC.W    $AAAA,$0000 ; 2
	        DC.W    $AAAA,$0000 ; 3
	        DC.W    $AAAA,$0000 ; 4
	        DC.W    $AAAA,$0000 ; 5
	        DC.W    $AAAA,$0000 ; 6
	        DC.W    $AAAA,$0000 ; 7
	        DC.W    $AAAA,$0000 ; 8
	        DC.W    $AAAA,$0000 ; 9
	        DC.W    $AAAA,$0000 ; 10
	        DC.W    $AAAA,$0000 ; 11
	        DC.W    $AAAA,$0000 ; 13
	        DC.W    $AAAA,$0000 ; 14
	        DC.W    $AAAA,$0000 ; 14
	        DC.W    $AAAA,$0000 ; 15
			DC.W    $0000,$0000 ; End of sprite data
SPRITE6:
			DC.W    $9D83+OFFSET,$AD00 ;VSTART, HSTART, VSTOP
	        DC.W    $AAAA,$0000 ; 0
	        DC.W    $AAAA,$0000 ; 1
	        DC.W    $AAAA,$0000 ; 2
	        DC.W    $AAAA,$0000 ; 3
	        DC.W    $AAAA,$0000 ; 4
	        DC.W    $AAAA,$0000 ; 5
	        DC.W    $AAAA,$0000 ; 6
	        DC.W    $AAAA,$0000 ; 7
	        DC.W    $AAAA,$0000 ; 8
	        DC.W    $AAAA,$0000 ; 9
	        DC.W    $AAAA,$0000 ; 10
	        DC.W    $AAAA,$0000 ; 11
	        DC.W    $AAAA,$0000 ; 13
	        DC.W    $AAAA,$0000 ; 14
	        DC.W    $AAAA,$0000 ; 14
	        DC.W    $AAAA,$0000 ; 15
			DC.W    $0000,$0000 ; End of sprite data
SPRITE7:
			DC.W    $AD83+OFFSET,$BD01 ;VSTART, HSTART, VSTOP
	        DC.W    $AAAA,$0000 ; 0
	        DC.W    $AAAA,$0000 ; 1
	        DC.W    $AAAA,$0000 ; 2
	        DC.W    $AAAA,$0000 ; 3
	        DC.W    $AAAA,$0000 ; 4
	        DC.W    $AAAA,$0000 ; 5
	        DC.W    $AAAA,$0000 ; 6
	        DC.W    $AAAA,$0000 ; 7
	        DC.W    $AAAA,$0000 ; 8
	        DC.W    $AAAA,$0000 ; 9
	        DC.W    $AAAA,$0000 ; 10
	        DC.W    $AAAA,$0000 ; 11
	        DC.W    $AAAA,$0000 ; 13
	        DC.W    $AAAA,$0000 ; 14
	        DC.W    $AAAA,$0000 ; 14
	        DC.W    $AAAA,$0000 ; 15
			DC.W    $0000,$0000 ; End of sprite data

bitplanes:
	ds.b    51201,$0