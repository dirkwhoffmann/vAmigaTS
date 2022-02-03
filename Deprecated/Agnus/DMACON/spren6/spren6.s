	include "../../../../include/registers.i"
	include "../../../include/ministartup.i"
	
MAIN:
	jsr 	setup

.mainLoop:
	jsr     synccpu
	bra.b	.mainLoop

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
	move.w  #$8020,DMACON(a1) ; Sprite DMA
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
	move.w  #$555,COLOR00(a1)
	move.w  #$222,COLOR00(a1)
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
			DC.W    $4D81,$5D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $6D91,$7D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $8DA1,$9D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $ADB1,$BD00 ;VSTART, HSTART, VSTOP
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

copper:
	dc.w    BPLCON2, $0B	
	dc.w    BPLCON0, (1<<12)|$600
sprite0:
	dc.w    SPR0PTL, $0000
sprite1:
	dc.w    SPR1PTL, $0000
sprite2:
	dc.w    SPR2PTL, $0000
sprite3:
	dc.w    SPR3PTL, $0000
sprite4:
	dc.w    SPR4PTL, $0000
sprite5:
	dc.w    SPR5PTL, $0000
sprite6:
	dc.w    SPR6PTL, $0000
sprite7:
	dc.w    SPR7PTL, $0000

	;
	; Sprite 1
	; 

	dc.w    $3B41,$FFFE 
	RULER
   
    dc.w    $3CBB,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $3D01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $3EBD,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $3F01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $40BF,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $4101,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $42C1,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $4301,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $44C3,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $4501,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $46C5,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $3701,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $48C7,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $4901,$FFFE 
	dc.w    DMACON,$0020

	; 
	; Sprite 2
	; 

	dc.w    $4C41,$FFFE 
	RULER

    dc.w    $4CBB,$FFFE
	dc.w    INTREQ,$8008       ; Level 2 IRQ
	dc.w    $4D01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $4EBD,$FFFE
	dc.w    INTREQ,$8008       ; Level 2 IRQ
	dc.w    $4F01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $50BF,$FFFE
	dc.w    INTREQ,$8008       ; Level 2 IRQ
	dc.w    $5101,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $52C1,$FFFE
	dc.w    INTREQ,$8008       ; Level 2 IRQ
	dc.w    $5301,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $54C3,$FFFE
	dc.w    INTREQ,$8008       ; Level 2 IRQ
	dc.w    $5501,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $56C5,$FFFE
	dc.w    INTREQ,$8008       ; Level 2 IRQ
	dc.w    $5701,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $5C7,$FFFE
	dc.w    INTREQ,$8008       ; Level 2 IRQ
	dc.w    $5901,$FFFE 
	dc.w    DMACON,$0020

	; 
	; Sprite 3
	; 

	dc.w    $5C41,$FFFE 
	RULER

    dc.w    $5CBB,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $5D01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $5EBD,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $5F01,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $60BF,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $6101,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $62C1,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $6301,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $64C3,$FFFE
	dc.w    INTREQ, $8004       ; Level 1 IRQ
	dc.w    $6501,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $66C5,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $6701,$FFFE 
	dc.w    DMACON,$0020

    dc.w    $68C7,$FFFE
	dc.w    INTREQ,$8004       ; Level 1 IRQ
	dc.w    $6901,$FFFE 
	dc.w    DMACON,$0020

	dc.w    $6C41,$FFFE 
	RULER

	dc.w    $ffdf,$fffe ; Cross vertical boundary

	dc.w	BPLCON0,$200

	dc.l	$fffffffe

bitplanes:
	ds.b 51201,0