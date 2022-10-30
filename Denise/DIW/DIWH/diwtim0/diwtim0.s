
_DIWSTRT1				equ $2c61
_DIWSTRT2				equ $2c81
_DIWSTOP1				equ $2c61			 
_DIWSTOP2				equ $2c81			 

	include "../../../include/registers.i"
	include "../../../include/ministartup.i"
	
LVL3_INT_VECTOR		equ $6c
	
MAIN:
	; Load OCS base address
	lea     CUSTOM,a1
	
	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$0200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00
	move.b  #$7F,$BFED01

	; Install interrupt handlers
	lea	    irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	; Setup Copper
	lea	    copper,a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Setup colors
	move.w  #$000,COLOR00(a1)
	move.w  #$8AF,COLOR01(a1)
	move.w  #$CC4,COLOR02(a1)

	; Setup bitplane data
	moveq   #7,d3
	lea     bitplanes1,a2
.x1:
	move.l	#252,d0
.x2:
	move.l 	#$AAAAAAAA,(a2)+
	dbra	d0,.x2
	move.l	#252,d0
.x3:
	move.l 	#$00000000,(a2)+
	dbra	d0,.x3
	dbra    d3,.x1

	moveq   #7,d3
	lea     bitplanes2,a2
.y1:
	move.l	#252,d0
.y2:
	move.l 	#$00000000,(a2)+
	dbra	d0,.y2
	move.l	#252,d0
.y3:
	move.l 	#$AAAAAAAA,(a2)+
	dbra	d0,.y3
	dbra    d3,.y1

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 

	; Enable interrupts
	move.w	#$C020,INTENA(a1)

.mainLoop:
	bra.b	.mainLoop

irq3:
	movem.l	d0-a6,-(sp)

	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	move.w  #$0030,DDFSTRT(a1)
	move.w  #$00D8,DDFSTOP(a1)
	; move.w  #$2200,BPLCON0(a1)        ; 1 Bitplane
	move.w  #0,BPL1MOD(a1)
	move.w  #0,BPL2MOD(a1)

	lea	    bitplanes1(pc),a2
	move.l  a2,BPL1PTH(a1)
	lea	    bitplanes2(pc),a2
	move.l  a2,BPL2PTH(a1)

	movem.l	(sp)+,d0-a6
	rte

bitplanes1:
	ds.b    16384,$00
bitplanes2:
	ds.b    16384,$00

copper:
	dc.w    DIWSTRT,_DIWSTRT1
	dc.w	DIWSTOP,_DIWSTOP1
	dc.w    BPLCON0,$2200

	;
    ; Round 1
	; 

	dc.w	$4001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$4101,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$42A1,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP1
	dc.w	$43A1,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP2

	dc.w	$44A3,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP1
	dc.w	$45A3,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP2

	dc.w	$46A5,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP1
	dc.w	$47A5,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP2

	dc.w	$48A7,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP1
	dc.w	$49A7,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP2

	dc.w	$4AA9,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP1
	dc.w	$4BA9,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP2

	dc.w	$4CAB,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP1
	dc.w	$4DAB,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP2

	dc.w	$4EAD,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP1
	dc.w	$4FAD,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP2

	dc.w	$50AF,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP1
	dc.w	$51AF,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP2

	dc.w	$52B1,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP1
	dc.w	$53B1,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP2

	dc.w	$54B3,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP1
	dc.w	$55B3,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP2

	dc.w	$56B5,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP1
	dc.w	$57B5,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP2

	dc.w	$58B7,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP1
	dc.w	$59B7,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP2

	;
    ; Round 2
	; 

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP1
	dc.w	COLOR00, $F00
	dc.w	$6101,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$6221,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT1
	dc.w	$6321,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT2

	dc.w	$6423,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT1
	dc.w	$6523,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT2

	dc.w	$6625,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT1
	dc.w	$6725,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT2

	dc.w	$6827,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT1
	dc.w	$6927,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT2

	dc.w	$6A29,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT1
	dc.w	$6B29,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT2

	dc.w	$6C2B,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT1
	dc.w	$6D2B,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT2

	dc.w	$6E2D,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT1
	dc.w	$6F2D,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT2

	dc.w	$702F,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT1
	dc.w	$712F,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT2

	dc.w	$7231,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT1
	dc.w	$7331,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT2

	dc.w	$7433,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT1
	dc.w	$7533,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT2

	dc.w	$7635,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT1
	dc.w	$7735,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT2

	dc.w	$7837,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT1
	dc.w	$7937,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT2

	dc.w	$8001,$FFFE  ; WAIT 
	dc.w    BPLCON0,$0200

	dc.l	$fffffffe
	