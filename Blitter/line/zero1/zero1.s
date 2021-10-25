	include "../../../include/registers.i"
	include "../../../include/ministartup.i"
	include "../../../include/util.i"

LENGTH		equ $1602

BLTCON0_1   equ $0BCA
BLTCON0_2   equ $0BCA
BLTCON0_3   equ $0BCA 
BLTCON0_4   equ $0BCA
BLTCON0_5   equ $0BCA
BLTCON0_6   equ $0BCA
BLTCON0_7   equ $09CA    ; C off
BLTCON0_8   equ $09CA    ; C off
BLTCON0_9   equ $09CA    ; C off
BLTCON0_10  equ $09CA    ; C off
BLTCON0_11  equ $09CA    ; C off
BLTCON0_12  equ $09CA    ; C off
BLTCON1_1   equ $51     
BLTCON1_2   equ $51
BLTCON1_3   equ $51
BLTCON1_4   equ $53      ; Single dot mode
BLTCON1_5   equ $53      ; Single dot mode
BLTCON1_6   equ $53      ; Single dot mode
BLTCON1_7   equ $51
BLTCON1_8   equ $51
BLTCON1_9   equ $51
BLTCON1_10  equ $53      ; Single dot mode
BLTCON1_11  equ $53      ; Single dot mode
BLTCON1_12  equ $53      ; Single dot mode
PATTERN_1   equ $0000
PATTERN_2   equ $1000
PATTERN_3   equ $0100
PATTERN_4   equ $0000
PATTERN_5   equ $1000
PATTERN_6   equ $0100
PATTERN_7   equ $0000
PATTERN_8   equ $1000
PATTERN_9   equ $0100
PATTERN_10  equ $0000
PATTERN_11  equ $1000
PATTERN_12  equ $0100

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
	move.l  #bitplanes+$10*40+18,BLTCPTH(a1)
	move.l  #bitplanes+$10*40+18,BLTDPTH(a1)
	move.w  #PATTERN_1,BLTBDAT(a1)
	move.w  #BLTCON0_1,BLTCON0(a1)
	move.w  #BLTCON1_1,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)
	lea     color1,a2 
	bsr     checkZeroBit

    ; Blit 2
	bsr     prepareblit
	move.l  #bitplanes+$12*40+18,BLTCPTH(a1)
	move.l  #bitplanes+$12*40+18,BLTDPTH(a1)
	move.w  #PATTERN_2,BLTBDAT(a1)
	move.w  #BLTCON0_2,BLTCON0(a1)
	move.w  #BLTCON1_2,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)
	lea     color2,a2 
	bsr     checkZeroBit

    ; Blit 3
	bsr     prepareblit
	move.l  #bitplanes+$14*40+18,BLTCPTH(a1)
	move.l  #bitplanes+$14*40+18,BLTDPTH(a1)
	move.w  #PATTERN_3,BLTBDAT(a1)
	move.w  #BLTCON0_3,BLTCON0(a1)
	move.w  #BLTCON1_3,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)
	lea     color3,a2 
	bsr     checkZeroBit

    ; Blit 4
	bsr     prepareblit
	move.l  #bitplanes+$16*40+18,BLTCPTH(a1)
	move.l  #bitplanes+$16*40+18,BLTDPTH(a1)
	move.w  #PATTERN_4,BLTBDAT(a1)
	move.w  #BLTCON0_4,BLTCON0(a1)
	move.w  #BLTCON1_4,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)
	lea     color4,a2 
	bsr     checkZeroBit

    ; Blit 5
	bsr     prepareblit
	move.l  #bitplanes+$18*40+18,BLTCPTH(a1)
	move.l  #bitplanes+$18*40+18,BLTDPTH(a1)
	move.w  #PATTERN_5,BLTBDAT(a1)
	move.w  #BLTCON0_5,BLTCON0(a1)
	move.w  #BLTCON1_5,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)
	lea     color5,a2 
	bsr     checkZeroBit

    ; Blit 6
	bsr     prepareblit
	move.l  #bitplanes+$1A*40+18,BLTCPTH(a1)
	move.l  #bitplanes+$1A*40+18,BLTDPTH(a1)
	move.w  #PATTERN_6,BLTBDAT(a1)
	move.w  #BLTCON0_6,BLTCON0(a1)
	move.w  #BLTCON1_6,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)
	lea     color6,a2 
	bsr     checkZeroBit

    ; Blit 7
	bsr     prepareblit
	move.l  #bitplanes+$1C*40+18,BLTCPTH(a1)
	move.l  #bitplanes+$1C*40+18,BLTDPTH(a1)
	move.w  #PATTERN_7,BLTBDAT(a1)
	move.w  #BLTCON0_7,BLTCON0(a1)
	move.w  #BLTCON1_7,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)
	lea     color7,a2 
	bsr     checkZeroBit

    ; Blit 8
	bsr     prepareblit
	move.l  #bitplanes+$1E*40+18,BLTCPTH(a1)
	move.l  #bitplanes+$1E*40+18,BLTDPTH(a1)
	move.w  #PATTERN_8,BLTBDAT(a1)
	move.w  #BLTCON0_8,BLTCON0(a1)
	move.w  #BLTCON1_8,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)
	lea     color8,a2 
	bsr     checkZeroBit

    ; Blit 9
	bsr     prepareblit
	move.l  #bitplanes+$20*40+18,BLTCPTH(a1)
	move.l  #bitplanes+$20*40+18,BLTDPTH(a1)
	move.w  #PATTERN_9,BLTBDAT(a1)
	move.w  #BLTCON0_9,BLTCON0(a1)
	move.w  #BLTCON1_9,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)
	lea     color9,a2 
	bsr     checkZeroBit

    ; Blit 10
	bsr     prepareblit
	move.l  #bitplanes+$22*40+18,BLTCPTH(a1)
	move.l  #bitplanes+$22*40+18,BLTDPTH(a1)
	move.w  #PATTERN_10,BLTBDAT(a1)
	move.w  #BLTCON0_10,BLTCON0(a1)
	move.w  #BLTCON1_10,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)
	lea     color10,a2 
	bsr     checkZeroBit

    ; Blit 11
	bsr     prepareblit
	move.l  #bitplanes+$24*40+18,BLTCPTH(a1)
	move.l  #bitplanes+$24*40+18,BLTDPTH(a1)
	move.w  #PATTERN_11,BLTBDAT(a1)
	move.w  #BLTCON0_11,BLTCON0(a1)
	move.w  #BLTCON1_11,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)
	lea     color11,a2 
	bsr     checkZeroBit

    ; Blit 12
	bsr     prepareblit
	move.l  #bitplanes+$26*40+18,BLTCPTH(a1)
	move.l  #bitplanes+$26*40+18,BLTDPTH(a1)
	move.w  #PATTERN_12,BLTBDAT(a1)
	move.w  #BLTCON0_12,BLTCON0(a1)
	move.w  #BLTCON1_12,BLTCON1(a1)
	move.w  #LENGTH,BLTSIZE(a1)
	lea     color12,a2 
	bsr     checkZeroBit
	rts

prepareblit:
	bsr     blitWait
	move.w  #40,BLTCMOD(a1)
	move.w  #40,BLTDMOD(a1)
	move.w  #-100,BLTAPTL(a1)
	move.w  #-200,BLTAMOD(a1)
	move.w  #0,BLTBMOD(a1)
	move.w  #$8000,BLTADAT(a1)
	move.l  #$FFFFFFFF,BLTAFWM(a1)
	rts

checkZeroBit:
	bsr     blitWait
	move.w  DMACONR(a1),d0
	btst    #13,d0
	beq     .case2
	move.w  #$FF0,$2(a2)
	rts
.case2:
	move.w  #$44F,$2(a2)
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

	dc.w    $5F39, $FFFE         ; WAIT
color1:
	dc.w    COLOR00,$888
	dc.w    $6839, $FFFE         ; WAIT
	dc.w    COLOR00,$000
	dc.w    $6F39, $FFFE         ; WAIT
color2:
	dc.w    COLOR00,$444
	dc.w    $7839, $FFFE         ; WAIT
	dc.w    COLOR00,$000
	dc.w    $7F39, $FFFE         ; WAIT
color3:
	dc.w    COLOR00,$888
	dc.w    $8839, $FFFE         ; WAIT
	dc.w    COLOR00,$000
	dc.w    $8F39, $FFFE         ; WAIT
color4:
	dc.w    COLOR00,$444
	dc.w    $9839, $FFFE         ; WAIT
	dc.w    COLOR00,$000
	dc.w    $9F39, $FFFE         ; WAIT
color5:
	dc.w    COLOR00,$888
	dc.w    $A839, $FFFE         ; WAIT
	dc.w    COLOR00,$000
	dc.w    $AF39, $FFFE         ; WAIT
color6:
	dc.w    COLOR00,$444
	dc.w    $B839, $FFFE         ; WAIT
	dc.w    COLOR00,$000
	dc.w    $BF39, $FFFE         ; WAIT
color7:
	dc.w    COLOR00,$888
	dc.w    $C839, $FFFE         ; WAIT
	dc.w    COLOR00,$000
	dc.w    $CF39, $FFFE         ; WAIT
color8:
	dc.w    COLOR00,$444
	dc.w    $D839, $FFFE         ; WAIT
	dc.w    COLOR00,$000
	dc.w    $DF39, $FFFE         ; WAIT
color9:
	dc.w    COLOR00,$444
	dc.w    $E839, $FFFE         ; WAIT
	dc.w    COLOR00,$000
	dc.w    $EF39, $FFFE         ; WAIT
color10:
	dc.w    COLOR00,$444
	dc.w    $F839, $FFFE         ; WAIT
	dc.w    COLOR00,$000
	dc.w    $FF39, $FFFE         ; WAIT
color11:
	dc.w    COLOR00,$444

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.w    $0839, $FFFE         ; WAIT
	dc.w    COLOR00,$000
	dc.w    $0F39, $FFFE         ; WAIT
color12:
	dc.w    COLOR00,$444
	dc.w    $1839, $FFFE         ; WAIT
	dc.w    COLOR00,$000

	dc.l	$fffffffe

bitplanes:
	ds.b    61440,$00
	