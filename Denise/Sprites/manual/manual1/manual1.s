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

	; Setup playfield
	move.w  #$1200,BPLCON0(a1) ; 1 bitplane
	move.w  #$0000,BPL1MOD(a1) 
	move.w  #$0000,BPLCON1(a1) ; No scroll
	move.w  #$0024,BPLCON2(a1) ; Sprites have priority over playfields
	move.w  #$0038,DDFSTRT(a1)
	move.w  #$00D0,DDFSTOP(a1)
	move.w  #$2C81,DIWSTRT(a1) 
	move.w  #$F4C1,DIWSTOP(a1)

	; Set up colors
	MOVE.W  #$0008,COLOR00(a1)
	MOVE.W  #$0000,COLOR01(a1)
	MOVE.W  #$0FF0,COLOR17(a1)
	MOVE.W  #$00FF,COLOR18(a1)
	MOVE.W  #$0F0F,COLOR19(a1)
	MOVE.W  #$0FFF,COLOR21(a1)
	MOVE.W  #$088F,COLOR22(a1)
	MOVE.W  #$0F88,COLOR23(a1)

	; Install Copper list
	lea    	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable Copper and bitplane DMA
	move.w  #$8100,DMACON(a1) ; Bitplane DMA
	move.w  #$8080,DMACON(a1) ; Copper DMA
	move.w  #$8200,DMACON(a1) ; DMA enable
	
	; Enable interrupts
	move.w	#$C020,INTENA(a1) 

.mainLoop:
	bra.s .mainLoop

irq3:
	movem.l	d0-a6,-(sp)
	move.w  #$0020,INTREQ(a1)   ; Acknowledge
	move.w  #$000,COLOR00(a1)

	; Reset bitplane pointers
	lea     bitplanes(pc),a2
	move.l	a2,BPL1PTH(a1)

	movem.l	(sp)+,d0-a6
	rte

;
; Copper list
;

copper:

	dc.w    SPR0POS,$4D60
	dc.w    SPR1POS,$2D80
	dc.w    SPR2POS,$2DA0
	dc.w    SPR3POS,$00C0
	dc.w    SPR0CTL,$B100
	dc.w    SPR1CTL,$0000

	dc.w	$7101,$FFFE  ; WAIT 
	dc.w    SPR0DATA,$0990
	dc.w    SPR0DATB,$07E0
	dc.w    SPR1DATA,$0990
	dc.w    SPR1DATB,$07E0
	dc.w    SPR2DATA,$0990
	dc.w    SPR2DATB,$07E0
	dc.w    SPR3DATA,$0990
	dc.w    SPR3DATB,$07E0
	dc.w	$7201,$FFFE  ; WAIT 
	dc.w    SPR0DATA,$13C8
	dc.w    SPR0DATB,$0FF0
	dc.w    SPR1DATA,$13C8
	dc.w    SPR1DATB,$0FF0
	dc.w    SPR2DATA,$13C8
	dc.w    SPR2DATB,$0FF0
	dc.w    SPR3DATA,$13C8
	dc.w    SPR3DATB,$0FF0
	dc.w	$7301,$FFFE  ; WAIT 
	dc.w    SPR0DATA,$23C4
	dc.w    SPR0DATB,$1FF8
	dc.w    SPR1DATA,$23C4
	dc.w    SPR1DATB,$1FF8
	dc.w    SPR2DATA,$23C4
	dc.w    SPR2DATB,$1FF8
	dc.w    SPR3DATA,$23C4
	dc.w    SPR3DATB,$1FF8
	dc.w	$7401,$FFFE  ; WAIT 
	dc.w    SPR0DATA,$13C8
	dc.w    SPR0DATB,$0FF0
	dc.w    SPR1DATA,$13C8
	dc.w    SPR1DATB,$0FF0
	dc.w    SPR2DATA,$13C8
	dc.w    SPR2DATB,$0FF0
	dc.w    SPR3DATA,$13C8
	dc.w    SPR3DATB,$0FF0
	dc.w	$7501,$FFFE  ; WAIT 
	dc.w    SPR0DATA,$0990
	dc.w    SPR0DATB,$07E0
	dc.w    SPR1DATA,$0990
	dc.w    SPR1DATB,$07E0
	dc.w    SPR2DATA,$0990
	dc.w    SPR2DATB,$07E0
	dc.w    SPR3DATA,$0990
	dc.w    SPR3DATB,$07E0
	dc.w    COLOR00,$222

	dc.w	$C501,$FFFE  ; WAIT 
	dc.w    SPR1POS,$2D80
	dc.w    COLOR00,$444
	dc.w	$E501,$FFFE  ; WAIT 
	dc.w    SPR3POS,$FFFF
	dc.w    COLOR00,$666

	dc.w    $FFFF,$FFFE

bitplanes:
	ds.b    51201