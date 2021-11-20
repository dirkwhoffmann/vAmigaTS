	include "../../../include/registers.i"
	include "../../../include/ministartup.i"
	
LVL3_INT_VECTOR		equ $6c
	
MAIN:
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
	lea	    irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	; Setup Copper
	lea	    copper,a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Setup colors
	move.w  #$000,COLOR00(a1)
	move.w  #$8AF,COLOR01(a1)
	move.w  #$CC4,COLOR02(a1)

	; Setup bitplane data
	moveq   #7,d3
	lea     bitplanes1,a2
.x1:
	move.l	#252,d0
.x2:
	move.l 	#$AAAAAAAA,(a2)+
	dbra	d0,.x2
	move.l	#252,d0
.x3:
	move.l 	#$00000000,(a2)+
	dbra	d0,.x3
	dbra    d3,.x1

	moveq   #7,d3
	lea     bitplanes2,a2
.y1:
	move.l	#252,d0
.y2:
	move.l 	#$00000000,(a2)+
	dbra	d0,.y2
	move.l	#252,d0
.y3:
	move.l 	#$AAAAAAAA,(a2)+
	dbra	d0,.y3
	dbra    d3,.y1

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 

	; Enable interrupts
	move.w	#$C020,INTENA(a1)

.mainLoop:
	bra.b	.mainLoop

irq3:
	movem.l	d0-a6,-(sp)

	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	move.w  #$0030,DDFSTRT(a1)
	move.w  #$00D8,DDFSTOP(a1)
	move.w  #$2200,BPLCON0(a1)        ; 1 Bitplane
	move.w  #0,BPL1MOD(a1)
	move.w  #0,BPL2MOD(a1)

	lea	    bitplanes1(pc),a2
	move.l  a2,BPL1PTH(a1)
	lea	    bitplanes2(pc),a2
	move.l  a2,BPL2PTH(a1)

	movem.l	(sp)+,d0-a6
	rte

bitplanes1:
	ds.b    16384,$00
bitplanes2:
	ds.b    16384,$00
	