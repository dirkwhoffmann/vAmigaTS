	include "../../../include/registers.i"
	include "../../../include/ministartup.i"

LVL3_INT_VECTOR		equ $6c

; THIS MEMORY AREA NEEDS TO BE FREE FOR THE TEST TO RUN
PT1                 equ $40000
PTH1                equ $4
PT2                 equ $50000
PTH2                equ $5
PTL                 equ $0000

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

	; Install interrupt handler
	lea	    irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	; Setup bitplane pointers
	lea     copper(pc),a3

	lea     PT1,a2
	move.l 	a2,d1
	move.w	d1,2(a3)
    swap    d1
	move.w	d1,6(a3)

	lea     PT2,a2
	move.l 	a2,d1
	move.w	d1,10(a3)
    swap    d1
	move.w	d1,14(a3)

	; Clear bitplane area
	lea     PT1,a2
	lea     PT2,a3
	moveq   #0,d1
	move.w  #$FFFF,d0
.l:
	move.b  d1,(a2)+
	move.b  d1,(a3)+
	dbra    d0,.l

	; Setup bitplane data
	lea     PT1+14,a2
	moveq	#100,d0
.x1:
	move.w 	#$FFFF,(a2)+
	move.w 	#$0000,(a2)+
	add.w   #38+2,a2
	move.w 	#$FFFF,(a2)+
	move.w 	#$0000,(a2)+
	add.w   #34+2,a2
	dbra	d0,.x1

	lea     PT2+22,a2
	moveq	#100,d0
.x2:
	move.w 	#$FFFF,(a2)+
	move.w 	#$0000,(a2)+
	add.w   #38+2,a2
	move.w 	#$FFFF,(a2)+
	move.w 	#$0000,(a2)+
	add.w   #34+2,a2
	dbra	d0,.x2

	; Setup Copper
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 

	; Enable interrupts
	move.w	#$E89C,INTENA(a1)
	
.mainLoop:
	jsr     synccpu
	bra.s	.mainLoop

irq1:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	rte

irq2:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	rte

irq3:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	rte

irq4:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	rte

irq5:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	rte

irq6:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	rte

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
	dc.w    DIWSTRT,$2C81
	dc.w    DIWSTOP,$F4C1
	dc.w    BPLCON0,(2<<12)|$200
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0000
	dc.w    BPL1MOD,$0002
	dc.w    BPL2MOD,$0002
	dc.w    COLOR00,$000
	dc.w    COLOR01,$FF0
	dc.w    COLOR02,$44F
	dc.w    COLOR03,$F00

  	dc.w    $4039, $FFFE

	;
	; Round 1
	; 

	dc.w	$5000+SHIFT,$FFFE
	dc.w	COLOR00, $888
	MODIFY 2
	dc.w	COLOR00, $000

	dc.w	$5802+SHIFT, $FFFE  
	dc.w	COLOR00, $888
	MODIFY 0
	dc.w	COLOR00, $000

	dc.w	$6004+SHIFT, $FFFE  
	dc.w	COLOR00, $888
	MODIFY 2
	dc.w	COLOR00, $000

	dc.w	$6806+SHIFT, $FFFE  
	dc.w	COLOR00, $888
	MODIFY 0
	dc.w	COLOR00, $000

	dc.w	$7008+SHIFT, $FFFE  
	dc.w	COLOR00, $888
	MODIFY 2
	dc.w	COLOR00, $000

	dc.w	$780A+SHIFT, $FFFE  
	dc.w	COLOR00, $888
	MODIFY 0
	dc.w	COLOR00, $000

	;
	; Round 2
	; 
	
	dc.w	$800C+SHIFT,$FFFE
	dc.w	COLOR00, $888
	MODIFY 2
	dc.w	COLOR00, $000

	dc.w	$880E+SHIFT, $FFFE  
	dc.w	COLOR00, $888
	MODIFY 0
	dc.w	COLOR00, $000

	dc.w	$9010+SHIFT, $FFFE  
	dc.w	COLOR00, $888
	MODIFY 2
	dc.w	COLOR00, $000

	dc.w	$9812+SHIFT, $FFFE  
	dc.w	COLOR00, $888
	MODIFY 0
	dc.w	COLOR00, $000

	dc.w	$A014+SHIFT, $FFFE  
	dc.w	COLOR00, $888
	MODIFY 2
	dc.w	COLOR00, $000

	dc.w	$A816+SHIFT, $FFFE  
	dc.w	COLOR00, $888
	MODIFY 0
	dc.w	COLOR00, $000

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.l    $fffffffe
