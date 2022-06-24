
	include "../../../include/registers.i"
	include "../../../include/ministartup.i"
	
DDFSTRTINI			equ $38
DDFSTOPINI			equ $a8
BPLDMAON          	equ $8100
BPLDMAOFF         	equ $0100
LVL3_INT_VECTOR		equ $6c

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
	;lea	    irq3(pc),a3
 	;move.l	a3,LVL3_INT_VECTOR

	; Setup Copper
	lea	    copper,a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Setup colors
	move.w  #$000,COLOR00(a1)
	move.w  #$8AF,COLOR01(a1)
	move.w  #$CC4,COLOR02(a1)
	move.w  #$C44,COLOR03(a1)

	; Setup bitplane pointers
	lea     copper,a3

	lea     bitplane1(pc),a2
	move.l 	a2,d1
	move.w	d1,2(a3)
    swap    d1
	move.w	d1,6(a3)

	lea     bitplane2(pc),a2
	move.l 	a2,d1
	move.w	d1,10(a3)
    swap    d1
	move.w	d1,14(a3)

	; Setup bitplane data
	;lea     bitplane1+4,a2
	;bsr		setup  

	lea     bitplane1+12,a2
	bsr		setup  

	lea     bitplane2+20,a2
	bsr     setup

	;lea     bitplane2+28,a2
	;bsr		setup  

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 

	; Enable interrupts
	;move.w	#$C020,INTENA(a1)

.mainLoop:
	bra.b	.mainLoop

setup:
	moveq	#100,d0
.loop:
	move.w 	#$FFFF,(a2)+
	move.w 	#$0000,(a2)+
	add.w   #26+2,a2
	move.w 	#$FFFF,(a2)+
	move.w 	#$0000,(a2)+
	add.w   #22+2,a2
	dbra	d0,.loop
	rts

irq3:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	rte

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
	dc.w  	DDFSTRT,$0038
	dc.w  	DDFSTOP,$00A8
	dc.w  	BPLCON0,$2200
	dc.w  	BPL1MOD,0
	dc.w  	BPL2MOD,0
	dc.w    DDFSTRT,DDFSTRTINI
	dc.w    DDFSTOP,DDFSTOPINI
	dc.w    DIWSTRT,$3a81
	dc.w	DIWSTOP,$1ac1

	dc.w	$3839,$FFFE  ; WAIT 
	RULER

	dc.w	$4051,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w	$4081,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$4453,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w	$4481,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$4855,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w	$4881,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$4C57,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w	$4C81,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$5059,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w	$5081,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$545B,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w	$5481,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$585D,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w	$5881,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$5C5F,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w	$5C81,$FFFE  
	dc.w    DMACON,BPLDMAON


	;
	;
	;

	dc.w    $ffdf,$fffe  ; Cross vertical boundary

	dc.w	$0639,$FFFE  ; WAIT 
	RULER

	dc.l	$fffffffe

bitplane1:
	ds.b    16384,$00
bitplane2:
	ds.b    16384,$00
	
