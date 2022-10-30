	include "../../../include/registers.i"
	; include "../../../include/ministartup.i"
	
LVL3_INT_VECTOR		equ $6c	
FETCH_START         equ $38
FETCH_STOP          equ $D8

MAIN:	
	lea 	CUSTOM,a1

	; Install interrupt handler
	lea	irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	
	; Setup bitplane data
	lea bitplanes(pc),a0 
	move.w #51201,d0
.loop:
	move.b #$AA,(a0)+
	dbra d0,.loop

	; Setup colors
	move.w #$000,COLOR00(a1)
	move.w #$FF0,COLOR01(a1)

	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 

	; Enable interrupts
	move.w  #$C020,INTENA(a1)
	
.mainLoop:
	bra.b	.mainLoop

irq3:

	movem.l	d0-a6,-(sp)
	lea 	CUSTOM,a1
	move.w	#$3FFF,INTREQ(a1)	; Acknowledge
	lea     bitplanes(pc),a2
	lea     BPL1PTH(a1),a3
	move.l	a2,(a3)
	movem.l	(sp)+,d0-a6
	rte

copper:
	dc.w    BPLCON1,$0000
	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w    DDFSTRT,FETCH_START
	dc.w	DDFSTOP,FETCH_STOP
	dc.w	BPL1MOD,$0
	dc.w	BPL2MOD,$0
 
    ; 
	; Block 1 (LORES)
	;

	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(1<<12)|$200 ; 1 bitplanes, lores mode
	dc.w    COLOR01,$66F
	;dc.w    BPLCON1,$00
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$3601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$36D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $3900+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,SCROLL1

	dc.w	$3C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$3CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $3F00+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,SCROLL2

	dc.w	$4201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$42D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $4500+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,SCROLL3

 	; 
	; Block 2 (LORES)
	;

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$B6F
	;dc.w    BPLCON1,$00
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $4B00+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,SCROLL4

	dc.w	$4E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$4ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $5100+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,SCROLL5

	dc.w	$5401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$54D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $5700+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,SCROLL6

	dc.w	$5A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$5AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $5D00+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,SCROLL7

	; 
	; Block 3 (LORES)
	;

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6F
	;dc.w    BPLCON1,$00
	dc.w	$60D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $6300+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,SCROLL8

	dc.w	$6601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$66D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $6900+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,SCROLL9

	dc.w	$6C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$6CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $6F00+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,SCROLL10

	dc.w	$7201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$72D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w    $7500+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,SCROLL11

	; 
	; Block 4 (LORES)
	;

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6B
	;dc.w    BPLCON1,$00
	dc.w	$78D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $7B00+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,SCROLL12

	dc.w	$7E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$7ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $8100+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,SCROLL13

	dc.w	$8401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$84D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $8700+TRIGGER,$FFFE  ; Scroll 
	dc.w    BPLCON1,SCROLL14

	dc.w	$8A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$8AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w    $8D00+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,SCROLL15

	dc.w	$9001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$90D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off
	dc.w    BPLCON1,$00

	;
	; HIRES
	;

	dc.w    $9839, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000

    ; 
	; Block 1 (HIRES)
	;

	dc.w	$A001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(1<<12)|$8200 ; 1 bitplanes, hires mode
	dc.w    COLOR01,$66F
	;dc.w    BPLCON1,$00
	dc.w	$A0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$A601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$A6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $A900+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,$11

	dc.w	$AC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$ACD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $AF00+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,$22

	dc.w	$B201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$B2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $B500+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,$33

 	; 
	; Block 2 (HIRES)
	;

	dc.w	$B801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$B6F
	;dc.w    BPLCON1,$00
	dc.w	$B8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $BB00+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,$44

	dc.w	$BE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$BED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $C100+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,$55

	dc.w	$C401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$C4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $C700+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,$66

	dc.w	$CA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$CAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $CD00+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,$77

	; 
	; Block 3 (HIRES)
	;

	dc.w	$D001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6F
	;dc.w    BPLCON1,$00
	dc.w	$D0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $D300+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,$88

	dc.w	$D601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$D6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w    $D900+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,$99

	dc.w	$DC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$DCD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $DF00+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,$AA

	dc.w	$E201,$FFFE  ; WAIT 
	dc.w	COLOR00,$F00
	;dc.w    BPLCON1,$00
	dc.w	$E2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $E500+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,$BB

	; 
	; Block 4 (HIRES)
	;

	dc.w	$E801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6B
	;dc.w    BPLCON1,$00
	dc.w	$E8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $EB00+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,$CC

	dc.w	$EE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$EED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $F100+TRIGGER,$FFFE  ; Scroll
	dc.w    BPLCON1,$DD

	dc.w	$F401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$F4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $F700+TRIGGER,$FFFE  ; Scroll 
	dc.w    BPLCON1,$EE

	dc.w	$FA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	;dc.w    BPLCON1,$00
	dc.w	$FAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $FD00+TRIGGER,$FFFE  ; Scroll
	;dc.w    BPLCON1,$FF

	dc.w	$FFDF,$FFFE  ; Cross vertical boundary

	dc.w	$0001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$00D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off

	dc.l	$fffffffe

bitplanes:
	ds.b    51201
	