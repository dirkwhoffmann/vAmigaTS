	include "../../../include/registers.i"
	; WE DON'T USE MINISTARTUP AS IT DOESN'T SEEM TO BE NTSC COMPATIBLE
	; include "../../../include/ministartup.i" 

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
	lea	    irq1(pc),a3 
 	move.l	a3,LVL1_INT_VECTOR

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

	; Enable interrupts
	move.w	#$C020,INTENA(a1)   ; VERTB
	; move.w	#$C001,INTENA(a1)   ; TBE (UART)

.mainLoop:

	; jsr     synccpu
	bra.s	.mainLoop
	
irq1:
	move.w  #$FF0,COLOR00(a1)
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

	dc.w    COLOR00,$000

	BEAMCON	

    ;
    ; Section 1
	;
	
  	dc.w    $3D01, $FFFE         	; WAIT
	dc.w    BPLCON0, (0<<12)|$200
	dc.w    VPOSW,$0
  	dc.w    $3E39, $FFFE         	; WAIT
	include "../copperline.i"

	dc.w    $4011, $FFFE  			; WAIT
	VPOSW0
	dc.w	$40BF, $FFFE  			; WAIT
	include "../copperline.i"
	dc.w    $41BF, $FFFE  			; WAIT
	include "../copperline.i"
	dc.w	$42BF, $FFFE  			; WAIT
	include "../copperline.i"
	dc.w    $43BF, $FFFE  			; WAIT
	include "../copperline.i"

	dc.w    $4811, $FFFE  			; WAIT
	VPOSW1
	dc.w	$48BF, $FFFE  			; WAIT
	include "../copperline.i"
	dc.w    $49BF, $FFFE  			; WAIT
	include "../copperline.i"
	dc.w	$4ABF, $FFFE  			; WAIT
	include "../copperline.i"
	dc.w    $4BBF, $FFFE  			; WAIT
	include "../copperline.i"

	dc.w    $5011, $FFFE  			; WAIT
	VPOSW0
	dc.w	$50BF, $FFFE  			; WAIT
	include "../copperline.i"
	VPOSW0
	dc.w    $51BF, $FFFE  			; WAIT
	include "../copperline.i"
	VPOSW0
	dc.w    $52BF, $FFFE  			; WAIT
	include "../copperline.i"
	VPOSW0
	dc.w    $53BF, $FFFE  			; WAIT
	include "../copperline.i"


	dc.w    $5811, $FFFE  			; WAIT
	VPOSW0
	dc.w	$58BF, $FFFE  			; WAIT
	include "../copperline.i"
	VPOSW1
	dc.w    $59BF, $FFFE  			; WAIT
	include "../copperline.i"
	VPOSW0
	dc.w    $5ABF, $FFFE  			; WAIT
	include "../copperline.i"
	VPOSW1
	dc.w    $5BBF, $FFFE  			; WAIT
	include "../copperline.i"


	dc.w    $6011, $FFFE  			; WAIT
	VPOSW1
	dc.w	$60BF, $FFFE  			; WAIT
	include "../copperline.i"
	VPOSW0
	dc.w    $61BF, $FFFE  			; WAIT
	include "../copperline.i"
	VPOSW1
	dc.w    $62BF, $FFFE  			; WAIT
	include "../copperline.i"
	VPOSW0
	dc.w    $63BF, $FFFE  			; WAIT
	include "../copperline.i"

	dc.w    $6811, $FFFE  			; WAIT
	VPOSW1
	dc.w	$68BF, $FFFE  			; WAIT
	include "../copperline.i"
	VPOSW1
	dc.w    $69BF, $FFFE  			; WAIT
	include "../copperline.i"
	VPOSW1
	dc.w    $6ABF, $FFFE  			; WAIT
	include "../copperline.i"
	VPOSW1
	dc.w    $6BBF, $FFFE  			; WAIT
	include "../copperline.i"

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	; Wait for PAL only line
	dc.w    $08BF, $FFFE  			; WAIT
	dc.w    COLOR00,$888
	
	dc.l    $fffffffe
spare:
	ds.w    2048,$00
bitplanes:
	ds.b    32768,$00
