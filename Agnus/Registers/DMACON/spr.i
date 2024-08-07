
LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
SPRDMAON          	equ $8020
SPRDMAOFF         	equ $0020

RULER	MACRO
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	ENDM

	include "../../../../include/registers.i"
	include "../../../include/ministartup.i"
	
MAIN:
	jsr 	setup

mainloop: 
	jsr     synccpu
delayloop:
   	move.w  #2000,d3
.loop1:
	move.w  #$555,COLOR00(a1)
	move.w  #$222,COLOR00(a1)
	dbra    d3,.loop1
   	move.w  #300,d3
	move.w  #$F0F,d4
	move.w  #$000,d5
.loop2:
	move.w  d4,COLOR00(a1)
	move.w  d5,COLOR00(a1)
    dbra    d3,.loop2
	bra.s   mainloop
	
setup:
	; Load OCS base address
	lea     CUSTOM,a1
	
	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$0200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00
	move.b  #$7F,$BFED01

	; Install interrupt handlers
	lea	    irq1(pc),a3 
 	move.l	a3,LVL1_INT_VECTOR
	lea	    irq2(pc),a3 
 	move.l	a3,LVL2_INT_VECTOR
	lea	    irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	; Setup playfield
	move.w  #$1200,BPLCON0(a1) ; 1 bitplane
	move.w  #$0000,BPL1MOD(a1) 
	move.w  #$0000,BPLCON1(a1) ; No scroll
	move.w  #$0024,BPLCON2(a1) ; Sprites have priority over playfields
	move.w  #$0038,DDFSTRT(a1)
	move.w  #$00D0,DDFSTOP(a1)
	move.w  #$2C81,DIWSTRT(a1) 
	move.w  #$F4C1,DIWSTOP(a1)

	; Setup colors
	move.w  #$008,COLOR00(a1)
	move.w  #$000,COLOR01(a1)

	move.w  #$F00,COLOR17(a1)
	move.w  #$0F0,COLOR18(a1)
	move.w  #$FF0,COLOR19(a1)

	move.w  #$F00,COLOR21(a1)
	move.w  #$0F0,COLOR22(a1)
	move.w  #$FF0,COLOR23(a1)

	move.w  #$F00,COLOR25(a1)
	move.w  #$0F0,COLOR26(a1)
	move.w  #$FF0,COLOR27(a1)

	move.w  #$F00,COLOR29(a1)
	move.w  #$0F0,COLOR30(a1)
	move.w  #$FF0,COLOR31(a1)

	; Install Copper list
	lea    	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA Copper, bitplane, and sprite DMA
	move.w  #$8100,DMACON(a1) ; Bitplane DMA
	move.w  #$8080,DMACON(a1) ; Copper DMA
	move.w  #$8020,DMACON(a1) ; Sprite DMA
	move.w  #$8200,DMACON(a1) ; DMA enable

	; Enable interrupts
	move.w	#$C02C,INTENA(a1)

	rts 

irq1:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	move.w  #$F44,COLOR00(a1)
	move.w  #SPRDMAON,DMACON(a1)
	move.w  #$000,COLOR00(a1)
	rte

irq2:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	move.w  #$4F4,COLOR00(a1)
	move.w  #SPRDMAOFF,DMACON(a1)
	move.w  #$000,COLOR00(a1)
	rte
	
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

synccpu:
	lea     VHPOSR(a1),a3      ; VHPOSR     

	; Wait until we have reached a certain scanline
.loop 
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$2000,d2
	bne     .loop
	and     #1,VPOSR(a1)
	bne     .loop

	; Sync horizontally
	move.w  #$F0F,COLOR00(a1)
.synccpu1:
	andi.w  #$F,(a3)          ; 16 cycles
	bne     .synccpu1         ; 10 cycles
	move.w  #$606,COLOR00(a1)
.synccpu2:
	andi.w  #$1F,(a3)         ; 16 cycles
	bne     .synccpu2         ; 10 cycles
	move.w  #$A0A,COLOR00(a1)
.synccpu3:
	andi.w  #$FF,(a3)         ; 16 cycles
	nop                       ;  4 cycles
	nop                       ;  4 cycles
	nop                       ;  4 cycles
	bne     .synccpu3         ; 10 cycles (if taken)

	; Adust horizontally
  	moveq   #10,d2
.adjust:
    dbra    d2,.adjust

	; Sync vertically
.synccpu4:
	nop 
	move.w  #$404,COLOR00(a1)
	ds.w    96,$4E71          ; NOPs to keep the horizontal position in each iteration
	move.w  (a3),d2     
	move.w  #$F0F,COLOR00(a1)  
	and     #$FF00,d2
	cmp.w   #$3000,d2
	bne     .synccpu4
	move.w  #$000,COLOR00(a1)
	rts

	;
	;  Sprite data 
	;

SPRITE0:
			DC.W    $3D79,$4D00 ;VSTART, HSTART, VSTOP
	        DC.W    $8000,$8000 ; 0
	        DC.W    $4000,$4000 ; 1
	        DC.W    $2000,$2000 ; 2
	        DC.W    $1000,$1000 ; 3
	        DC.W    $0800,$0800 ; 4
	        DC.W    $0400,$0400 ; 5
	        DC.W    $0200,$0200 ; 6
	        DC.W    $0100,$0100 ; 7
	        DC.W    $0080,$0080 ; 8
	        DC.W    $0040,$0040 ; 9
	        DC.W    $0020,$0020 ; 10
	        DC.W    $0010,$0010 ; 11
	        DC.W    $0008,$0008 ; 12
	        DC.W    $0004,$0004 ; 13
	        DC.W    $0002,$0002 ; 14
	        DC.W    $0001,$0001 ; 15
	        DC.W    $0000,$0000 ; End of sprite data
SPRITE1:
			DC.W    $4D81,$5D00 ;VSTART, HSTART, VSTOP
	        DC.W    $8000,$8000 ; 0
	        DC.W    $4000,$4000 ; 1
	        DC.W    $2000,$2000 ; 2
	        DC.W    $1000,$1000 ; 3
	        DC.W    $0800,$0800 ; 4
	        DC.W    $0400,$0400 ; 5
	        DC.W    $0200,$0200 ; 6
	        DC.W    $0100,$0100 ; 7
	        DC.W    $0080,$0080 ; 8
	        DC.W    $0040,$0040 ; 9
	        DC.W    $0020,$0020 ; 10
	        DC.W    $0010,$0010 ; 11
	        DC.W    $0008,$0008 ; 12
	        DC.W    $0004,$0004 ; 13
	        DC.W    $0002,$0002 ; 14
	        DC.W    $0001,$0001 ; 15
	        DC.W    $0000,$0000 ; End of sprite data
SPRITE2:
			DC.W    $5D89,$6D00 ;VSTART, HSTART, VSTOP
	        DC.W    $8000,$8000 ; 0
	        DC.W    $4000,$4000 ; 1
	        DC.W    $2000,$2000 ; 2
	        DC.W    $1000,$1000 ; 3
	        DC.W    $0800,$0800 ; 4
	        DC.W    $0400,$0400 ; 5
	        DC.W    $0200,$0200 ; 6
	        DC.W    $0100,$0100 ; 7
	        DC.W    $0080,$0080 ; 8
	        DC.W    $0040,$0040 ; 9
	        DC.W    $0020,$0020 ; 10
	        DC.W    $0010,$0010 ; 11
	        DC.W    $0008,$0008 ; 12
	        DC.W    $0004,$0004 ; 13
	        DC.W    $0002,$0002 ; 14
	        DC.W    $0001,$0001 ; 15
	        DC.W    $0000,$0000 ; End of sprite data
SPRITE3:
			DC.W    $6D91,$7D00 ;VSTART, HSTART, VSTOP
	        DC.W    $8000,$8000 ; 0
	        DC.W    $4000,$4000 ; 1
	        DC.W    $2000,$2000 ; 2
	        DC.W    $1000,$1000 ; 3
	        DC.W    $0800,$0800 ; 4
	        DC.W    $0400,$0400 ; 5
	        DC.W    $0200,$0200 ; 6
	        DC.W    $0100,$0100 ; 7
	        DC.W    $0080,$0080 ; 8
	        DC.W    $0040,$0040 ; 9
	        DC.W    $0020,$0020 ; 10
	        DC.W    $0010,$0010 ; 11
	        DC.W    $0008,$0008 ; 12
	        DC.W    $0004,$0004 ; 13
	        DC.W    $0002,$0002 ; 14
	        DC.W    $0001,$0001 ; 15
	        DC.W    $0000,$0000 ; End of sprite data
SPRITE4:
			DC.W    $7D99,$8D00 ;VSTART, HSTART, VSTOP
	        DC.W    $8000,$8000 ; 0
	        DC.W    $4000,$4000 ; 1
	        DC.W    $2000,$2000 ; 2
	        DC.W    $1000,$1000 ; 3
	        DC.W    $0800,$0800 ; 4
	        DC.W    $0400,$0400 ; 5
	        DC.W    $0200,$0200 ; 6
	        DC.W    $0100,$0100 ; 7
	        DC.W    $0080,$0080 ; 8
	        DC.W    $0040,$0040 ; 9
	        DC.W    $0020,$0020 ; 10
	        DC.W    $0010,$0010 ; 11
	        DC.W    $0008,$0008 ; 12
	        DC.W    $0004,$0004 ; 13
	        DC.W    $0002,$0002 ; 14
	        DC.W    $0001,$0001 ; 15
	        DC.W    $0000,$0000 ; End of sprite data
SPRITE5:
			DC.W    $8DA1,$9D00 ;VSTART, HSTART, VSTOP
	        DC.W    $8000,$8000 ; 0
	        DC.W    $4000,$4000 ; 1
	        DC.W    $2000,$2000 ; 2
	        DC.W    $1000,$1000 ; 3
	        DC.W    $0800,$0800 ; 4
	        DC.W    $0400,$0400 ; 5
	        DC.W    $0200,$0200 ; 6
	        DC.W    $0100,$0100 ; 7
	        DC.W    $0080,$0080 ; 8
	        DC.W    $0040,$0040 ; 9
	        DC.W    $0020,$0020 ; 10
	        DC.W    $0010,$0010 ; 11
	        DC.W    $0008,$0008 ; 12
	        DC.W    $0004,$0004 ; 13
	        DC.W    $0002,$0002 ; 14
	        DC.W    $0001,$0001 ; 15
	        DC.W    $0000,$0000 ; End of sprite data
SPRITE6:
			DC.W    $9DA9,$AD00 ;VSTART, HSTART, VSTOP
	        DC.W    $8000,$8000 ; 0
	        DC.W    $4000,$4000 ; 1
	        DC.W    $2000,$2000 ; 2
	        DC.W    $1000,$1000 ; 3
	        DC.W    $0800,$0800 ; 4
	        DC.W    $0400,$0400 ; 5
	        DC.W    $0200,$0200 ; 6
	        DC.W    $0100,$0100 ; 7
	        DC.W    $0080,$0080 ; 8
	        DC.W    $0040,$0040 ; 9
	        DC.W    $0020,$0020 ; 10
	        DC.W    $0010,$0010 ; 11
	        DC.W    $0008,$0008 ; 12
	        DC.W    $0004,$0004 ; 13
	        DC.W    $0002,$0002 ; 14
	        DC.W    $0001,$0001 ; 15
	        DC.W    $0000,$0000 ; End of sprite data
SPRITE7:
			DC.W    $ADB1,$BD00 ;VSTART, HSTART, VSTOP
	        DC.W    $8000,$8000 ; 0
	        DC.W    $4000,$4000 ; 1
	        DC.W    $2000,$2000 ; 2
	        DC.W    $1000,$1000 ; 3
	        DC.W    $0800,$0800 ; 4
	        DC.W    $0400,$0400 ; 5
	        DC.W    $0200,$0200 ; 6
	        DC.W    $0100,$0100 ; 7
	        DC.W    $0080,$0080 ; 8
	        DC.W    $0040,$0040 ; 9
	        DC.W    $0020,$0020 ; 10
	        DC.W    $0010,$0010 ; 11
	        DC.W    $0008,$0008 ; 12
	        DC.W    $0004,$0004 ; 13
	        DC.W    $0002,$0002 ; 14
	        DC.W    $0001,$0001 ; 15
	        DC.W    $0000,$0000 ; End of sprite data

	