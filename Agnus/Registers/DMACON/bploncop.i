	include "../../../include/registers.i"
	include "../../../include/ministartup.i"

BPLDMAON          equ $8100
BPLDMAOFF         equ $0100

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
	jsr     synccpu
	bra.s	.mainLoop

synccpu:
	lea     VHPOSR(a1),a3      ; VHPOSR     

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
	dc.w    DDFSTRT,DDFSTRTINI
	dc.w    DDFSTOP,DDFSTOPINI
	dc.w    DIWSTRT,$4181
	dc.w    DIWSTOP,$F4C1
	dc.w    BPLCON0,(1<<12)|$200
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0000
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000
	dc.w    COLOR00,$000
	dc.w    COLOR01,$000

	;
	; DDFSTRT
	; 

  	dc.w    $4039, $FFFE
	RULER

	dc.w	$4201,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w    COLOR01,$000	
	dc.w	$4301,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$433D,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$4401,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w    COLOR01,$000	
	dc.w	$4501,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$453F,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$4601,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w    COLOR01,$000	
	dc.w	$4701,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$4741,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$4801,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w    COLOR01,$000	
	dc.w	$4901,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$4943,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$4A01,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w    COLOR01,$000	
	dc.w	$4B01,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$4B45,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$4C01,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w    COLOR01,$000	
	dc.w	$4D01,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$4D47,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$4E01,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w    COLOR01,$000	
	dc.w	$4F01,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$4F49,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$5001,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w    COLOR01,$000	
	dc.w	$5101,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$514B,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$5201,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w    COLOR01,$000	
	dc.w	$5301,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$534D,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$5401,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w    COLOR01,$000	
	dc.w	$5501,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$554F,$FFFE  
	dc.w    DMACON,BPLDMAON

	dc.w	$5601,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w    COLOR01,$000	

	;
	; DDFSTOP
	; 

  	dc.w    $6039, $FFFE
	RULER

	dc.w	$6201,$FFFE  
	dc.w    DMACON,BPLDMAON
	dc.w    COLOR01,$000	
	dc.w	$6301,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$639D,$FFFE  
	dc.w    DMACON,BPLDMAOFF

	dc.w	$6401,$FFFE  
	dc.w    DMACON,BPLDMAON
	dc.w    COLOR01,$000	
	dc.w	$6501,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$659F,$FFFE  
	dc.w    DMACON,BPLDMAOFF

	dc.w	$6601,$FFFE  
	dc.w    DMACON,BPLDMAON
	dc.w    COLOR01,$000	
	dc.w	$6701,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$67A1,$FFFE  
	dc.w    DMACON,BPLDMAOFF

	dc.w	$6801,$FFFE  
	dc.w    DMACON,BPLDMAON
	dc.w    COLOR01,$000	
	dc.w	$6901,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$69A3,$FFFE  
	dc.w    DMACON,BPLDMAOFF

	dc.w	$6A01,$FFFE  
	dc.w    DMACON,BPLDMAON
	dc.w    COLOR01,$000	
	dc.w	$6B01,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$6BA5,$FFFE  
	dc.w    DMACON,BPLDMAOFF

	dc.w	$6C01,$FFFE  
	dc.w    DMACON,BPLDMAON
	dc.w    COLOR01,$000	
	dc.w	$6D01,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$6DA7,$FFFE  
	dc.w    DMACON,BPLDMAOFF

	dc.w	$6E01,$FFFE  
	dc.w    DMACON,BPLDMAON
	dc.w    COLOR01,$000	
	dc.w	$6F01,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$6FA9,$FFFE  
	dc.w    DMACON,BPLDMAOFF

	dc.w	$7001,$FFFE  
	dc.w    DMACON,BPLDMAON
	dc.w    COLOR01,$000	
	dc.w	$7101,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$71AB,$FFFE  
	dc.w    DMACON,BPLDMAOFF

	dc.w	$7201,$FFFE  
	dc.w    DMACON,BPLDMAON
	dc.w    COLOR01,$000	
	dc.w	$7301,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$73AD,$FFFE  
	dc.w    DMACON,BPLDMAOFF

	dc.w	$7401,$FFFE  
	dc.w    DMACON,BPLDMAON
	dc.w    COLOR01,$000	
	dc.w	$7501,$FFFE  
	dc.w    COLOR01,COL
	dc.w	$75AF,$FFFE  
	dc.w    DMACON,BPLDMAOFF

	dc.w	$7601,$FFFE  
	dc.w    DMACON,BPLDMAOFF
	dc.w    COLOR01,$000	

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 
	dc.l    $fffffffe

bitplane:
	ds.b    16384,$00
