	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"
	
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

	; Install single bitplane
	move.w  #$1200,BPLCON0(a1) ; 1 bitplane
	move.w  #$0000,BPL1MOD(a1) 
	move.w  #$0000,BPLCON1(a1) ; No scroll
	move.w  #$0024,BPLCON2(a1) ; Sprites have priority over playfields
	move.w  #$0038,DDFSTRT(a1)
	move.w  #$00D0,DDFSTOP(a1)
	move.w  #$2C81,DIWSTRT(a1) 
	move.w  #$F4C1,DIWSTOP(a1)

	; Setup colors
	move.w  #$0008,COLOR00(a1)
	move.w  #$0000,COLOR01(a1)
	move.w  #$0FF0,COLOR17(a1)
	move.w  #$00FF,COLOR18(a1)
	move.w  #$0F0F,COLOR19(a1)

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
	lea	    sprite(pc),a2
 	move.l	a2,SPR0PTH(a1)
	lea	    dummysprite(pc),a2
 	move.l	a2,SPR1PTH(a1)
 	move.l	a2,SPR2PTH(a1)
 	move.l	a2,SPR3PTH(a1)
 	move.l	a2,SPR4PTH(a1)
 	move.l	a2,SPR5PTH(a1)
 	move.l	a2,SPR6PTH(a1)
 	move.l	a2,SPR7PTH(a1)

	movem.l	(sp)+,d0-a6
	rte

;
; Copper list
;

copper: 

	dc.w    $8001,$FFFE
	dc.w    COLOR00, $000
 
	dc.w	$FFDF,$FFFE  ; Cross vertical boundary
	dc.w    $FFFF,$FFFE  ; End of Copper list

;
; Sprite data
; 

sprite:
	DC.W    $4D60,$5200 ;VSTART, HSTART, VSTOP
	DC.W    $0990,$07E0 ;First pair of descriptor words
	DC.W    $13C8,$0FF0
	DC.W    $23C4,$1FF8
	DC.W    $13C8,$0FF0
	DC.W    $0990,$07E0
	 		
	DC.W    $5160,$6000 ;VSTART, HSTART, VSTOP   (VSTRT NEVER REACHED)
	DC.W    $5960,$6200 ;VSTART, HSTART, VSTOP   (VSTRT NEVER REACHED)
	DC.W    $6160,$6400 ;VSTART, HSTART, VSTOP   (VSTRT NEVER REACHED)

	DC.W    $8D60,$9200 ;VSTART, HSTART, VSTOP
	DC.W    $0990,$07E0 ;First pair of descriptor words
	DC.W    $13C8,$0FF0
	DC.W    $23C4,$1FF8
	DC.W    $13C8,$0FF0
	DC.W    $0990,$07E0

	DC.W    $B060,$A000 ;VSTART, HSTART, VSTOP   (VSTRT > VSTOP)
	DC.W    $B260,$A200 ;VSTART, HSTART, VSTOP   (VSTRT > VSTOP)
	DC.W    $B460,$A400 ;VSTART, HSTART, VSTOP   (VSTRT > VSTOP)

	DC.W    $CD60,$D200 ;VSTART, HSTART, VSTOP
	DC.W    $0990,$07E0 ;First pair of descriptor words
	DC.W    $13C8,$0FF0
	DC.W    $23C4,$1FF8
	DC.W    $13C8,$0FF0
	DC.W    $0990,$07E0

	DC.W    $0000,$0000 ;End of sprite data
	
dummysprite:
	DC.W    $0000,$0000

bitplanes:
	ds.b    51201