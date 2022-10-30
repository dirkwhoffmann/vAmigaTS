	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"
	
LVL3_INT_VECTOR		equ $6c
	
MAIN:	
	; Load OCS base address
	lea CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Install interrupt handlers
	lea	    irq3(pc),a2
 	move.l	a2,LVL3_INT_VECTOR

	; Setup playfield
	move.w  #$1200,BPLCON0(a1) ; 1 bitplane
	move.w  #$0000,BPL1MOD(a1) 
	move.w  #$0000,BPLCON1(a1) ; No scroll
	move.w  #$0024,BPLCON2(a1) ; Sprites have priority over playfields
	move.w  #$0038,DDFSTRT(a1)
	move.w  #$00D0,DDFSTOP(a1)
	move.w  #$2C81,DIWSTRT(a1) 
	move.w  #$F4C1,DIWSTOP(a1)

	; Set up colors
	MOVE.W  #$000,COLOR00(a1)
	MOVE.W  #$000,COLOR01(a1)
	MOVE.W  #$FF0,COLOR17(a1)
	MOVE.W  #$0FF,COLOR18(a1)
	MOVE.W  #$F0F,COLOR19(a1)
	MOVE.W  #$FFF,COLOR20(a1)
	MOVE.W  #$88F,COLOR21(a1)
	MOVE.W  #$F88,COLOR22(a1)

	; Install Copper list
	lea    	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable Copper and bitplane DMA
	move.w  #$8100,DMACON(a1) ; Bitplane DMA
	move.w  #$8080,DMACON(a1) ; Copper DMA
	move.w  #$8200,DMACON(a1) ; DMA enable
	
	; Enable interrupts
	move.w	#$C020,INTENA(a1) 

.mainLoop:
	bra.s .mainLoop

irq3:
	movem.l	d0-a6,-(sp)
	move.w  #$0020,INTREQ(a1)   ; Acknowledge
	move.w  #$000,COLOR00(a1)

	; Reset bitplane pointers
	lea     bitplanes(pc),a2
	move.l	a2,BPL1PTH(a1)

	movem.l	(sp)+,d0-a6
	rte

;
; Copper list
;

copper:

	include "colors.s"
	dc.w    SPR7CTL,$0000

	dc.w	$3631,$FFFE
	dc.w    SPR7DATA,$FC  
	dc.w    SPR7DATB,$82A
	dc.w    $3645,$FFFE 
	dc.w    SPR7POS,$3652
	dc.w    SPR7DATA,$6000
	dc.w    $36A1,$FFFE
	dc.w    SPR7POS,$36A6
	dc.w    SPR7DATA,$C006
	dc.w    SPR7POS,$36CA
	dc.w    SPR7DATA,$1C00

	dc.w    $3731,$FFFE 
	dc.w    SPR7DATA,$FC
	dc.w    SPR7DATB,$82C
	dc.w    $3745,$FFFE
	dc.w    SPR7POS,$3753
	dc.w    SPR7DATA,$4000
	dc.w    $379F,$FFFE 
	dc.w    SPR7POS,$37A5
	dc.w    SPR7DATA,$6000
	dc.w    SPR7POS,$37C9
	dc.w    SPR7DATA,$1C00

	dc.w    $3831,$FFFE 
	dc.w    SPR7DATA,$FC
	dc.w    SPR7DATB,$82E
	dc.w    $3845,$FFFE
	dc.w    SPR7POS,$3854
	dc.w    SPR7DATA,$4000
	dc.w    $389F,$FFFE
	dc.w    SPR7POS,$38A4
	dc.w    SPR7DATA,$4006
	dc.w    SPR7POS,$38C8
	dc.w    SPR7DATA,$5A00

	dc.w    $3931,$FFFE 
	dc.w    SPR7DATA,$FC
	dc.w    SPR7DATB,$830
	dc.w    $3945,$FFFE
	dc.w    SPR7POS,$3955
	dc.w    SPR7DATA,$A000
	dc.w    $399D,$FFFE
	dc.w    SPR7POS,$39A3
	dc.w    SPR7DATA,$8018
	dc.w    SPR7POS,$39C7
	dc.w    SPR7DATA,$2D00

	dc.w    $3A31,$FFFE 
	dc.w    SPR7DATA,$FC
	dc.w    SPR7DATB,$832
	dc.w    $3A45,$FFFE
	dc.w    SPR7POS,$3A56
	dc.w    SPR7DATA,$6100
	dc.w    SPR7POS,$3AA2
	dc.w    SPR7DATA,$8
	dc.w    SPR7POS,$3AC6
	dc.w    SPR7DATA,$3F00

	dc.w    $3B01,$FFFE
	dc.w    SPR7CTL,$0

	dc.w    $FFFF,$FFFE

bitplanes:
	ds.b    51201