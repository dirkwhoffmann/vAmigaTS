	include "../../../include/registers.i"
	include "../../../include/ministartup.i"
	include "../../../include/util.i"

LENGTH		equ $1602
BLTCON1_1   equ $0051
BLTCON1_2   equ $2051
BLTCON1_3   equ $4051
BLTCON1_4   equ $6051
BLTCON1_5   equ $8051
BLTCON1_6   equ $A051
BLTCON1_7   equ $C051
BLTCON1_8   equ $D051
PATTERN1    equ $00FF
PATTERN2    equ $00FF
PATTERN3    equ $00FF
PATTERN4    equ $00FF
PATTERN5    equ $00FF
PATTERN6    equ $00FF
PATTERN7    equ $00FF
PATTERN8    equ $00FF

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
	move.l  #bitplanes+$60*40+12,BLTCPTH(a1)
	move.l  #bitplanes+$60*40+12,BLTDPTH(a1)
	move.w  #PATTERN1,BLTBDAT(a1)
	move.w  #LENGTH,BLTSIZE(a1)

    ; Blit 2
	bsr     prepareblit
	; Use BLTCON1 as it was left by the previous blit
	move.l  #bitplanes+$62*40+12,BLTCPTH(a1)
	move.l  #bitplanes+$62*40+12,BLTDPTH(a1)
	move.w  #PATTERN2,BLTBDAT(a1)
	move.w  #LENGTH,BLTSIZE(a1)

    ; Blit 3
	bsr     prepareblit
	; Use BLTCON1 as it was left by the previous blit
	move.l  #bitplanes+$64*40+12,BLTCPTH(a1)
	move.l  #bitplanes+$64*40+12,BLTDPTH(a1)
	move.w  #PATTERN3,BLTBDAT(a1)
	move.w  #LENGTH,BLTSIZE(a1)

    ; Blit 4
	bsr     prepareblit
	; Use BLTCON1 as it was left by the previous blit
	move.l  #bitplanes+$66*40+12,BLTCPTH(a1)
	move.l  #bitplanes+$66*40+12,BLTDPTH(a1)
	move.w  #PATTERN4,BLTBDAT(a1)
	move.w  #LENGTH,BLTSIZE(a1)

    ; Blit 5
	bsr     prepareblit
	; Use BLTCON1 as it was left by the previous blit
	move.l  #bitplanes+$68*40+12,BLTCPTH(a1)
	move.l  #bitplanes+$68*40+12,BLTDPTH(a1)
	move.w  #PATTERN5,BLTBDAT(a1)
	move.w  #LENGTH,BLTSIZE(a1)

    ; Blit 6
	bsr     prepareblit
	; Use BLTCON1 as it was left by the previous blit
	move.l  #bitplanes+$6A*40+12,BLTCPTH(a1)
	move.l  #bitplanes+$6A*40+12,BLTDPTH(a1)
	move.w  #PATTERN6,BLTBDAT(a1)
	move.w  #LENGTH,BLTSIZE(a1)

    ; Blit 7
	bsr     prepareblit
	; Use BLTCON1 as it was left by the previous blit
	move.l  #bitplanes+$6C*40+12,BLTCPTH(a1)
	move.l  #bitplanes+$6C*40+12,BLTDPTH(a1)
	move.w  #PATTERN7,BLTBDAT(a1)
	move.w  #LENGTH,BLTSIZE(a1)

    ; Blit 8
	bsr     prepareblit
	; Use BLTCON1 as it was left by the previous blit
	move.l  #bitplanes+$6E*40+12,BLTCPTH(a1)
	move.l  #bitplanes+$6E*40+12,BLTDPTH(a1)
	move.w  #PATTERN8,BLTBDAT(a1)
	move.w  #LENGTH,BLTSIZE(a1)
	rts

prepareblit:
	bsr     blitWait
	move.w  #40,BLTCMOD(a1)
	move.w  #40,BLTDMOD(a1)
	move.w  #-100,BLTAPTL(a1)
	move.w  #-200,BLTAMOD(a1)
	move.w  #0,BLTBMOD(a1)
	move.w  #$ABCA,BLTCON0(a1)
	move.w  #$8000,BLTADAT(a1)
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

	dc.w    $7839, $FFFE         ; WAIT
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
	