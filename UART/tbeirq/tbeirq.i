	include "../../../include/registers.i"
	include "../../../include/ministartup.i"

LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78

COL1                equ $FD3
COL2                equ $FC4
COL3                equ $FB5
COL4                equ $FA6
COL5                equ $F97
COL6                equ $F88

COL1_2              equ $E89
COL2_2              equ $D8A
COL3_2              equ $C8B
COL4_2              equ $B8C
COL5_2              equ $A8D
COL6_2              equ $98E

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
	lea	    irq2(pc),a3 
 	move.l	a3,LVL2_INT_VECTOR
	lea	    irq3(pc),a3 
 	move.l	a3,LVL3_INT_VECTOR
	lea	    irq4(pc),a3 
 	move.l	a3,LVL4_INT_VECTOR
	lea	    irq5(pc),a3 
 	move.l	a3,LVL5_INT_VECTOR
	lea	    irq6(pc),a3 
 	move.l	a3,LVL6_INT_VECTOR

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
	move.w	#$E899,INTENA(a1)

	; Setup constants
	lea	    irq1(pc),a4 
	lea	    irq1_2(pc),a5 
	
.mainLoop:
	jsr     synccpu
	bra.s	.mainLoop

irq1:
    move.w  #$66F,COLOR00(a1)
 	move.l	a5,LVL1_INT_VECTOR
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
    move.w  #$000,COLOR00(a1)
	move.w  #PAYLOAD,SERDAT(a1)
	rte

irq1_2:
    move.w  #$FFF,COLOR00(a1)
 	move.l	a4,LVL1_INT_VECTOR
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
    move.w  #$000,COLOR00(a1)
	rte

irq2:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #PERIOD,SERPER(a1)
	move.w  #COL2,COLOR00(a1)
	move.w  #PAYLOAD,SERDAT(a1)
	rte

irq3:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #PERIOD+3,SERPER(a1)
	move.w  #COL3,COLOR00(a1)
	move.w  #PAYLOAD,SERDAT(a1)
	rte

irq4:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #PERIOD+6,SERPER(a1)
	move.w  #COL4,COLOR00(a1)
	move.w  #PAYLOAD,SERDAT(a1)
	rte

irq5:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #PERIOD+9,SERPER(a1)
	move.w  #COL5,COLOR00(a1)
	move.w  #PAYLOAD,SERDAT(a1)
	rte

irq6:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #PERIOD+12,SERPER(a1)
	move.w  #COL6,COLOR00(a1)
	move.w  #PAYLOAD,SERDAT(a1)
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
	dc.w    BPLCON0, (0<<12)|$200

    ;
    ; Section 1
	;

  	dc.w    $4039, $FFFE
	include "../copperline.i"
	dc.w    BPLCON0, (0<<12)|$200

	dc.w	$42<<8|HPOS,$FFFE
	dc.w    INTREQ, $8004                ; Level 1 interrupt

	dc.w	$44<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8008                ; Level 2 interrupt

	dc.w	$46<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8010                ; Level 3 interrupt

	dc.w	$48<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8080                ; Level 4 interrupt

	dc.w	$4A<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8800                ; Level 5 interrupt

	dc.w	$4C<<8|HPOS, $FFFE  
	dc.w    INTREQ, $A000                ; Level 6 interrupt

    ;
    ; Section 2
	;

  	dc.w    $5039, $FFFE         ; WAIT
	include "../copperline.i"
	dc.w    BPLCON0, (0<<12)|$200

	dc.w	$54<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8008                ; Level 2 interrupt

	dc.w	$56<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8010                ; Level 3 interrupt

	dc.w	$58<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8080                ; Level 4 interrupt

	dc.w	$5A<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8800                ; Level 5 interrupt

	dc.w	$5C<<8|HPOS, $FFFE  
	dc.w    INTREQ, $A000                ; Level 6 interrupt

  	;
    ; Section 3
	;

  	dc.w    $6039, $FFFE         ; WAIT
	include "../copperline.i"

	dc.w	$64<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8008        ; Level 2 interrupt

	dc.w	$66<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8010        ; Level 3 interrupt

	dc.w	$68<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8080        ; Level 4 interrupt

	dc.w	$6A<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8800    ; Level 5 interrupt

	dc.w	$6C<<8|HPOS, $FFFE  
	dc.w    INTREQ, $A000    ; Level 6 interrupt

 	;
    ; Section 4
	;

  	dc.w    $7039, $FFFE         ; WAIT
	include "../copperline.i"

	dc.w	$74<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8008        ; Level 2 interrupt

	dc.w	$76<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8010        ; Level 3 interrupt

	dc.w	$78<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8080        ; Level 4 interrupt

	dc.w	$7A<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8800    	; Level 5 interrupt

	dc.w	$7C<<8|HPOS, $FFFE  
	dc.w    INTREQ, $A000    	; Level 6 interrupt

	;
    ; Section 5
	;

  	dc.w    $8039, $FFFE         ; WAIT
	include "../copperline.i"

	dc.w	$84<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8008        ; Level 2 interrupt

	dc.w	$86<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8010        ; Level 3 interrupt

	dc.w	$88<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8080        ; Level 4 interrupt

	dc.w	$8A<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8800    ; Level 5 interrupt

	dc.w	$8C<<8|HPOS, $FFFE  
	dc.w    INTREQ, $A000    ; Level 6 interrupt

	;
    ; Section 6
	;

  	dc.w    $9039, $FFFE         ; WAIT
	include "../copperline.i"

	dc.w	$94<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8008           ; Level 2 interrupt

	dc.w	$96<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8010           ; Level 3 interrupt

	dc.w	$98<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8080           ; Level 4 interrupt

	dc.w	$9A<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8800           ; Level 5 interrupt

	dc.w	$9C<<8|HPOS, $FFFE  
	dc.w    INTREQ, $A000           ; Level 6 interrupt

  	;
    ; Section 7
    ;

  	dc.w    $A039, $FFFE         ; WAIT
	include "../copperline.i"

	dc.w	$A4<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8008        ; Level 2 interrupt

	dc.w	$A6<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8010        ; Level 3 interrupt

	dc.w	$A8<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8080        ; Level 4 interrupt

	dc.w	$AA<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8800    ; Level 5 interrupt

	dc.w	$AC<<8|HPOS, $FFFE  
	dc.w    INTREQ, $A000    ; Level 6 interrupt

	;
    ; Section 8
	;

  	dc.w    $B039, $FFFE         ; WAIT
	include "../copperline.i"

	dc.w	$B4<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8008           ; Level 2 interrupt

	dc.w	$B6<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8010           ; Level 3 interrupt

	dc.w	$B8<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8080           ; Level 4 interrupt

	dc.w	$BA<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8800           ; Level 5 interrupt

	dc.w	$BC<<8|HPOS, $FFFE  
	dc.w    INTREQ, $A000           ; Level 6 interrupt

 	;
    ; Section 9
    ;

  	dc.w    $C039, $FFFE         ; WAIT
	include "../copperline.i"

	dc.w	$C4<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8008        ; Level 2 interrupt

	dc.w	$C6<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8010        ; Level 3 interrupt

	dc.w	$C8<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8080        ; Level 4 interrupt

	dc.w	$CA<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8800    ; Level 5 interrupt

	dc.w	$CC<<8|HPOS, $FFFE  
	dc.w    INTREQ, $A000    ; Level 6 interrupt

	;
    ; Section 10
	;

  	dc.w    $D039, $FFFE         ; WAIT
	include "../copperline.i"

	dc.w	$D4<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8008           ; Level 2 interrupt

	dc.w	$D6<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8010           ; Level 3 interrupt

	dc.w	$D8<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8080           ; Level 4 interrupt

	dc.w	$DA<<8|HPOS, $FFFE  
	dc.w    INTREQ, $8800           ; Level 5 interrupt

	dc.w	$DC<<8|HPOS, $FFFE  
	dc.w    INTREQ, $A000           ; Level 6 interrupt

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.l    $fffffffe
spare:
	ds.w    1024,$00
bitplanes:
	ds.b    32768,$00
