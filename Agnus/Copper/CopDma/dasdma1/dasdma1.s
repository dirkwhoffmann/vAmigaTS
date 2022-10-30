	include "../../../../include/registers.i"
	include "../../../include/ministartup.i"
	
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

STRIPE	MACRO
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$080
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$080
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$080
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$080
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$080
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$080
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$080
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$080
	dc.w    COLOR00,$000
	ENDM

MAIN:
	jsr 	setup

.mainLoop:
	bra.b	.mainLoop

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
	move.w  #$FF8,COLOR17(a1)
	move.w  #$F00,COLOR18(a1)
	move.w  #$F00,COLOR19(a1)
	move.w  #$8FF,COLOR21(a1)
	move.w  #$F00,COLOR22(a1)
	move.w  #$F00,COLOR23(a1)
	move.w  #$8F8,COLOR25(a1)
	move.w  #$F00,COLOR26(a1)
	move.w  #$F00,COLOR27(a1)
	move.w  #$F8F,COLOR29(a1)
	move.w  #$F00,COLOR30(a1)
	move.w  #$F00,COLOR31(a1)

	; Install Copper list
	lea    	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA Copper, bitplane, and sprite DMA
	move.w  #$8100,DMACON(a1) ; Bitplane DMA
	move.w  #$8080,DMACON(a1) ; Copper DMA
	; move.w  #$8020,DMACON(a1) ; Sprite DMA
	move.w  #$8200,DMACON(a1) ; DMA enable

	; Enable interrupts
	move.w	#$C02C,INTENA(a1)

	rts 

irq1:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	move.w  #$888,COLOR00(a1)
	move.w  #SPRDMAON,DMACON(a1)
	move.w  #$000,COLOR00(a1)
	rte

irq2:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	move.w  #$888,COLOR00(a1)
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
	; Copper
	;

copper:

	dc.w	BPLCON0,$1200
	
	;
	; Area 1
	; 

	dc.w    $3401,$FFFE
	dc.w    DMACON, $000F  ; Audio DMA off
	dc.w    DMACON, $0010  ; Audio DMA off

    dc.w    $38DD,$FFFE
	STRIPE
	dc.w    $3C41,$FFFE 
	RULER   
    dc.w    $3EDD,$FFFE
	STRIPE

	; 
	; Area 2
	; 

	dc.w    $5401,$FFFE
	dc.w    DMACON, $800F  ; Audio DMA on
	dc.w    DMACON, $0010  ; Audio DMA off

    dc.w    $58DD,$FFFE
	STRIPE
	dc.w    $5C41,$FFFE 
	RULER
    dc.w    $5EDD,$FFFE
	STRIPE
 
	; 
	; Area 3
	; 

	dc.w    $7401,$FFFE
	dc.w    DMACON, $000F  ; Audio DMA off
	dc.w    DMACON, $8010  ; Audio DMA on

    dc.w    $78DD,$FFFE
	STRIPE
	dc.w    $7C41,$FFFE 
	RULER
    dc.w    $7EDD,$FFFE
	STRIPE

	; 
	; Area 4
	; 

	dc.w    $9401,$FFFE
	dc.w    DMACON, $800F  ; Audio DMA on
	dc.w    DMACON, $8010  ; Audio DMA on

    dc.w    $98DD,$FFFE
	STRIPE
	dc.w    $9C41,$FFFE 
	RULER
    dc.w    $9EDD,$FFFE
	STRIPE

	dc.w    $ffdf,$fffe ; Cross vertical boundary

	dc.w	BPLCON0,$200

	dc.l	$fffffffe


	;
	;  Sprite data 
	;

SPRITE0:
			DC.W    $3D79,$4D00 ;VSTART, HSTART, VSTOP
	        DC.W    $8000,$0000 ; 0
	        DC.W    $4000,$0000 ; 1
	        DC.W    $2000,$0000 ; 2
	        DC.W    $1000,$0000 ; 3
	        DC.W    $0800,$0000 ; 4
	        DC.W    $0400,$0000 ; 5
	        DC.W    $0200,$0000 ; 6
	        DC.W    $0100,$0000 ; 7
	        DC.W    $0080,$0000 ; 8
	        DC.W    $0040,$0000 ; 9
	        DC.W    $0020,$0000 ; 10
	        DC.W    $0010,$0000 ; 11
	        DC.W    $0008,$0000 ; 12
	        DC.W    $0004,$0000 ; 13
	        DC.W    $0002,$0000 ; 14
	        DC.W    $0001,$0000 ; 15
	        DC.W    $0000,$0000 ; End of sprite data
SPRITE1:
			DC.W    $3D81,$4D00 ;VSTART, HSTART, VSTOP
	        DC.W    $8000,$0000 ; 0
	        DC.W    $4000,$0000 ; 1
	        DC.W    $2000,$0000 ; 2
	        DC.W    $1000,$0000 ; 3
	        DC.W    $0800,$0000 ; 4
	        DC.W    $0400,$0000 ; 5
	        DC.W    $0200,$0000 ; 6
	        DC.W    $0100,$0000 ; 7
	        DC.W    $0080,$0000 ; 8
	        DC.W    $0040,$0000 ; 9
	        DC.W    $0020,$0000 ; 10
	        DC.W    $0010,$0000 ; 11
	        DC.W    $0008,$0000 ; 12
	        DC.W    $0004,$0000 ; 13
	        DC.W    $0002,$0000 ; 14
	        DC.W    $0001,$0000 ; 15
	        DC.W    $0000,$0000 ; End of sprite data
SPRITE2:
			DC.W    $5D89,$6D00 ;VSTART, HSTART, VSTOP
	        DC.W    $8000,$0000 ; 0
	        DC.W    $4000,$0000 ; 1
	        DC.W    $2000,$0000 ; 2
	        DC.W    $1000,$0000 ; 3
	        DC.W    $0800,$0000 ; 4
	        DC.W    $0400,$0000 ; 5
	        DC.W    $0200,$0000 ; 6
	        DC.W    $0100,$0000 ; 7
	        DC.W    $0080,$0000 ; 8
	        DC.W    $0040,$0000 ; 9
	        DC.W    $0020,$0000 ; 10
	        DC.W    $0010,$0000 ; 11
	        DC.W    $0008,$0000 ; 12
	        DC.W    $0004,$0000 ; 13
	        DC.W    $0002,$0000 ; 14
	        DC.W    $0001,$0000 ; 15
	        DC.W    $0000,$0000 ; End of sprite data
SPRITE3:
			DC.W    $7D91,$8D00 ;VSTART, HSTART, VSTOP
	        DC.W    $8000,$0000 ; 0
	        DC.W    $4000,$0000 ; 1
	        DC.W    $2000,$0000 ; 2
	        DC.W    $1000,$0000 ; 3
	        DC.W    $0800,$0000 ; 4
	        DC.W    $0400,$0000 ; 5
	        DC.W    $0200,$0000 ; 6
	        DC.W    $0100,$0000 ; 7
	        DC.W    $0080,$0000 ; 8
	        DC.W    $0040,$0000 ; 9
	        DC.W    $0020,$0000 ; 10
	        DC.W    $0010,$0000 ; 11
	        DC.W    $0008,$0000 ; 12
	        DC.W    $0004,$0000 ; 13
	        DC.W    $0002,$0000 ; 14
	        DC.W    $0001,$0000 ; 15
	        DC.W    $0000,$0000 ; End of sprite data
SPRITE4:
			DC.W    $7D99,$8D00 ;VSTART, HSTART, VSTOP
	        DC.W    $8000,$0000 ; 0
	        DC.W    $4000,$0000 ; 1
	        DC.W    $2000,$0000 ; 2
	        DC.W    $1000,$0000 ; 3
	        DC.W    $0800,$0000 ; 4
	        DC.W    $0400,$0000 ; 5
	        DC.W    $0200,$0000 ; 6
	        DC.W    $0100,$0000 ; 7
	        DC.W    $0080,$0000 ; 8
	        DC.W    $0040,$0000 ; 9
	        DC.W    $0020,$0000 ; 10
	        DC.W    $0010,$0000 ; 11
	        DC.W    $0008,$0000 ; 12
	        DC.W    $0004,$0000 ; 13
	        DC.W    $0002,$0000 ; 14
	        DC.W    $0001,$0000 ; 15
	        DC.W    $0000,$0000 ; End of sprite data
SPRITE5:
			DC.W    $7DA1,$8D00 ;VSTART, HSTART, VSTOP
	        DC.W    $8000,$0000 ; 0
	        DC.W    $4000,$0000 ; 1
	        DC.W    $2000,$0000 ; 2
	        DC.W    $1000,$0000 ; 3
	        DC.W    $0800,$0000 ; 4
	        DC.W    $0400,$0000 ; 5
	        DC.W    $0200,$0000 ; 6
	        DC.W    $0100,$0000 ; 7
	        DC.W    $0080,$0000 ; 8
	        DC.W    $0040,$0000 ; 9
	        DC.W    $0020,$0000 ; 10
	        DC.W    $0010,$0000 ; 11
	        DC.W    $0008,$0000 ; 12
	        DC.W    $0004,$0000 ; 13
	        DC.W    $0002,$0000 ; 14
	        DC.W    $0001,$0000 ; 15
	        DC.W    $0000,$0000 ; End of sprite data
SPRITE6:
			DC.W    $9DA9,$AD00 ;VSTART, HSTART, VSTOP
	        DC.W    $8000,$0000 ; 0
	        DC.W    $4000,$0000 ; 1
	        DC.W    $2000,$0000 ; 2
	        DC.W    $1000,$0000 ; 3
	        DC.W    $0800,$0000 ; 4
	        DC.W    $0400,$0000 ; 5
	        DC.W    $0200,$0000 ; 6
	        DC.W    $0100,$0000 ; 7
	        DC.W    $0080,$0000 ; 8
	        DC.W    $0040,$0000 ; 9
	        DC.W    $0020,$0000 ; 10
	        DC.W    $0010,$0000 ; 11
	        DC.W    $0008,$0000 ; 12
	        DC.W    $0004,$0000 ; 13
	        DC.W    $0002,$0000 ; 14
	        DC.W    $0001,$0000 ; 15
	        DC.W    $0000,$0000 ; End of sprite data
SPRITE7:
			DC.W    $9DB1,$AD00 ;VSTART, HSTART, VSTOP
	        DC.W    $8000,$0000 ; 0
	        DC.W    $4000,$0000 ; 1
	        DC.W    $2000,$0000 ; 2
	        DC.W    $1000,$0000 ; 3
	        DC.W    $0800,$0000 ; 4
	        DC.W    $0400,$0000 ; 5
	        DC.W    $0200,$0000 ; 6
	        DC.W    $0100,$0000 ; 7
	        DC.W    $0080,$0000 ; 8
	        DC.W    $0040,$0000 ; 9
	        DC.W    $0020,$0000 ; 10
	        DC.W    $0010,$0000 ; 11
	        DC.W    $0008,$0000 ; 12
	        DC.W    $0004,$0000 ; 13
	        DC.W    $0002,$0000 ; 14
	        DC.W    $0001,$0000 ; 15
	        DC.W    $0000,$0000 ; End of sprite data

bitplanes:
	ds.b 51201,0
	