	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
BASE                equ $38

entry:	
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

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

.checkVerticalBlank:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_VERTB,d0	
	beq.s	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; clear interrupt bit	

.resetBitplanePointers:
	lea	bitplanes(pc),a1
	lea     BPL1PTH(a5),a2
	moveq	#SCREEN_BIT_DEPTH-1,d0
.bitplaneloop:
	move.l	a1,(a2)
	lea	SCREEN_WIDTH_BYTES(a1),a1 ; bit plane data is interleaved
	addq	#4,a2
	dbra	d0,.bitplaneloop
	
.checkCopper:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_COPER,d0	
	beq.s	.interruptComplete
.copperInterrupt:
	move.w	#INTF_COPER,INTREQ(a5)	; clear interrupt bit	
	
.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte

copper:
    dc.w    DIWSTRT,$2c71 
    dc.w    DIWSTOP,$2cd1
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"out/image-copper-list.s"

	dc.w	BPLCON0,(5<<12)|$200

   ; 
	; Block 1 (LORES)
	;

	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(1<<12)|$200 ; 1 bitplanes, lores mode
	dc.w    COLOR01,$66F
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00C0
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w	$3601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00C2
	dc.w	$36D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$3C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00C4
	dc.w	$3CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00C6
	dc.w	$42D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

 	; 
	; Block 2 (LORES)
	;

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$B6F
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00C8
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00CA
	dc.w	$4ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$5401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00CC
	dc.w	$54D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$5A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00CE
	dc.w	$5AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; 
	; Block 3 (LORES)
	;

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6F
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00D0
	dc.w	$60D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$6601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00D2
	dc.w	$66D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$6C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00D4
	dc.w	$6CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$7201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00D6
	dc.w	$72D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; 
	; Block 4 (LORES)
	;

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6B
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00D8
	dc.w	$78D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$7E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00DA
	dc.w	$7ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$8401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00DC
	dc.w	$84D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$8A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00DE
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
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00C0
	dc.w	$A0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w	$A601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00C2
	dc.w	$A6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$AC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00C4
	dc.w	$ACD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$B201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00C6
	dc.w	$B2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

 	; 
	; Block 2 (HIRES)
	;

	dc.w	$B801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$B6F
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00C8
	dc.w	$B8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$BE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00CA
	dc.w	$BED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$C401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00CC
	dc.w	$C4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$CA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00CE
	dc.w	$CAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; 
	; Block 3 (HIRES)
	;

	dc.w	$D001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6F
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00D0
	dc.w	$D0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$D601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00D2
	dc.w	$D6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$DC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00D4
	dc.w	$DCD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$E201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00D6
	dc.w	$E2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; 
	; Block 4 (HIRES)
	;

	dc.w	$E801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    COLOR01,$F6B
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00D8
	dc.w	$E8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$EE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00DA
	dc.w	$EED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$F401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE 
	dc.w	DDFSTOP,$00DC
	dc.w	$F4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$FA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,BASE
	dc.w	DDFSTOP,$00DE
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
	incbin	"out/image.bin"
	