	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5

BPL1DAT             equ $110
BPL2DAT             equ $112
BPL3DAT             equ $114
BPL4DAT             equ $116
BPL5DAT             equ $118
BPL6DAT             equ $11A

MAIN:	
	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable interrupts and DMA
	move.b  #$7F,$BFDD00        ; CIA B
	move.b  #$7F,$BFED01        ; CIA A
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)

	; Disable all bitplanes 
	move.w  #$200,BPLCON0(a1)

	; Install interrupt handler
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	
	; Setup bitplane data
	moveq  #0,d0
	lea    bitplanes,a2 
	move.w #51200,d0
.loop:
	move.b #$CC,(a2)+
	dbra d0,.loop

	; Setup colors
	move.w #$000,COLOR00(a1)
	move.w #$FF0,COLOR01(a1)

	; Install copper list and enable DMA
	lea 	CUSTOM,a1
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	
	; Enable innterrupts
	move.w	#$C020,INTENA(a1) 

.mainLoop:
	bra.b	.mainLoop

level3InterruptHandler:

	movem.l	d0-a6,-(sp)
	lea 	CUSTOM,a1
	move.w	#$3FFF,INTREQ(a1)	; Acknowledge
	lea     bitplanes,a2 
	move.l  a2,BPL1PTH(a1)
	move.l  a2,BPL2PTH(a1)
	move.l  a2,BPL3PTH(a1)
	move.l  a2,BPL4PTH(a1)
	move.l  a2,BPL5PTH(a1)
	move.l  a2,BPL6PTH(a1)
	movem.l	(sp)+,d0-a6
	rte

copper:
	dc.w    DIWSTRT,$2c71 
	dc.w	DIWSTOP,$2cd1
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	dc.w    DDFSTRT,$0038
	dc.w	DDFSTOP,$00C0

	include "colors.s"

	dc.w    COLOR15,$00F
	dc.w    COLOR16,$FF0
	dc.w    COLOR31,$F00

    ; 
	; Block 1 (LORES)
	;

	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(7<<12)|$200 ; 7 bitplanes (invalid value), lores mode
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w    BPL5DAT,$0000

	dc.w	$3601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$36D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    BPL6DAT,$0000

	dc.w	$3C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$3CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$42D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

 	; 
	; Block 2 (LORES)
	;

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    BPL5DAT,$FFFF

	dc.w	$4E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$4ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    BPL6DAT,$0000

	dc.w	$5401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$54D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$5A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$5AD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; 
	; Block 3 (LORES)
	;

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$60D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    BPL5DAT,$0000

	dc.w	$6601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$66D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    BPL6DAT,$FFFF

	dc.w	$6C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$6CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$7201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$72D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; 
	; Block 4 (LORES)
	;

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$78D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    BPL5DAT,$FFFF

	dc.w	$7E01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$7ED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    BPL6DAT,$FFFF

	dc.w	$8401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$84D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$8A01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
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
	dc.w	BPLCON0,(7<<12)|$8200 ; 7 bitplanes (invalid value), hires mode
	dc.w	$A0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w    BPL5DAT,$0000

	dc.w	$A601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    BPL6DAT,$0000

	dc.w	$AC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$ACD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$B201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$B2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

 	; 
	; Block 2 (HIRES)
	;

	dc.w	$B801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$B8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    BPL5DAT,$FFFF

	dc.w	$BE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$BED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    BPL6DAT,$FFFF

	dc.w	$C401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$C4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$CA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$CAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; 
	; Block 3 (HIRES)
	;

	dc.w	$D001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$D0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    BPL5DAT,$0000

	dc.w	$D601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$D6D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    BPL6DAT,$FFFF

	dc.w	$DC01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$DCD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$E201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$E2D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	; 
	; Block 4 (HIRES)
	;

	dc.w	$E801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$E8D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    BPL5DAT,$FFFF

	dc.w	$EE01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$EED9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    BPL6DAT,$FFFF

	dc.w	$F401,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$F4D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$FA01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$FAD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$FFDF,$FFFE  ; Cross vertical boundary

	dc.w	$0001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$00D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off

	dc.l	$fffffffe

bitplanes:
	ds.b    51201
	
