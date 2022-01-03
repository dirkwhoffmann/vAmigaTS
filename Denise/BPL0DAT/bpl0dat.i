	include "../../../include/registers.i"
	include "../../../include/ministartup.i"

BPL0DAT 	equ    	$110
BPL1DAT 	equ    	$112
BPL2DAT 	equ    	$114
BPL3DAT 	equ    	$116
BPL4DAT 	equ    	$118
BPL5DAT 	equ    	$11A
NOOP    	equ    	$1FE
PATTERN 	equ    	$CCCC
ANTIPATTERN	equ		$3333

MAIN:
	; Load OCS base address
	lea     CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00
	move.b  #$7F,$BFED01

	; Setup colors
	move.w  #$000,COLOR00(a1)
	move.w  #$0FF,COLOR01(a1)
	move.w  #$F33,COLOR02(a1)
	move.w  #$44F,COLOR03(a1)
	move.w  #$FFF,COLOR04(a1)

	; Setup Copper
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8200,DMACON(a1)   ; DMAEN 

.mainLoop:
	bra.s	.mainLoop

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
	dc.w    DDFSTRT,$38
	dc.w    DDFSTOP,$D0
	dc.w    DIWSTRT,$2C81
	dc.w    DIWSTOP,$F4C1
	dc.w    BPLCON0,(0<<12)|$200
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0000
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000
	dc.w    BPL1DAT,PATTERN
	dc.w    BPL2DAT,ANTIPATTERN
	dc.w    BPL3DAT,$0000
	dc.w    BPL4DAT,$0000
	dc.w    BPL5DAT,$0000
	dc.w    COLOR00,$000
	
	;
	; Ruler
	; 

  	dc.w    $4039, $FFFE
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$000
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$00F
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

	;
	; 
	; 

  	dc.w    $4239, $FFFE
	dc.w    BPLCON1,SHIFT1
	dc.w    BPLCON0,BLTCON0_1
	dc.w    NOOP,0
	dc.w    NOOP,0
	dc.w    BPL0DAT,PATTERN
	dc.w    BPLCON0,BLTCON0_2

  	dc.w    $4439, $FFFE
	dc.w    BPLCON1,SHIFT2
	dc.w    BPLCON0,BLTCON0_1
	dc.w    NOOP,0
	dc.w    NOOP,0
	dc.w    BPL0DAT,PATTERN
	dc.w    BPLCON0,BLTCON0_2

  	dc.w    $4639, $FFFE
	dc.w    BPLCON1,SHIFT3
	dc.w    BPLCON0,BLTCON0_1
	dc.w    NOOP,0
	dc.w    NOOP,0
	dc.w    BPL0DAT,PATTERN
	dc.w    BPLCON0,BLTCON0_2

  	dc.w    $4839, $FFFE
	dc.w    BPLCON1,SHIFT4
	dc.w    BPLCON0,BLTCON0_1
	dc.w    NOOP,0
	dc.w    NOOP,0
	dc.w    BPL0DAT,PATTERN
	dc.w    BPLCON0,BLTCON0_2

  	dc.w    $4A39, $FFFE
	dc.w    BPLCON1,SHIFT5
	dc.w    BPLCON0,BLTCON0_1
	dc.w    NOOP,0
	dc.w    NOOP,0
	dc.w    BPL0DAT,PATTERN
	dc.w    BPLCON0,BLTCON0_2

 	dc.w    $4C39, $FFFE
	dc.w    BPLCON1,SHIFT6
	dc.w    BPLCON0,BLTCON0_1
	dc.w    NOOP,0
	dc.w    NOOP,0
	dc.w    BPL0DAT,PATTERN
	dc.w    BPLCON0,BLTCON0_2

	dc.w    $4E39, $FFFE
	dc.w    BPLCON1,SHIFT7
	dc.w    BPLCON0,BLTCON0_1
	dc.w    NOOP,0
	dc.w    NOOP,0
	dc.w    BPL0DAT,PATTERN
	dc.w    BPLCON0,BLTCON0_2

 	dc.w    $5039, $FFFE
	dc.w    BPLCON1,SHIFT8
	dc.w    BPLCON0,BLTCON0_1
	dc.w    NOOP,0
	dc.w    NOOP,0
	dc.w    BPL0DAT,PATTERN
	dc.w    BPLCON0,BLTCON0_2

  	dc.w    $5239, $FFFE
	dc.w    BPLCON1,SHIFT9
	dc.w    BPLCON0,BLTCON0_1
	dc.w    NOOP,0
	dc.w    NOOP,0
	dc.w    BPL0DAT,PATTERN
	dc.w    BPLCON0,BLTCON0_2

  	dc.w    $5439, $FFFE
	dc.w    BPLCON1,SHIFT10
	dc.w    BPLCON0,BLTCON0_1
	dc.w    NOOP,0
	dc.w    NOOP,0
	dc.w    BPL0DAT,PATTERN
	dc.w    BPLCON0,BLTCON0_2

  	dc.w    $5639, $FFFE
	dc.w    BPLCON1,SHIFT11
	dc.w    BPLCON0,BLTCON0_1
	dc.w    NOOP,0
	dc.w    NOOP,0
	dc.w    BPL0DAT,PATTERN
	dc.w    BPLCON0,BLTCON0_2

  	dc.w    $5839, $FFFE
	dc.w    BPLCON1,SHIFT12
	dc.w    BPLCON0,BLTCON0_1
	dc.w    NOOP,0
	dc.w    NOOP,0
	dc.w    BPL0DAT,PATTERN
	dc.w    BPLCON0,BLTCON0_2

 	dc.w    $5A39, $FFFE
	dc.w    BPLCON1,SHIFT13
	dc.w    BPLCON0,BLTCON0_1
	dc.w    NOOP,0
	dc.w    NOOP,0
	dc.w    BPL0DAT,PATTERN
	dc.w    BPLCON0,BLTCON0_2

	dc.w    $5C39, $FFFE
	dc.w    BPLCON1,SHIFT14
	dc.w    BPLCON0,BLTCON0_1
	dc.w    NOOP,0
	dc.w    NOOP,0
	dc.w    BPL0DAT,PATTERN
	dc.w    BPLCON0,BLTCON0_2

	dc.w    $5E39, $FFFE
	dc.w    BPLCON1,SHIFT15
	dc.w    BPLCON0,BLTCON0_1
	dc.w    NOOP,0
	dc.w    NOOP,0
	dc.w    BPL0DAT,PATTERN
	dc.w    BPLCON0,BLTCON0_2

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.l    $fffffffe
