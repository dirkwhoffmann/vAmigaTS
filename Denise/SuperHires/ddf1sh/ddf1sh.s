	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
BASE                equ $38

entry:	
	lea 	CUSTOM,a1

	; Install interrupt handler
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	
	; Setup bitplane data
	lea bitplanes1,a0 
	move.w #14000,d0
.loop1:
	move.w #$FF00,(a0)+
	dbra d0,.loop1

	lea bitplanes2,a0 
	move.w #14000,d0
.loop2:
	move.w #$0FF0,(a0)+
	dbra d0,.loop2

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
	lea     bitplanes1,a2
	lea     BPL1PTH(a1),a3
	move.l	a2,(a3)
	lea     bitplanes2,a2
	lea     BPL2PTH(a1),a3
	move.l	a2,(a3)
	movem.l	(sp)+,d0-a6
	rte

copper:
	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPL1MOD,0
	dc.w	BPL2MOD,0
 	include "../shrscolors.i"

    ; 
	; Block 1 (LORES)
	;

	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(1<<12)|$200 ; 1 bitplanes, lores mode
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00B0
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA
	
	dc.w	$3601,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00B2
	dc.w	$36D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$3C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00B4
	dc.w	$3CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$4201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00B6
	dc.w	$42D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

 	; 
	; Block 2 (LORES)
	;

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(1<<12)|$240 ; 1 bitplanes, super-hires mode
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00B8
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$4E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00BA
	dc.w	$4ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$5401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00BC
	dc.w	$54D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$5A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00BE
	dc.w	$5AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	; 
	; Block 3 (LORES)
	;

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00C0
	dc.w	$60D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$6601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00C2
	dc.w	$66D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$6C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00C4
	dc.w	$6CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$7201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00C6
	dc.w	$72D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	; 
	; Block 4 (LORES)
	;

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(1<<12)|$200 ; 1 bitplanes, lores mode
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00C8
	dc.w	$78D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$7E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00CA
	dc.w	$7ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$8401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00CC
	dc.w	$84D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$8A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00CE
	dc.w	$8AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$9001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$90D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA
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
	dc.w    COLOR00,$AAA

    ; 
	; Block 1 (HIRES)
	;

	dc.w	$A001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(1<<12)|$8200 ; 1 bitplanes, hires mode
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00B0
	dc.w	$A0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA
	
	dc.w	$A601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00B2
	dc.w	$A6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$AC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00B4
	dc.w	$ACD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$B201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00B6
	dc.w	$B2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

 	; 
	; Block 2 (HIRES)
	;

	dc.w	$B801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(1<<12)|$240 ; 1 bitplanes, super-hires mode
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00B8
	dc.w	$B8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$BE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00BA
	dc.w	$BED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$C401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00BC
	dc.w	$C4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$CA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00BE
	dc.w	$CAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	; 
	; Block 3 (HIRES)
	;

	dc.w	$D001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00C0
	dc.w	$D0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$D601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00C2
	dc.w	$D6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$DC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00C4
	dc.w	$DCD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$E201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00C6
	dc.w	$E2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	; 
	; Block 4 (HIRES)
	;

	dc.w	$E801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(1<<12)|$8200 ; 1 bitplanes, hires mode
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00C8
	dc.w	$E8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$EE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00CA
	dc.w	$EED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$F401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00CC
	dc.w	$F4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$FA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00CE
	dc.w	$FAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	$FFDF,$FFFE  ; Cross vertical boundary

	dc.w	$0001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$00D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $AAA

	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off
	dc.w    DDFSTRT,$0038 ; Reset normal values
	dc.w	DDFSTOP,$00D0

	dc.l	$fffffffe

bitplanes1:
	ds.b    28002
bitplanes2:
	ds.b    28002
	