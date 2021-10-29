	include "../../../include/registers.i"
	include "../../../include/ministartup.i"

MAIN:
	; Load OCS base address
	lea     CUSTOM,a1
	lea     CUSTOM,a6

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

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

	; Set up playfield
	move.w  #$2C81,DIWSTRT(a1)
	move.w	#$572C,DIWSTOP(a1)
	move.w	#$0,BPL1MOD(a1)
	move.w	#$0,BPL2MOD(a1)

	; Setup Copper
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #$8003,COPCON(a1)   ; Allow Copper to write Blitter registers

	; Enable DMA
	move.w	#$8040,DMACON(a1)   ; Blitter DMA 	
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 
	move.w	#$8400,DMACON(a1)   ; BlitPri = 1 

	; Enable interrupts
	; move.w	#$E89C,INTENA(a1)

.mainLoop:

	jsr     synccpu
	jsr     prepareblit

	move.w  #1700,d3
.loop1:
	dbra    d3,.loop1
   	move.w  #1800,d3
	move.w  #$88F,d4
	move.w  #$000,d5
.loop2:
	move.w  d4,COLOR00(a1)
	move.w  d5,COLOR00(a1)
    dbra    d3,.loop2
	bra.s	.mainLoop

prepareblit:	
	movem.l d0-a6,-(sp)
	bsr     blitWait
	move.w  #BLIT_BLTCON1,d0
	btst    #0,d0
	bne     .prepareline

	; Prepare the copy Bliter
	move.w  #$44B,COLOR00(a1)
	move.w  #BLIT_BLTCON0,BLTCON0(a1)
	move.w  #BLIT_BLTCON1,BLTCON1(a1) 
	move.l  #$ffffffff,BLTAFWM(a1)   
	move.w  #0,BLTAMOD(a1)
	move.w  #0,BLTBMOD(a1)
	move.w  #0,BLTCMOD(a1)
	move.w  #0,BLTDMOD(a1)
	move.l  #spare,BLTAPTH(a1)	 
	move.l  #spare,BLTBPTH(a1)	
	move.l  #spare,BLTCPTH(a1)
	move.l  #spare,BLTDPTH(a1)
	movem.l (sp)+,d0-a6
	rts

.prepareline:
	; Prepare the line Blitter
	move.w  #$4B4,COLOR00(a1)
	move.w  #BLIT_BLTCON0,BLTCON0(a1)
	move.w  #BLIT_BLTCON1,BLTCON1(a1) 
	move.l  #$ffffffff,BLTAFWM(a1)
	move.w  #40,BLTCMOD(a1)
	move.w  #40,BLTDMOD(a1)
	move.w  #-100,BLTAPTL(a1)
	move.w  #-200,BLTAMOD(a1)
	move.w  #0,BLTBMOD(a1)
	move.w  #$ABCA,BLTCON0(a1)
	move.w  #$8000,BLTADAT(a1)
	move.l  #spare,BLTBPTH(a1)	
	move.l  #spare,BLTCPTH(a1)
	move.l  #spare,BLTDPTH(a1)
	movem.l (sp)+,d0-a6
	rts

synccpu:
	lea     VHPOSR(a1),a3     ; VHPOSR     

	; Wait until we have reached a certain scanline
.loop 
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$2000,d2
	bne     .loop
	and     #1,VPOSR(a1)
	bne     .loop

	; Sync horizontally
	move.w  #$F0F,COLOR00(a1)
.synccpu1:
	andi.w  #$F,(a3)          ; 16 cycles
	bne     .synccpu1         ; 10 cycles
	move.w  #$606,COLOR00(a1)
.synccpu2:
	andi.w  #$1F,(a3)         ; 16 cycles
	bne     .synccpu2         ; 10 cycles
	move.w  #$A0A,COLOR00(a1)
.synccpu3:
	andi.w  #$FF,(a3)         ; 16 cycles
	nop                       ;  4 cycles
	nop                       ;  4 cycles
	nop                       ;  4 cycles
	bne     .synccpu3         ; 10 cycles (if taken)

	; Adust horizontally
  	moveq   #10,d2
.adjust:
    dbra    d2,.adjust

	; Sync vertically
.synccpu4:
	nop 
	move.w  #$404,COLOR00(a1)
	ds.w    96,$4E71          ; NOPs to keep the horizontal position in each iteration
	move.w  (a3),d2     
	move.w  #$F0F,COLOR00(a1)  
	and     #$FF00,d2
	cmp.w   #$3000,d2
	bne     .synccpu4
	move.w  #$000,COLOR00(a1)
	rts

blitWait:
	tst DMACONR(a1)		;for compatibility
.waitblit:
	btst #6,DMACONR(a1)
	bne.s .waitblit
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

	dc.w    DDFSTRT,$38
	dc.w    DDFSTOP,$D0
	dc.w    BPLCON0, (0<<12)|$200

 	; Draw reference lines
	dc.w    $4E39, $FFFE         ; WAIT
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
    ; Perform blits with different sizes
	;

	dc.w	$7539,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (1)<<6|(1)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$7739,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (1)<<6|(2)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$7939,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (2)<<6|(1)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

 	dc.w	$7B39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (2)<<6|(2)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00
	
	dc.w	$7D39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (2)<<6|(3)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00
	
	dc.w	$7F39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (3)<<6|(2)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$8139,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (3)<<6|(3)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$8339,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (3)<<6|(4)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00
	
	dc.w	$8539,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (4)<<6|(3)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$8739,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (4)<<6|(4)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$8939,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (4)<<6|(5)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$8B39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (5)<<6|(4)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$8D39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (5)<<6|(5)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$8F39,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (5)<<6|(6)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$9139,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (6)<<6|(5)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$9339,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (6)<<6|(6)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$9539,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (6)<<6|(7)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

  	;
    ; Round 2
	;
	
	dc.w	$A539,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (1)<<6|(1)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$A73B,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (1)<<6|(2)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$A93D,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (2)<<6|(1)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

 	dc.w	$AB3F,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (2)<<6|(2)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00
	
	dc.w	$AD41,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (2)<<6|(3)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00
	
	dc.w	$AF43,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (3)<<6|(2)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$B145,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (3)<<6|(3)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$B347,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (3)<<6|(4)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00
	
	dc.w	$B549,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (4)<<6|(3)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$B74B,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (4)<<6|(4)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$B94D,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (4)<<6|(5)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$BB4F,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (5)<<6|(4)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$BD51,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (5)<<6|(5)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$BF53,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (5)<<6|(6)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$C155,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (6)<<6|(5)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$C357,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (6)<<6|(6)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	dc.w	$C559,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w    BLTSIZE, (6)<<6|(7)
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $F00

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.l    $fffffffe	

spare:
	ds.w    1024,$00
bitplanes:
	ds.b    32768,$00
