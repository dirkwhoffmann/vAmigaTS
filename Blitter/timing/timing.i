	include "../../../include/registers.i"
	include "../../../include/ministartup.i"

CHK_EXC_VECTOR		equ $18
TRPV_INT_VECTOR		equ $1C
LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78
TRP0_INT_VECTOR		equ $80
TRP1_INT_VECTOR		equ $84
TRP2_INT_VECTOR		equ $88

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

	; Install interrupt handlers
	lea	    irq3(pc),a3 
 	move.l	a3,LVL3_INT_VECTOR

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
	move.w	#$C020,INTENA(a1)   ; VERTB

.mainLoop:

	jsr     synccpu
	jsr     prepareblit
	bra.s	.mainLoop

prepareblit:	
	movem.l d0-a6,-(sp)
	bsr     blitWait
	move.w  #BLIT_BLTCON1,d0
	btst    #0,d0
	bne     .prepareline

	; Prepare the copy Blitter
	move.w  #$004,COLOR00(a1)
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
	;move.w  #$040,COLOR00(a1)
	move.w  #BLIT_BLTCON0,BLTCON0(a1)
	move.w  #BLIT_BLTCON1,BLTCON1(a1) 
	move.l  #$ffffffff,BLTAFWM(a1)
	move.w  #40,BLTCMOD(a1)
	move.w  #40,BLTDMOD(a1)
	move.w  #-100,BLTAPTL(a1)
	move.w  #-200,BLTAMOD(a1)
	move.w  #0,BLTBMOD(a1)
	move.w  #$8000,BLTADAT(a1)
	move.l  #spare,BLTBPTH(a1)	
	move.l  #spare,BLTCPTH(a1)
	move.l  #spare,BLTDPTH(a1)
	movem.l (sp)+,d0-a6
	rts

irq3:
	move.w  #$000,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	rte

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

    ;
    ; Section 1
	;

  	dc.w    $3D01, $FFFE         ; WAIT
	dc.w    BPLCON0, (0<<12)|$200
  	dc.w    $3E39, $FFFE         ; WAIT
	include "../copperline.i"

	dc.w	$4039,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$4239,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$4439,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

 	dc.w	$4639,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$4839,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$4A3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$4C3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$4E3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$503B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$523B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$543D,$FFFE  ; WAIT 
	dc.w	COLOR00,COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$563D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$583D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$5A3D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$5C3D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	;
	; Section 2
  	;

  	dc.w    $5D01, $FFFE         ; WAIT
	dc.w    BPLCON0, (0<<12)|$200
  	dc.w    $5E39, $FFFE         ; WAIT
	include "../copperline.i"

	dc.w    BPLCON0, (1<<12)|$200

	dc.w	$6039,$FFFE  ; WAIT 
	dc.w	COLOR00, COL2
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$6239,$FFFE ; WAIT 
	dc.w	COLOR00, COL2
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$6439,$FFFE  ; WAIT 
	dc.w	COLOR00, COL2
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

 	dc.w	$6639,$FFFE  ; WAIT 
	dc.w	COLOR00, COL2
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$6839,$FFFE  ; WAIT 
	dc.w	COLOR00, COL2
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$6A3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL2
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$6C3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL2
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$6E3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL2
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$703B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL2
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$723B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL2
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$743D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL2
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$763D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL2
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$783D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL2
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$7A3D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL2
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$7C3D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL2
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

   	;
   	; Section 3
   	;

  	dc.w    $7D01, $FFFE         ; WAIT
	dc.w    BPLCON0, (0<<12)|$200
  	dc.w    $7E39, $FFFE         ; WAIT
	include "../copperline.i"
	dc.w    BPLCON0, (2<<12)|$200

	dc.w	$8039,$FFFE  ; WAIT 
	dc.w	COLOR00, COL3
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$8239,$FFFE ; WAIT 
	dc.w	COLOR00, COL3
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$8439,$FFFE  ; WAIT 
	dc.w	COLOR00, COL3
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

 	dc.w	$8639,$FFFE  ; WAIT 
	dc.w	COLOR00, COL3
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$8839,$FFFE  ; WAIT 
	dc.w	COLOR00, COL3
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$8A3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL3
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$8C3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL3
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$8E3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL3
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$903B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL3
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$923B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL3
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$943D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL3
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$963D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL3
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$983D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL3
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$9A3D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL3
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$9C3D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL3
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

   	;
   	; Section 4
   	;

  	dc.w    $9D01, $FFFE         ; WAIT
	dc.w    BPLCON0, (0<<12)|$200
  	dc.w    $9E39, $FFFE         ; WAIT
	include "../copperline.i"
	dc.w    BPLCON0, (3<<12)|$200

	dc.w	$A039,$FFFE  ; WAIT 
	dc.w	COLOR00, COL4
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$A239,$FFFE ; WAIT 
	dc.w	COLOR00, COL4
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$A439,$FFFE  ; WAIT 
	dc.w	COLOR00, COL4
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

 	dc.w	$A639,$FFFE  ; WAIT 
	dc.w	COLOR00, COL4
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$A839,$FFFE  ; WAIT 
	dc.w	COLOR00, COL4
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$AA3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL4
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$AC3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL4
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$AE3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL4
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$B03B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL4
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$B23B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL4
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$B43D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL4
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$B63D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL4
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$B83D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL4
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$BA3D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL4
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$BC3D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL4
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
   	;
   	; Section 5
   	;

  	dc.w    $BD01, $FFFE         ; WAIT
	dc.w    BPLCON0, (0<<12)|$200
  	dc.w    $BE39, $FFFE         ; WAIT
	include "../copperline.i"
	dc.w    BPLCON0, (4<<12)|$200

	dc.w	$C039,$FFFE  ; WAIT 
	dc.w	COLOR00, COL5
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$C239,$FFFE ; WAIT 
	dc.w	COLOR00, COL5
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$C439,$FFFE  ; WAIT 
	dc.w	COLOR00, COL5
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

 	dc.w	$C639,$FFFE  ; WAIT 
	dc.w	COLOR00, COL5
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$C839,$FFFE  ; WAIT 
	dc.w	COLOR00, COL5
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$CA3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL5
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$CC3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL5
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$CE3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL5
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$D03B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL5
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$D23B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL5
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$D43D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL5
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$D63D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL5
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$D83D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL5
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$DA3D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL5
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$DC3D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL5
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

  	;
    ; Section 6
  	;

  	dc.w    $DD01, $FFFE         ; WAIT
	dc.w    BPLCON0, (0<<12)|$200
  	dc.w    $DE39, $FFFE         ; WAIT
	include "../copperline.i"
	dc.w    BPLCON0, (5<<12)|$200

	dc.w	$E039,$FFFE  ; WAIT 
	dc.w	COLOR00, COL6
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$E239,$FFFE ; WAIT 
	dc.w	COLOR00, COL6
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$E439,$FFFE  ; WAIT 
	dc.w	COLOR00, COL6
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

 	dc.w	$E639,$FFFE  ; WAIT 
	dc.w	COLOR00, COL6
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$E839,$FFFE  ; WAIT 
	dc.w	COLOR00, COL6
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$EA3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL6
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$EC3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL6
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$EE3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL6
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$F03B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL6
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$F23B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL6
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$F43D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL6
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$F63D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL6
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$F83D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL6
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$FA3D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL6
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$FC3D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL6
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

  	;
    ; Section 7
    ;

  	dc.w    $FD01, $FFFE         ; WAIT
	dc.w    BPLCON0, (0<<12)|$200
  	dc.w    $FE39, $FFFE         ; WAIT
	include "../copperline.i"
	dc.w    BPLCON0, (6<<12)|$200

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.w	$0039,$FFFE  ; WAIT 
	dc.w	COLOR00, COL7
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$0239,$FFFE ; WAIT 
	dc.w	COLOR00, COL7
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$0439,$FFFE  ; WAIT 
	dc.w	COLOR00, COL7
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

 	dc.w	$0639,$FFFE  ; WAIT 
	dc.w	COLOR00, COL7
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$0839,$FFFE  ; WAIT 
	dc.w	COLOR00, COL7
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$0A3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL7
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$0C3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL7
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$0E3B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL7
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000
	
	dc.w	$103B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL7
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$123B,$FFFE  ; WAIT 
	dc.w	COLOR00, COL7
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$143D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL7
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$163D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL7
	dc.w    BLTSIZE, BLTSIZE2
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$183D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL7
	dc.w    BLTSIZE, BLTSIZE3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$1A3D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL7
	dc.w    BLTSIZE, BLTSIZE4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w	$1C3D,$FFFE  ; WAIT 
	dc.w	COLOR00, COL7
	dc.w    BLTSIZE, BLTSIZE5
	dc.w    $0001,$7FFE  ; WAIT
	dc.w    COLOR00, $000

	dc.w    BPLCON0, (0<<12)|$200
	dc.l    $fffffffe
spare:
	ds.w    1024,$00
bitplanes:
	ds.b    32768,$00
