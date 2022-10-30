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
	move.w	#$C001,INTENA(a1)   ; TBE (UART)

.mainLoop:

	jsr     synccpu
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

	dc.w	SERPER, SERPERVAL

    ;
    ; Section 1
	;
	
  	dc.w    $3D01, $FFFE         ; WAIT
	dc.w    BPLCON0, (0<<12)|$200
  	dc.w    $3E39, $FFFE         ; WAIT
	include "../copperline.i"

	dc.w	$4039, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$4049, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$4239, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$424B, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$4439, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$444D, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

 	dc.w	$4639, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$464F, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$4839, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$4851, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$4A39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$4A53, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$4C39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$4C55, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$4E39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$4E57, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$5039, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$5059, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$5239, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$525B, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$5439, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$545D, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$5639, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$565F, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$5839, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$5861, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$5A39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$5A63, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$5C39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$5C65, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

  	;
  	; Section 2
  	;

  	dc.w    $5D01, $FFFE         ; WAIT
	dc.w    BPLCON0, (0<<12)|$200
  	dc.w    $5E39, $FFFE         ; WAIT
	include "../copperline.i"

	dc.w    BPLCON0, (0<<12)|$200

	dc.w	$6039, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$6067, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$6239, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$6269, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$6439, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$646B, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

 	dc.w	$6639, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$666D, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$6839, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$686F, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$6A39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$6A71, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$6C39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$6C73, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$6E39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$6E75, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$7039, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$7077, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$7239, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$7279, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$7439, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$747B, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$7639, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$767D, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$7839, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$787F, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$7A39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$7A81, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$7C39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$7C83, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
  	;
   	; Section 3
   	;

  	dc.w    $7D01, $FFFE         ; WAIT
	dc.w    BPLCON0, (0<<12)|$200
  	dc.w    $7E39, $FFFE         ; WAIT
	include "../copperline.i"

	dc.w    BPLCON0, (2<<12)|$200

	dc.w	$8039, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$8049, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$8239, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$824B, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$8439, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$844D, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

 	dc.w	$8639, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$864F, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$8839, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$8851, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$8A39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$8A53, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$8C39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$8C55, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$8E39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$8E57, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$9039, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$9059, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$9239, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$925B, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$9439, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$945D, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$9639, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$965F, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$9839, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$9861, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$9A39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$9A63, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$9C39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$9C65, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

   	;
   	; Section 4
   	;

  	dc.w    $9D01, $FFFE         ; WAIT
	dc.w    BPLCON0, (0<<12)|$200
  	dc.w    $9E39, $FFFE         ; WAIT
	include "../copperline.i"

	dc.w    BPLCON0, (3<<12)|$200

	dc.w	$A039, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$A067, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$A239, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$A269, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$A439, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$A46B, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

 	dc.w	$A639, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$A66D, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$A839, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$A86F, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$AA39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$AA71, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$AC39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$AC73, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$AE39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$AE75, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$B039, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$B077, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$B239, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$B279, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$B439, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$B47B, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$B639, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$B67D, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$B839, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$B87F, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$BA39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$BA81, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$BC39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$BC83, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
   	;
   	; Section 5
   	;

  	dc.w    $BD01, $FFFE         ; WAIT
	dc.w    BPLCON0, (0<<12)|$200
  	dc.w    $BE39, $FFFE         ; WAIT
	include "../copperline.i"

	dc.w    BPLCON0, (4<<12)|$200

	dc.w	$C039, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$C049, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$C239, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$C24B, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$C439, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$C44D, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

 	dc.w	$C639, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$C64F, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$C839, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$C851, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$CA39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$CA53, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$CC39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$CC55, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$CE39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$CE57, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$D039, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$D059, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$D239, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$D25B, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$D439, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$D45D, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$D639, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$D65F, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$D839, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$D861, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$DA39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$DA63, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$DC39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$DC65, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
  	;
    ; Section 6
    ;

  	dc.w    $DD01, $FFFE         ; WAIT
	dc.w    BPLCON0, (0<<12)|$200
  	dc.w    $DE39, $FFFE         ; WAIT
	include "../copperline.i"

	dc.w    BPLCON0, (5<<12)|$200

	dc.w	$E039, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$E067, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$E239, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$E269, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$E439, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$E46B, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

 	dc.w	$E639, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$E66D, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$E839, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$E86F, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$EA39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$EA71, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$EC39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$EC73, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$EE39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$EE75, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
	dc.w	$F039, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$F077, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$F239, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$F279, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$F439, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$F47B, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$F639, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$F67D, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$F839, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$F87F, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$FA39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$FA81, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000

	dc.w	$FC39, $FFFE  ; WAIT 
	dc.w	COLOR00, COL1
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	dc.w	$FC83, $FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    SERDAT, $FF
	dc.w	COLOR00, $000
	
  	;
    ; Section 7
    ;

  	dc.w    $FD01, $FFFE         ; WAIT
	dc.w    BPLCON0, (0<<12)|$200
  	dc.w    $FE39, $FFFE         ; WAIT
	include "../copperline.i"


	dc.w    BPLCON0, (0<<12)|$200
	dc.l    $fffffffe
spare:
	ds.w    2048,$00
bitplanes:
	ds.b    32768,$00
