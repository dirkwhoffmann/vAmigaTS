	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
BASE                equ $38
SCROLL              equ $AA

entry:	
	lea 	CUSTOM,a1

	; Install interrupt handler
	lea	level3InterruptHandler(pc),a3
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

	;; install copper list and enable DMA
	lea 	CUSTOM,a1
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	
.mainLoop:
	bra.b	.mainLoop

level3InterruptHandler:

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
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
    ; 
	; Block 1 (LORES)
	;

	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(1<<12)|$200 ; 1 bitplanes, lores mode
	dc.w    COLOR01,$66F
	dc.w    BPLCON1,$00
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$3601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$36D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $3961,$FFFE  ; Scroll
	dc.w    BPLCON1,$88
	dc.w    BPLCON1,$99
	dc.w    BPLCON1,$AA
	dc.w    BPLCON1,$BB
	dc.w    BPLCON1,$CC
	dc.w    BPLCON1,$DD
	dc.w    BPLCON1,$EE
	dc.w    BPLCON1,$FF

	dc.w	$3C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$3CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $3F63,$FFFE  ; Scroll
	dc.w    BPLCON1,$88
	dc.w    BPLCON1,$99
	dc.w    BPLCON1,$AA
	dc.w    BPLCON1,$BB
	dc.w    BPLCON1,$CC
	dc.w    BPLCON1,$DD
	dc.w    BPLCON1,$EE
	dc.w    BPLCON1,$FF

	dc.w	$4201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$42D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $4565,$FFFE  ; Scroll
	dc.w    BPLCON1,$88
	dc.w    BPLCON1,$99
	dc.w    BPLCON1,$AA
	dc.w    BPLCON1,$BB
	dc.w    BPLCON1,$CC
	dc.w    BPLCON1,$DD
	dc.w    BPLCON1,$EE
	dc.w    BPLCON1,$FF

 	; 
	; Block 2 (LORES)
	;

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$B6F
	dc.w    BPLCON1,$00
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $4B67,$FFFE  ; Scroll
	dc.w    BPLCON1,$88
	dc.w    BPLCON1,$99
	dc.w    BPLCON1,$AA
	dc.w    BPLCON1,$BB
	dc.w    BPLCON1,$CC
	dc.w    BPLCON1,$DD
	dc.w    BPLCON1,$EE
	dc.w    BPLCON1,$FF

	dc.w	$4E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$4ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $5169,$FFFE  ; Scroll
	dc.w    BPLCON1,$88
	dc.w    BPLCON1,$99
	dc.w    BPLCON1,$AA
	dc.w    BPLCON1,$BB
	dc.w    BPLCON1,$CC
	dc.w    BPLCON1,$DD
	dc.w    BPLCON1,$EE
	dc.w    BPLCON1,$FF

	dc.w	$5401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$54D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $576B,$FFFE  ; Scroll
	dc.w    BPLCON1,$88
	dc.w    BPLCON1,$99
	dc.w    BPLCON1,$AA
	dc.w    BPLCON1,$BB
	dc.w    BPLCON1,$CC
	dc.w    BPLCON1,$DD
	dc.w    BPLCON1,$EE
	dc.w    BPLCON1,$FF

	dc.w	$5A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$5AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $5D6D,$FFFE  ; Scroll
	dc.w    BPLCON1,$88
	dc.w    BPLCON1,$99
	dc.w    BPLCON1,$AA
	dc.w    BPLCON1,$BB
	dc.w    BPLCON1,$CC
	dc.w    BPLCON1,$DD
	dc.w    BPLCON1,$EE
	dc.w    BPLCON1,$FF

	; 
	; Block 3 (LORES)
	;

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6F
	dc.w    BPLCON1,$00
	dc.w	$60D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $636F,$FFFE  ; Scroll
	dc.w    BPLCON1,$11
	dc.w    BPLCON1,$22
	dc.w    BPLCON1,$33
	dc.w    BPLCON1,$44
	dc.w    BPLCON1,$55
	dc.w    BPLCON1,$66
	dc.w    BPLCON1,$77
	dc.w    BPLCON1,$88

	dc.w	$6601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$66D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $6971,$FFFE  ; Scroll
	dc.w    BPLCON1,$11
	dc.w    BPLCON1,$22
	dc.w    BPLCON1,$33
	dc.w    BPLCON1,$44
	dc.w    BPLCON1,$55
	dc.w    BPLCON1,$66
	dc.w    BPLCON1,$77
	dc.w    BPLCON1,$88

	dc.w	$6C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$6CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $6F73,$FFFE  ; Scroll
	dc.w    BPLCON1,$11
	dc.w    BPLCON1,$22
	dc.w    BPLCON1,$33
	dc.w    BPLCON1,$44
	dc.w    BPLCON1,$55
	dc.w    BPLCON1,$66
	dc.w    BPLCON1,$77
	dc.w    BPLCON1,$88

	dc.w	$7201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$72D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w    $7575,$FFFE  ; Scroll
	dc.w    BPLCON1,$11
	dc.w    BPLCON1,$22
	dc.w    BPLCON1,$33
	dc.w    BPLCON1,$44
	dc.w    BPLCON1,$55
	dc.w    BPLCON1,$66
	dc.w    BPLCON1,$77
	dc.w    BPLCON1,$88

	; 
	; Block 4 (LORES)
	;

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6B
	dc.w    BPLCON1,$00
	dc.w	$78D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $7B77,$FFFE  ; Scroll
	dc.w    BPLCON1,$11
	dc.w    BPLCON1,$22
	dc.w    BPLCON1,$33
	dc.w    BPLCON1,$44
	dc.w    BPLCON1,$55
	dc.w    BPLCON1,$66
	dc.w    BPLCON1,$77
	dc.w    BPLCON1,$88

	dc.w	$7E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$7ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $8179,$FFFE  ; Scroll
	dc.w    BPLCON1,$11
	dc.w    BPLCON1,$22
	dc.w    BPLCON1,$33
	dc.w    BPLCON1,$44
	dc.w    BPLCON1,$55
	dc.w    BPLCON1,$66
	dc.w    BPLCON1,$77
	dc.w    BPLCON1,$88

	dc.w	$8401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$84D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $877B,$FFFE  ; Scroll 
	dc.w    BPLCON1,$11
	dc.w    BPLCON1,$22
	dc.w    BPLCON1,$33
	dc.w    BPLCON1,$44
	dc.w    BPLCON1,$55
	dc.w    BPLCON1,$66
	dc.w    BPLCON1,$77
	dc.w    BPLCON1,$88

	dc.w	$8A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$8AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w    $8D7D,$FFFE  ; Scroll
	dc.w    BPLCON1,$11
	dc.w    BPLCON1,$22
	dc.w    BPLCON1,$33
	dc.w    BPLCON1,$44
	dc.w    BPLCON1,$55
	dc.w    BPLCON1,$66
	dc.w    BPLCON1,$77
	dc.w    BPLCON1,$88

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
	dc.w    BPLCON1,$00
	dc.w	$A0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$A601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$A6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $A961,$FFFE  ; Scroll
	dc.w    BPLCON1,$88
	dc.w    BPLCON1,$99
	dc.w    BPLCON1,$AA
	dc.w    BPLCON1,$BB
	dc.w    BPLCON1,$CC
	dc.w    BPLCON1,$DD
	dc.w    BPLCON1,$EE
	dc.w    BPLCON1,$FF

	dc.w	$AC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$ACD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $AF63,$FFFE  ; Scroll
	dc.w    BPLCON1,$88
	dc.w    BPLCON1,$99
	dc.w    BPLCON1,$AA
	dc.w    BPLCON1,$BB
	dc.w    BPLCON1,$CC
	dc.w    BPLCON1,$DD
	dc.w    BPLCON1,$EE
	dc.w    BPLCON1,$FF

	dc.w	$B201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$B2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $B565,$FFFE  ; Scroll
	dc.w    BPLCON1,$88
	dc.w    BPLCON1,$99
	dc.w    BPLCON1,$AA
	dc.w    BPLCON1,$BB
	dc.w    BPLCON1,$CC
	dc.w    BPLCON1,$DD
	dc.w    BPLCON1,$EE
	dc.w    BPLCON1,$FF

 	; 
	; Block 2 (HIRES)
	;

	dc.w	$B801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$B6F
	dc.w    BPLCON1,$00
	dc.w	$B8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $BB67,$FFFE  ; Scroll
	dc.w    BPLCON1,$88
	dc.w    BPLCON1,$99
	dc.w    BPLCON1,$AA
	dc.w    BPLCON1,$BB
	dc.w    BPLCON1,$CC
	dc.w    BPLCON1,$DD
	dc.w    BPLCON1,$EE
	dc.w    BPLCON1,$FF

	dc.w	$BE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$BED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $C169,$FFFE  ; Scroll
	dc.w    BPLCON1,$88
	dc.w    BPLCON1,$99
	dc.w    BPLCON1,$AA
	dc.w    BPLCON1,$BB
	dc.w    BPLCON1,$CC
	dc.w    BPLCON1,$DD
	dc.w    BPLCON1,$EE
	dc.w    BPLCON1,$FF

	dc.w	$C401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$C4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $C76B,$FFFE  ; Scroll
	dc.w    BPLCON1,$88
	dc.w    BPLCON1,$99
	dc.w    BPLCON1,$AA
	dc.w    BPLCON1,$BB
	dc.w    BPLCON1,$CC
	dc.w    BPLCON1,$DD
	dc.w    BPLCON1,$EE
	dc.w    BPLCON1,$FF

	dc.w	$CA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$CAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $CD6D,$FFFE  ; Scroll
	dc.w    BPLCON1,$88
	dc.w    BPLCON1,$99
	dc.w    BPLCON1,$AA
	dc.w    BPLCON1,$BB
	dc.w    BPLCON1,$CC
	dc.w    BPLCON1,$DD
	dc.w    BPLCON1,$EE
	dc.w    BPLCON1,$FF

	; 
	; Block 3 (HIRES)
	;

	dc.w	$D001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6F
	dc.w    BPLCON1,$00
	dc.w	$D0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $D36F,$FFFE  ; Scroll
	dc.w    BPLCON1,$11
	dc.w    BPLCON1,$22
	dc.w    BPLCON1,$33
	dc.w    BPLCON1,$44
	dc.w    BPLCON1,$55
	dc.w    BPLCON1,$66
	dc.w    BPLCON1,$77
	dc.w    BPLCON1,$88

	dc.w	$D601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$D6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w    $D971,$FFFE  ; Scroll
	dc.w    BPLCON1,$11
	dc.w    BPLCON1,$22
	dc.w    BPLCON1,$33
	dc.w    BPLCON1,$44
	dc.w    BPLCON1,$55
	dc.w    BPLCON1,$66
	dc.w    BPLCON1,$77
	dc.w    BPLCON1,$88

	dc.w	$DC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$DCD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $DF73,$FFFE  ; Scroll
	dc.w    BPLCON1,$11
	dc.w    BPLCON1,$22
	dc.w    BPLCON1,$33
	dc.w    BPLCON1,$44
	dc.w    BPLCON1,$55
	dc.w    BPLCON1,$66
	dc.w    BPLCON1,$77
	dc.w    BPLCON1,$88

	dc.w	$E201,$FFFE  ; WAIT 
	dc.w	COLOR00,$F00
	dc.w    BPLCON1,$00
	dc.w	$E2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $E575,$FFFE  ; Scroll
	dc.w    BPLCON1,$11
	dc.w    BPLCON1,$22
	dc.w    BPLCON1,$33
	dc.w    BPLCON1,$44
	dc.w    BPLCON1,$55
	dc.w    BPLCON1,$66
	dc.w    BPLCON1,$77
	dc.w    BPLCON1,$88

	; 
	; Block 4 (HIRES)
	;

	dc.w	$E801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6B
	dc.w    BPLCON1,$00
	dc.w	$E8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $EB77,$FFFE  ; Scroll
	dc.w    BPLCON1,$11
	dc.w    BPLCON1,$22
	dc.w    BPLCON1,$33
	dc.w    BPLCON1,$44
	dc.w    BPLCON1,$55
	dc.w    BPLCON1,$66
	dc.w    BPLCON1,$77
	dc.w    BPLCON1,$88

	dc.w	$EE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$EED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $F179,$FFFE  ; Scroll
	dc.w    BPLCON1,$11
	dc.w    BPLCON1,$22
	dc.w    BPLCON1,$33
	dc.w    BPLCON1,$44
	dc.w    BPLCON1,$55
	dc.w    BPLCON1,$66
	dc.w    BPLCON1,$77
	dc.w    BPLCON1,$88

	dc.w	$F401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$F4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $F77B,$FFFE  ; Scroll 
	dc.w    BPLCON1,$11
	dc.w    BPLCON1,$22
	dc.w    BPLCON1,$33
	dc.w    BPLCON1,$44
	dc.w    BPLCON1,$55
	dc.w    BPLCON1,$66
	dc.w    BPLCON1,$77
	dc.w    BPLCON1,$88

	dc.w	$FA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON1,$00
	dc.w	$FAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $FD7D,$FFFE  ; Scroll
	dc.w    BPLCON1,$11
	dc.w    BPLCON1,$22
	dc.w    BPLCON1,$33
	dc.w    BPLCON1,$44
	dc.w    BPLCON1,$55
	dc.w    BPLCON1,$66
	dc.w    BPLCON1,$77
	dc.w    BPLCON1,$88

	dc.w	$FFDF,$FFFE  ; Cross vertical boundary

	dc.w	$0001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$00D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off
	dc.w    DDFSTRT,$0038 ; Reset normal values
	dc.w	DDFSTOP,$00B0

	dc.l	$fffffffe

bitplanes:
	ds.b    51201
	