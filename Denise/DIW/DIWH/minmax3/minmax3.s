
_DIWSTRT				equ $2cff
_DIWSTOP				equ $2c61

DIWHIGH					equ $1e4

	include "../../../../include/registers.i"
	include "../../../../include/ministartup.i"
	
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
	dc.w    DIWSTRT,_DIWSTRT
	dc.w	DIWSTOP,_DIWSTOP
	dc.w    BPLCON0,$2200

	;
    ; Round 1
	; 

	dc.w	$4001,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP
	dc.w	COLOR00, $F00
	dc.w	$4101,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4281,$FFFE  ; WAIT 
	dc.w    DIWSTOP,$2cc0
	dc.w	$4301,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP

	dc.w	$4481,$FFFE  ; WAIT 
	dc.w    DIWSTOP,$2cc1
	dc.w	$4501,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP

	dc.w	$4681,$FFFE  ; WAIT 
	dc.w    DIWSTOP,$2cc2
	dc.w	$4701,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP

	dc.w	$4881,$FFFE  ; WAIT 
	dc.w    DIWSTOP,$2cc3
	dc.w	$4901,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP

	dc.w	$4A81,$FFFE  ; WAIT 
	dc.w    DIWSTOP,$2cc4
	dc.w	$4B01,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP

	dc.w	$4C81,$FFFE  ; WAIT 
	dc.w    DIWSTOP,$2cc5
	dc.w	$4D01,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP

	dc.w	$4E81,$FFFE  ; WAIT 
	dc.w    DIWSTOP,$2cc6
	dc.w	$4F01,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP

	dc.w	$5081,$FFFE  ; WAIT 
	dc.w    DIWSTOP,$2cc7
	dc.w	$5101,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP

	dc.w	$5281,$FFFE  ; WAIT 
	dc.w    DIWSTOP,$2cc8
	dc.w	$5301,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP

	dc.w	$5481,$FFFE  ; WAIT 
	dc.w    DIWSTOP,$2c01
	dc.w    DIWHIGH,$0000
	dc.w	$5501,$FFFE  ; WAIT 
	dc.w    DIWHIGH,$2100
	dc.w    DIWSTOP,_DIWSTOP

	dc.w	$5681,$FFFE  ; WAIT 
	dc.w    DIWSTOP,$2c02
	dc.w    DIWHIGH,$0000
	dc.w	$5701,$FFFE  ; WAIT 
	dc.w    DIWHIGH,$2100
	dc.w    DIWSTOP,_DIWSTOP

	dc.w	$5881,$FFFE  ; WAIT 
	dc.w    DIWSTOP,$2c03
	dc.w    DIWHIGH,$0000
	dc.w	$5901,$FFFE  ; WAIT 
	dc.w    DIWHIGH,$2100
	dc.w    DIWSTOP,_DIWSTOP

	dc.w	$5A81,$FFFE  ; WAIT 
	dc.w    DIWSTOP,$2cc7
	dc.w	$5B01,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP

	;
    ; Round 2
	; 

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w    DIWSTOP,_DIWSTOP
	dc.w	COLOR00, $F00
	dc.w	$6101,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$6281,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2c00
	dc.w	$6301,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT

	dc.w	$6481,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2c01
	dc.w	$6501,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT

	dc.w	$6681,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2c02
	dc.w	$6701,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT

	dc.w	$6881,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2c03
	dc.w	$6901,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT

	dc.w	$6A81,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2c04
	dc.w	$6B01,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT

	dc.w	$6C81,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2c05
	dc.w	$6D01,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT

	dc.w	$6E81,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2c06
	dc.w	$6F01,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT

	dc.w	$7081,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2c07
	dc.w	$7101,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT

	dc.w	$7281,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2c08
	dc.w	$7301,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT

	dc.w	$7481,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2c09
	dc.w	$7501,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT

	dc.w	$7681,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2c0A
	dc.w	$7701,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT

	dc.w	$7881,$FFFE  ; WAIT 
	dc.w    DIWSTRT,$2c0B
	dc.w	$7901,$FFFE  ; WAIT 
	dc.w    DIWSTRT,_DIWSTRT

	dc.w	$8001,$FFFE  ; WAIT 
	dc.w    BPLCON0,$0200

	dc.l	$fffffffe
	