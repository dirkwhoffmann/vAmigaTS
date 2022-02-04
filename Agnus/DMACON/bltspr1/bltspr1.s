	include "../../../../include/registers.i"
	include "../../../include/ministartup.i"

LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
DDFSTRT_INI			equ $A0
DDFSTOP_INI			equ $D8
BLIT_BLTCON0        equ $0FCA
BLIT_BLTCON1		equ $0000
COL1                equ $66B 
COL2                equ $FF0 
BLTSIZE1            equ (5)<<6|(3)

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

MAIN:	

	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Disable DMA
	move.w  #$7FFF,DMACON(a1)

	; Install interrupt handlers
	lea	    irq1(pc),a3 
 	move.l	a3,LVL1_INT_VECTOR
	lea	    irq2(pc),a3 
 	move.l	a3,LVL2_INT_VECTOR
	lea	    irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	; Setup playfield
	move.w  #$0000,BPL1MOD(a1) 
	move.w  #$0000,BPLCON1(a1)
	move.w  #DDFSTRT_INI,DDFSTRT(a1)
	move.w  #DDFSTOP_INI,DDFSTOP(a1)
	move.w  #$2C81,DIWSTRT(a1) 
	move.w  #$74C1,DIWSTOP(a1)

	; Setup colors
	move.w  #$008,COLOR00(a1)
	move.w  #$555,COLOR01(a1)

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

	; Setup bitplane pointers
	lea     bitplanes,a2
	lea     copper,a3
	moveq	#5,d0
.bitplaneloop:
	move.l 	a2,d1
	move.w	d1,2(a3)
	swap	d1
	move.w  d1,6(a3)
	addq	#8,a3
	dbra	d0,.bitplaneloop

	; Setup bitplane data
	lea bitplanes,a0 
	move.w #2048,d0
.loop:
	move.l #$AAAAAAAA,(a0)+
	dbra d0,.loop
	
	; Install copper list
	lea		copper,a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #$8003,COPCON(a1)   ; Allow Copper to write Blitter registers

	; Enable DMA
	move.w	#$8040,DMACON(a1)   ; Blitter DMA 	
	move.w  #$8080,DMACON(a1)   ; Copper DMA
	move.w  #$8020,DMACON(a1)   ; Sprite DMA
	move.w  #$8100,DMACON(a1)   ; Bitplane DMA
	move.w  #$8200,DMACON(a1)   ; DMA enable
	move.w	#$8400,DMACON(a1)   ; BlitPri = 1 

	; Enable interrupts
	move.w	#$C02C,INTENA(a1)
;
; Main loop
;

mainLoop: 

	jsr     prepareblit

synccpu:
	lea     VHPOSR(a1),a3     ; VHPOSR     

	; Wait until we have reached the middle of a frame
.loop 
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$3000,d2
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
  	moveq #10,d2
.adjust:
    dbra d2,.adjust

	; Sync vertically
.synccpu4:
	nop 
	move.w  #$404,COLOR00(a1)
	ds.w    96,$4E71          ; NOPs to keep the horizontal position in each iteration
	move.w  (a3),d2     
	move.w  #$F0F,COLOR00(a1)  
	and     #$FF00,d2
	cmp.w   #$4000,d2
	bne     .synccpu4
	move.w  #$000,COLOR00(a1)  

cpuwait:
	bra     mainLoop

irq1:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	move.w  #$F44,COLOR00(a1)
	; move.w  #SPRDMAON,DMACON(a1)
	move.w  #$000,COLOR00(a1)
	rte

irq2:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	move.w  #$4F4,COLOR00(a1)
	; move.w  #SPRDMAOFF,DMACON(a1)
	move.w  #$000,COLOR00(a1)
	rte
	
irq3:
	movem.l	d0-a6,-(sp)

	move.w  #$0020,INTREQ(a1)   ; Acknowledge
	move.w  #$000,COLOR00(a1)

	; Reset bitplane pointers
	lea     bitplanes,a2
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

prepareblit:	
	movem.l d0-a6,-(sp)
	bsr     blitWait

	; Prepare the copy Blitter
	move.w  #$004,COLOR00(a1)
	move.w  #BLIT_BLTCON0,BLTCON0(a1)
	move.w  #BLIT_BLTCON1,BLTCON1(a1) 
	move.l  #$ffffffff,BLTAFWM(a1)   
	move.w  #0,BLTAMOD(a1)
	move.w  #0,BLTBMOD(a1)
	move.w  #0,BLTCMOD(a1)
	move.w  #0,BLTDMOD(a1)
	move.l  #spare,BLTAPTH(a1)	 
	move.l  #spare,BLTBPTH(a1)	
	move.l  #spare,BLTCPTH(a1)
	move.l  #spare,BLTDPTH(a1)
	movem.l (sp)+,d0-a6
	rts

blitWait:
	tst DMACONR(a1)		;for compatibility
.waitblit:
	btst #6,DMACONR(a1)
	bne.s .waitblit
	rts

	;
	;  Sprite data 
	;

SPRITE0:
			DC.W    $5DB5,$7D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $5DB9,$7D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $5DBD,$7D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $5DC1,$7D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $5DC5,$7D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $5DC9,$7D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $5DCD,$7D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $5DD1,$7D00 ;VSTART, HSTART, VSTOP
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
	dc.w    BPLCON0,$0200

	dc.w    $5D39,$FFFE    ; WAIT
	RULER
	dc.w    $5E01,$FFFE    ; WAIT
	dc.w    BPLCON0,$1200 
	

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000

	dc.w	$6201,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w	$6201,$FFFE  ; WAIT 
	dc.w    DMACON,$0020 ; DMA OFF
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	dc.w    DMACON,$8020 ; DMA ON

	dc.w	$6401,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w	$6403,$FFFE  ; WAIT 
	dc.w    DMACON,$0020 ; DMA OFF
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	dc.w    DMACON,$8020 ; DMA ON

	dc.w	$6601,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w	$6605,$FFFE  ; WAIT 
	dc.w    DMACON,$0020 ; DMA OFF
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	dc.w    DMACON,$8020 ; DMA ON

	dc.w	$6801,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w	$6807,$FFFE  ; WAIT 
	dc.w    DMACON,$0020 ; DMA OFF
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	dc.w    DMACON,$8020 ; DMA ON

	dc.w	$6A01,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w	$6A09,$FFFE  ; WAIT 
	dc.w    DMACON,$0020 ; DMA OFF
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	dc.w    DMACON,$8020 ; DMA ON

	dc.w	$6C01,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w	$6C0B,$FFFE  ; WAIT 
	dc.w    DMACON,$0020 ; DMA OFF
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	dc.w    DMACON,$8020 ; DMA ON

	dc.w	$6E01,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w	$6E0D,$FFFE  ; WAIT 
	dc.w    DMACON,$0020 ; DMA OFF
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	dc.w    DMACON,$8020 ; DMA ON

	dc.w	$7001,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w	$700F,$FFFE  ; WAIT 
	dc.w    DMACON,$0020 ; DMA OFF
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	dc.w    DMACON,$8020 ; DMA ON

	dc.w	$7201,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w	$7211,$FFFE  ; WAIT 
	dc.w    DMACON,$0020 ; DMA OFF
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	dc.w    DMACON,$8020 ; DMA ON

	dc.w	$7401,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w	$7413,$FFFE  ; WAIT 
	dc.w    DMACON,$0020 ; DMA OFF
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	dc.w    DMACON,$8020 ; DMA ON

	dc.w	$7601,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w	$7615,$FFFE  ; WAIT 
	dc.w    DMACON,$0020 ; DMA OFF
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	dc.w    DMACON,$8020 ; DMA ON

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w	$7817,$FFFE  ; WAIT 
	dc.w    DMACON,$0020 ; DMA OFF
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	dc.w    DMACON,$8020 ; DMA ON

	dc.w	$7A01,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w	$7A19,$FFFE  ; WAIT 
	dc.w    DMACON,$0020 ; DMA OFF
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	dc.w    DMACON,$8020 ; DMA ON

	dc.w	$7C01,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w	$7C1B,$FFFE  ; WAIT 
	dc.w    DMACON,$0020 ; DMA OFF
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	dc.w    DMACON,$8020 ; DMA ON

	dc.w	$ffdf,$fffe    ; Cross vertical boundary
	dc.w    COLOR00, $000
	dc.w    BPLCON0,$0200

	dc.l	$fffffffe

spare:
	ds.b    512,$00
bitplanes:
	ds.b 	61440,$00
