	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78

MAIN:

	; Load OCS base address
	lea CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Install exception handlers
	lea	irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

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
	
	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	; move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 

	; Enable Interrupts
	move.w 	#$8020,INTENA(a1)   ; Level 3 (VERTB)
	move.w 	#$C000,INTENA(a1)   ; INTEN

.mainLoop:
	bra.s	.mainLoop

color0:
	dc.w   $FF0
	dc.w   $FF0
color1:
	dc.w   $4F4
	dc.w   $4F4

chkex: 
    move.w  #$FFF,COLOR00(a1)
    move.w  #$00F,COLOR00(a1)
    move.w  #$FF0,COLOR00(a1)
	rte

irq3:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge

synccpu:
	lea     VHPOSR(a1),a3     ; VHPOSR     

	; Wait until we have reached the middle of a frame
.loop 
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$3000,d2
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
  	moveq #10,d2
.adjust:
    dbra d2,.adjust

	; Sync vertically
.synccpu4:
	nop 
	move.w  #$404,COLOR00(a1)
	ds.w    96,$4E71          ; NOPs to keep the horizontal position in each iteration
	move.w  (a3),d2     
	move.w  #$F0F,COLOR00(a1)  
	and     #$FF00,d2
	cmp.w   #$4000,d2
	bne     .synccpu4
	move.w  #$000,COLOR00(a1)

    ; Setup some test values
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

    include "colors.s"
	
	dc.w	BPLCON0,(0<<12)|$200 
	dc.w    DDFSTRT,$18
	dc.w    DDFSTOP,$E0 

	dc.w    $4F39, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000

	dc.w    $5001, $FFFE         ; Wait
	dc.w	BPLCON0,(6<<12)|$200 

	dc.w    $8989, $FFFE         ; Wait
	dc.w    DPL1DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $8B8B, $FFFE       ; Wait
	dc.w    DPL2DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $8D8D, $FFFE         ; Wait
	dc.w    DPL3DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $8F8F, $FFFE         ; Wait
	dc.w    DPL4DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $9191, $FFFE         ; Wait
	dc.w    DPL5DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $9393, $FFFE         ; Wait
	dc.w    DPL6DATA,$CCCC
	dc.w    DPL1DATA,$F00F

	dc.w    $9595, $FFFE         ; Wait
	dc.w    DPL1DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $9797, $FFFE       ; Wait
	dc.w    DPL2DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $9999, $FFFE         ; Wait
	dc.w    DPL3DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $9B9B, $FFFE         ; Wait
	dc.w    DPL4DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $9D9D, $FFFE         ; Wait
	dc.w    DPL5DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $9F9F, $FFFE         ; Wait
	dc.w    DPL6DATA,$CCCC
	dc.w    DPL1DATA,$F00F

	dc.w    $A1A1, $FFFE         ; Wait
	dc.w    DPL1DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $A3A3, $FFFE         ; Wait
	dc.w    DPL2DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $A5A5, $FFFE         ; Wait
	dc.w    DPL3DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $A7A7, $FFFE         ; Wait
	dc.w    DPL4DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $A9A9, $FFFE         ; Wait
	dc.w    DPL5DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $ABAB, $FFFE         ; Wait
	dc.w    DPL6DATA,$CCCC
	dc.w    DPL1DATA,$F00F

	dc.w    $ADAD, $FFFE         ; Wait
	dc.w    DPL1DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $AFAF, $FFFE         ; Wait
	dc.w    DPL2DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $B1B1, $FFFE         ; Wait
	dc.w    DPL3DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $B3B3, $FFFE         ; Wait
	dc.w    DPL4DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $B5B5, $FFFE         ; Wait
	dc.w    DPL5DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $B7B7, $FFFE         ; Wait
	dc.w    DPL6DATA,$CCCC
	dc.w    DPL1DATA,$F00F

	dc.w    $B9B9, $FFFE         ; Wait
	dc.w    DPL1DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $BBBB, $FFFE         ; Wait
	dc.w    DPL2DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $BDBD, $FFFE         ; Wait
	dc.w    DPL3DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $BFBF, $FFFE         ; Wait
	dc.w    DPL4DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $C1C1, $FFFE         ; Wait
	dc.w    DPL5DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $C3C3, $FFFE         ; Wait
	dc.w    DPL6DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	
	dc.w    $C5C5, $FFFE         ; Wait
	dc.w    DPL1DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $C7C7, $FFFE         ; Wait
	dc.w    DPL2DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $C9C9, $FFFE         ; Wait
	dc.w    DPL3DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $CBCB, $FFFE         ; Wait
	dc.w    DPL4DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $CDCD, $FFFE         ; Wait
	dc.w    DPL5DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $CFCF, $FFFE         ; Wait
	dc.w    DPL6DATA,$CCCC
	dc.w    DPL1DATA,$F00F

	dc.w    $D1D1, $FFFE         ; Wait
	dc.w    DPL1DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $D3D3, $FFFE         ; Wait
	dc.w    DPL2DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $D5D5, $FFFE         ; Wait
	dc.w    DPL3DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $D7D7, $FFFE         ; Wait
	dc.w    DPL4DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $D9D9, $FFFE         ; Wait
	dc.w    DPL5DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $DBDB, $FFFE         ; Wait
	dc.w    DPL6DATA,$CCCC
	dc.w    DPL1DATA,$F00F

	dc.w    $DDDD, $FFFE         ; Wait
	dc.w    DPL1DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $DFDF, $FFFE         ; Wait
	dc.w    DPL2DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $E1E1, $FFFE         ; Wait
	dc.w    DPL3DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $E301, $FFFE         ; Wait
	dc.w    DPL4DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $E503, $FFFE         ; Wait
	dc.w    DPL5DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $E705, $FFFE         ; Wait
	dc.w    DPL6DATA,$CCCC
	dc.w    DPL1DATA,$F00F

	dc.w    $E907, $FFFE         ; Wait
	dc.w    DPL1DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $EB09, $FFFE         ; Wait
	dc.w    DPL2DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $ED0B, $FFFE         ; Wait
	dc.w    DPL3DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $EF0D, $FFFE         ; Wait
	dc.w    DPL4DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $F10F, $FFFE         ; Wait
	dc.w    DPL5DATA,$CCCC
	dc.w    DPL1DATA,$F00F
	dc.w    $F311, $FFFE         ; Wait
	dc.w    DPL6DATA,$CCCC
	dc.w    DPL1DATA,$F00F

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
	