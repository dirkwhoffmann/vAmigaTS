BLIT_BLTCON0        equ $0FCA
BLIT_BLTCON1		equ $0000

BLTSIZE1            equ (5)<<6|(5)

COL1                equ $44F
COL2                equ $FF0
COL3                equ $F44
COL4                equ $4F4

RULER	MACRO
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
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
	ENDM

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
	dc.w    BPLCON0,$0200

    ;
    ; Section 1
	;

  	dc.w    $3E39, $FFFE         ; WAIT
	RULER

	dc.w	$4039,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000

	dc.w	$4239,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $4251,$FFFE
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000

	dc.w	$4439,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $4451,$FFFE
	dc.w    $4451,$FFFE
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000

 	dc.w	$4639,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $4651,$FFFE
	dc.w    $4651,$FFFE
	dc.w    $4651,$FFFE
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	
	dc.w	$4839,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $4851,$FFFE
	dc.w    $4851,$FFFE
	dc.w    $4851,$FFFE
	dc.w    $4851,$FFFE
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	
	dc.w	$4A39,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $4A51,$FFFE
	dc.w    $4A59,$FFFE
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000

	dc.w	$4C39,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $4C51,$FFFE
	dc.w    $4C59,$FFFE
	dc.w    $4C61,$FFFE
	dc.w    $4C69,$FFFE
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000

	dc.w	$4E39,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $4E51,$FFFE
	dc.w    $4E59,$FFFE
	dc.w    $4E61,$FFFE
	dc.w    $4E69,$FFFE
	dc.w    $4E71,$FFFE
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000
	
	dc.w    $5039, $FFFE         ; WAIT
	RULER

	dc.w	$5239,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000

	dc.w	$5439,$FFFE  ; WAIT 
	dc.w	COLOR00,COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $5251,$FFFF
	dc.w	COLOR00, COL3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000

	dc.w	$5639,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $6261,$FFFF
	dc.w	COLOR00, COL3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000

	dc.w	$5839,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $6251,$FFFF
	dc.w	COLOR00, COL3
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000

	dc.w	$5A39,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $5051,$FFFF
	dc.w	COLOR00, COL3
	dc.w    $6051,$FFFF
	dc.w	COLOR00, COL4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000

	dc.w	$5C39,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $6051,$FFFF
	dc.w	COLOR00, COL3
	dc.w    $5051,$FFFF
	dc.w	COLOR00, COL4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000

	dc.w	$5E39,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $5051,$FFFF
	dc.w	COLOR00, COL3
	dc.w    $5051,$FFFF
	dc.w	COLOR00, COL4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000

	dc.w	$6039,$FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    BLTSIZE, BLTSIZE1
	dc.w    $7051,$FFFF
	dc.w	COLOR00, COL3
	dc.w    $7051,$FFFF
	dc.w	COLOR00, COL4
	dc.w    $0001,$7FFE  ; WAIT
	dc.w	COLOR00, COL2
	dc.w    COLOR00, $000

	dc.w    BPLCON0, (0<<12)|$200
	dc.l    $fffffffe
spare:
	ds.w    1024,$00
bitplanes:
	ds.b    32768,$00
