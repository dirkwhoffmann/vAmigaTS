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
	move.b  #$7F,$BFDD00
	move.b  #$7F,$BFED01

	; Setup bitplane pointers
	lea     copper(pc),a3
	lea     bitplane(pc),a2
	move.l 	a2,d1
	move.w	d1,2(a3)
    swap    d1
	move.w	d1,6(a3)

	; Setup bitplane data
	lea     bitplane,a2
	move.l	#4096,d0
.x1:
	move.l 	#$AAAAAAAA,(a2)+
	dbra	d0,.x1

	; Setup Copper
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 

.mainLoop:
	bra.s	.mainLoop

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

RESTORE	MACRO
	dc.w    DDFSTRT,$38
	dc.w    DDFSTOP,$B0
	dc.w    COLOR01,$000	
	ENDM

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
	dc.w    DIWSTRT,$4181
	dc.w    DIWSTOP,$F4C1
	dc.w    BPLCON0,(1<<12)|$200
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0000
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000
	dc.w    COLOR00,$000
	RESTORE

	;
	; Round 1: Double match when DMA is on
	; 

  	dc.w    $4039, $FFFE
	RULER

	dc.w	$4201,$FFFE  
	RESTORE
	dc.w	$4301,$FFFE  
	dc.w    COLOR01,$44F
	dc.w    DDFSTRT,$58
	dc.w    DDFSTOP,$58

	dc.w	$4401,$FFFE  
	RESTORE
	dc.w	$4501,$FFFE  
	dc.w    COLOR01,$44F
	dc.w    DDFSTRT,$5A
	dc.w    DDFSTOP,$5A

	dc.w	$4601,$FFFE  
	RESTORE
	dc.w	$4701,$FFFE  
	dc.w    COLOR01,$84F
	dc.w    DDFSTRT,$5C
	dc.w    DDFSTOP,$5C

	dc.w	$4801,$FFFE  
	RESTORE
	dc.w	$4901,$FFFE  
	dc.w    COLOR01,$84F
	dc.w    DDFSTRT,$5E
	dc.w    DDFSTOP,$5E

	dc.w	$4A01,$FFFE  
	RESTORE
	dc.w	$4B01,$FFFE  
	dc.w    COLOR01,$84F
	dc.w    DDFSTRT,$60
	dc.w    DDFSTOP,$60

	dc.w	$4C01,$FFFE  
	RESTORE
	dc.w	$4D01,$FFFE  
	dc.w    COLOR01,$84F
	dc.w    DDFSTRT,$62
	dc.w    DDFSTOP,$62

	dc.w	$4E01,$FFFE  
	RESTORE
	dc.w	$4F01,$FFFE  
	dc.w    COLOR01,$F4F
	dc.w    DDFSTRT,$64
	dc.w    DDFSTOP,$64

	dc.w	$5001,$FFFE  
	RESTORE
	dc.w	$5101,$FFFE  
	dc.w    COLOR01,$F4F
	dc.w    DDFSTRT,$66
	dc.w    DDFSTOP,$66

	dc.w	$5201,$FFFE  
	RESTORE

	;
	; Round 2: Double match when DMA is on
	; 

  	dc.w    $7039, $FFFE
	RULER

	dc.w	$7201,$FFFE  
	RESTORE
	dc.w	$7301,$FFFE  
	dc.w    COLOR01,$44F
	dc.w	$7349,$FFFE  
	dc.w    DDFSTRT,$58
	dc.w    DDFSTOP,$58

	dc.w	$7401,$FFFE  
	RESTORE
	dc.w	$7501,$FFFE  
	dc.w    COLOR01,$44F
	dc.w	$7549,$FFFE  
	dc.w    DDFSTRT,$5A
	dc.w    DDFSTOP,$5A

	dc.w	$7601,$FFFE  
	RESTORE
	dc.w	$7701,$FFFE  
	dc.w    COLOR01,$84F
	dc.w	$7749,$FFFE  
	dc.w    DDFSTRT,$5C
	dc.w    DDFSTOP,$5C

	dc.w	$7801,$FFFE  
	RESTORE
	dc.w	$7901,$FFFE  
	dc.w    COLOR01,$84F
	dc.w	$7949,$FFFE  
	dc.w    DDFSTRT,$5E
	dc.w    DDFSTOP,$5E

	dc.w	$7A01,$FFFE  
	RESTORE
	dc.w	$7B01,$FFFE  
	dc.w    COLOR01,$84F
	dc.w	$7B49,$FFFE  
	dc.w    DDFSTRT,$60
	dc.w    DDFSTOP,$60

	dc.w	$7C01,$FFFE  
	RESTORE
	dc.w	$7D01,$FFFE  
	dc.w    COLOR01,$84F
	dc.w	$7D49,$FFFE  
	dc.w    DDFSTRT,$62
	dc.w    DDFSTOP,$62

	dc.w	$7E01,$FFFE  
	RESTORE
	dc.w	$7F01,$FFFE  
	dc.w    COLOR01,$F4F
	dc.w	$7F49,$FFFE  
	dc.w    DDFSTRT,$64
	dc.w    DDFSTOP,$64

	dc.w	$8001,$FFFE  
	RESTORE
	dc.w	$8101,$FFFE  
	dc.w    COLOR01,$F4F
	dc.w	$8149,$FFFE  
	dc.w    DDFSTRT,$66
	dc.w    DDFSTOP,$66

	dc.w	$8201,$FFFE  
	RESTORE


	; Cross vertical boundary
	dc.w    $ffdf,$fffe 
	dc.l    $fffffffe

bitplane:
	ds.b    16384,$00
