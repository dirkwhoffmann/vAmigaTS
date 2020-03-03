	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
LEFT                equ $80
RIGHT               equ $b0

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
	dc.w    DDFSTRT,LEFT
	dc.w	DDFSTOP,RIGHT
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w	$3601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$18
	dc.w	DDFSTOP,$10
	dc.w	$36D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$3C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,LEFT
	dc.w	DDFSTOP,RIGHT
	dc.w	$3CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$20
	dc.w	DDFSTOP,$18
	dc.w	$42D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

 	; 
	; Block 2 (LORES)
	;

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$B6F
	dc.w    DDFSTRT,LEFT
	dc.w	DDFSTOP,RIGHT
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$28
	dc.w	DDFSTOP,$20
	dc.w	$4ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$5401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,LEFT
	dc.w	DDFSTOP,RIGHT
	dc.w	$54D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$5A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$30 
	dc.w	DDFSTOP,$28
	dc.w	$5AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; 
	; Block 3 (LORES)
	;

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6F
	dc.w    DDFSTRT,LEFT
	dc.w	DDFSTOP,RIGHT
	dc.w	$60D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$6601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$38 
	dc.w	DDFSTOP,$30
	dc.w	$66D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$6C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,LEFT
	dc.w	DDFSTOP,RIGHT
	dc.w	$6CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$7201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$40
	dc.w	DDFSTOP,$38
	dc.w	$72D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; 
	; Block 4 (LORES)
	;

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6B
	dc.w    DDFSTRT,LEFT
	dc.w	DDFSTOP,RIGHT
	dc.w	$78D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$7E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$48
	dc.w	DDFSTOP,$40
	dc.w	$7ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$8401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,LEFT
	dc.w	DDFSTOP,RIGHT
	dc.w	$84D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$8A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$50 
	dc.w	DDFSTOP,$48
	dc.w	$8AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$9001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$90D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off

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
	dc.w    DDFSTRT,LEFT 
	dc.w	DDFSTOP,RIGHT
	dc.w	$A0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w	$A601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$18 
	dc.w	DDFSTOP,$10
	dc.w	$A6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$AC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,LEFT 
	dc.w	DDFSTOP,RIGHT
	dc.w	$ACD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$B201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$20 
	dc.w	DDFSTOP,$18
	dc.w	$B2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

 	; 
	; Block 2 (HIRES)
	;

	dc.w	$B801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$B6F
	dc.w    DDFSTRT,LEFT
	dc.w	DDFSTOP,RIGHT
	dc.w	$B8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$BE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$28
	dc.w	DDFSTOP,$20
	dc.w	$BED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$C401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,LEFT
	dc.w	DDFSTOP,RIGHT
	dc.w	$C4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$CA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$30
	dc.w	DDFSTOP,$28
	dc.w	$CAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; 
	; Block 3 (HIRES)
	;

	dc.w	$D001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6F
	dc.w    DDFSTRT,LEFT
	dc.w	DDFSTOP,RIGHT
	dc.w	$D0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$D601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$38
	dc.w	DDFSTOP,$30
	dc.w	$D6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$DC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,LEFT
	dc.w	DDFSTOP,RIGHT
	dc.w	$DCD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$E201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$40
	dc.w	DDFSTOP,$38
	dc.w	$E2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; 
	; Block 4 (HIRES)
	;

	dc.w	$E801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6B
	dc.w    DDFSTRT,LEFT
	dc.w	DDFSTOP,RIGHT
	dc.w	$E8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$EE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$48
	dc.w	DDFSTOP,$40
	dc.w	$EED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$F401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,LEFT
	dc.w	DDFSTOP,RIGHT
	dc.w	$F4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$FA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$50
	dc.w	DDFSTOP,$48
	dc.w	$FAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$FFDF,$FFFE  ; Cross vertical boundary

	dc.w	$0001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$00D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off
	dc.w    DDFSTRT,$0038 ; Reset normal values
	dc.w	DDFSTOP,$00D0

	dc.l	$fffffffe

bitplanes:
	ds.b    51201
	