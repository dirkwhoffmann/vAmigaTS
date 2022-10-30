	include "../../../include/registers.i"
	include "../../../include/ministartup.i"
	include "../../../include/util.i"

LENGTH		equ $1602
BLTCON1_1   equ $01
BLTCON1_2   equ $05
BLTCON1_3   equ $09
BLTCON1_4   equ $0D
BLTCON1_5   equ $11
BLTCON1_6   equ $15
BLTCON1_7   equ $19
BLTCON1_8   equ $1D
PATTERN     equ $AAAA

MAIN:

	; Prepare the test environment
	bsr     prepare

	; Setup bitplane pointers
	lea     bitplanes(pc),a2
	lea     copper(pc),a3
	moveq	#5,d0
.bitplaneloop:
	move.l 	a2,d1
	move.w	d1,2(a3)
	swap	d1
	move.w  d1,6(a3)
	addq	#8,a3
	dbra	d0,.bitplaneloop
	
	; Install copper list
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8040,DMACON(a1)   ; Blitter DMA 	
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 
	move.w	#$8400,DMACON(a1)   ; BlitPri = 1 

	; Run the test
	bsr     runtest

.loop:
	jmp     .loop

runtest:

    ; Blit 1
	bsr     prepareblit
	move.w  #BLTCON1_1,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)

    ; Blit 2
	bsr     prepareblit
	move.w  #BLTCON1_2,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)

    ; Blit 3
	bsr     prepareblit
	move.w  #BLTCON1_3,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)

    ; Blit 4
	bsr     prepareblit
	move.w  #BLTCON1_4,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)

    ; Blit 5
	bsr     prepareblit
	move.w  #BLTCON1_5,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)

    ; Blit 6
	bsr     prepareblit
	move.w  #BLTCON1_6,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)

    ; Blit 7
	bsr     prepareblit
	move.w  #BLTCON1_7,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)

    ; Blit 8
	bsr     prepareblit
	move.w  #BLTCON1_8,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)
	rts

prepareblit:
	bsr     blitWait
	move.l  #bitplanes+$60*40+18,BLTCPTH(a1)
	move.l  #bitplanes+$60*40+18,BLTDPTH(a1)
	move.w  #40,BLTCMOD(a1)
	move.w  #40,BLTDMOD(a1)
	move.w  #-100,BLTAPTL(a1)
	move.w  #-300,BLTAMOD(a1)
	move.w  #100,BLTBMOD(a1)
	move.w  #$ABCA,BLTCON0(a1)
	move.w  #$8000,BLTADAT(a1)
	move.w  #PATTERN,BLTBDAT(a1)
	move.l  #$FFFFFFFF,BLTAFWM(a1)
	rts

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

	dc.w	BPLCON0,(1<<12)|$200 
	dc.w    DDFSTRT,$38
	dc.w    DDFSTOP,$D0
	dc.w    COLOR01,$FFF

	dc.w    $6F39, $FFFE         ; WAIT
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
	dc.w    COLOR00,$0FF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0FF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0FF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0FF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000

	dc.w    $AF39, $FFFE         ; WAIT
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
	dc.w    COLOR00,$0FF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0FF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0FF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0FF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.l	$fffffffe

bitplanes:
	ds.b    61440,$00
	