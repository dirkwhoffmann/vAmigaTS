	include "../../../include/registers.i"
	include "../../../include/ministartup.i"
	include "../../../include/util.i"

HEIGHT      equ 6

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
	
	;
	; Setup bitplane data
	;
	lea     bitplanes,a2

	moveq	#HEIGHT-1,d0
.x1:
	move.w 	#$FFFF,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$FFFF,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$FFFF,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$FFFF,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$FFFF,(a2)+
	move.w 	#$0000,(a2)+
	add.w   #20,a2
	dbra	d0,.x1

	moveq	#HEIGHT-1,d0
.x2:
	move.w 	#$8000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0001,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	add.w   #20,a2
	dbra	d0,.x2

	moveq	#HEIGHT-1,d0
.x3:
	move.w 	#$4000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$8000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	add.w   #20,a2
	dbra	d0,.x3

	moveq	#HEIGHT-1,d0
.x4:
	move.w 	#$8000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0002,(a2)+
	add.w   #20,a2
	dbra	d0,.x4

	moveq	#HEIGHT-1,d0
.x5:
	move.w 	#$8000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0001,(a2)+
	add.w   #20,a2
	dbra	d0,.x5

	moveq	#HEIGHT-1,d0
.x6:
	move.w 	#$4000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0002,(a2)+
	add.w   #20,a2
	dbra	d0,.x6

	moveq	#HEIGHT-1,d0
.x7:
	move.w 	#$4000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0001,(a2)+
	add.w   #20,a2
	dbra	d0,.x7
	
	moveq	#HEIGHT-1,d0
.x8:
	move.w 	#$AAAA,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$AAAA,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$CCCC,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$CCCC,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$FF00,(a2)+
	move.w 	#$FF00,(a2)+
	add.w   #20,a2
	dbra	d0,.x8

	moveq	#HEIGHT-1,d0
.x9:
	move.w 	#$8000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	add.w   #20,a2
	dbra	d0,.x9

	moveq	#HEIGHT-1,d0
.x10:
	move.w 	#$4000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	add.w   #20,a2
	dbra	d0,.x10

	moveq	#HEIGHT-1,d0
.x11:
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0001,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	add.w   #20,a2
	dbra	d0,.x11

	moveq	#HEIGHT-1,d0
.x12:
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0002,(a2)+
	add.w   #20,a2
	dbra	d0,.x12

	moveq	#HEIGHT-1,d0
.x13:
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0000,(a2)+
	move.w 	#$0001,(a2)+
	add.w   #20,a2
	dbra	d0,.x13

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

.mainloop:
	jmp     .mainloop

runtest:

	; Prepare the Blitter
	bsr     blitWait
	move.l  #bitplanes,BLTAPTH(a1)
	move.l  #bitplanes,BLTBPTH(a1)
	move.l  #bitplanes,BLTCPTH(a1)
	move.l  #bitplanes+$60*40,BLTDPTH(a1)
	move.w  #20,BLTAMOD(a1)
	move.w  #20,BLTBMOD(a1)
	move.w  #20,BLTCMOD(a1)
	move.w  #20,BLTDMOD(a1)
	move.w  #VAL_BLTCON0,BLTCON0(a1)
	move.w  #VAL_BLTCON1,BLTCON1(a1)
	move.w  #VAL_BLTADAT,BLTADAT(a1)
	move.w  #VAL_BLTBDAT,BLTBDAT(a1)
	move.w  #VAL_BLTCDAT,BLTCDAT(a1)
	move.l  #$FFFFFFFF,BLTAFWM(a1)

	; Start the Blitter
	move.w  #((13*6)<<6)|10,BLTSIZE(a1)
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
	dc.w    COLOR01,$FF8

	dc.w    $8339, $FFFE         ; WAIT
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

	dc.w    COLOR01,$F88

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.l	$fffffffe

bitplanes:
	ds.b    61440,$00
	