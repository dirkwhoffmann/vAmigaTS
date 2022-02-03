	include "../../../../include/registers.i"
	include "../../../include/ministartup.i"

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

STRIPE	MACRO
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$000
	ENDM

MAIN:	

	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Disable DMA
	move.w  #$7FFF,DMACON(a1)

	; Setup playfield
	move.w  #$0000,BPL1MOD(a1) 
	move.w  #$0000,BPLCON1(a1)
	move.w  #DDFSTRT_INI,DDFSTRT(a1)
	move.w  #DDFSTOP_INI,DDFSTOP(a1)
	move.w  #$2C81,DIWSTRT(a1) 
	move.w  #$74C1,DIWSTOP(a1)

	; Setup bitplane pointers
	lea     bitplanes,a2
	lea     copper,a3
	moveq	#5,d0
.bitplaneloop:
	move.l 	a2,d1
	move.w	d1,2(a3)
	swap	d1
	move.w  d1,6(a3)
	addq	#8,a3
	dbra	d0,.bitplaneloop

	; Setup bitplane data
	lea bitplanes(pc),a0 
	move.w #2048,d0
.loop:
	move.l #$AAAAAAAA,(a0)+
	dbra d0,.loop
	
	; Install copper list
	lea		copper,a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w  #$8080,DMACON(a1)  ; Copper DMA
	move.w  #$8100,DMACON(a1)  ; Bitplane DMA
	move.w  #$8200,DMACON(a1)  ; DMA enable

;
; Main loop
;

mainLoop: 

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

cpuwait:
	bra     mainLoop


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
	dc.w    COLOR00,$000
	dc.w    COLOR31,$555
	dc.w    BPLCON0,$0020

	dc.w    $4C01,$FFFE
	dc.w    BPLCON0,BPLCON0_INI

	; ROUND 1

	dc.w    $4E39,$FFFE    ; WAIT
	RULER

	dc.w    $5031,$FFFE    ; WAIT
	dc.w    $50FF,$FF03    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $5231,$FFFE    ; WAIT
	dc.w    $52FF,$FF05    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $5431,$FFFE    ; WAIT
	dc.w    $54FF,$FF09    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $5631,$FFFE    ; WAIT
	dc.w    $56FF,$FF11    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $5831,$FFFE    ; WAIT
	dc.w    $58FF,$FF21    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $5A31,$FFFE    ; WAIT
	dc.w    $5AFF,$FF41    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $5C31,$FFFE    ; WAIT
	dc.w    $5CFF,$FF81    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	; ROUND 2

	dc.w    $5E39,$FFFE    ; WAIT
	RULER

	dc.w    $6033,$FFFE    ; WAIT
	dc.w    $60FF,$FF03    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $6233,$FFFE    ; WAIT
	dc.w    $62FF,$FF05    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $6433,$FFFE    ; WAIT
	dc.w    $64FF,$FF09    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $6633,$FFFE    ; WAIT
	dc.w    $66FF,$FF11    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $6833,$FFFE    ; WAIT
	dc.w    $68FF,$FF21    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $6A33,$FFFE    ; WAIT
	dc.w    $6AFF,$FF41    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $6C33,$FFFE    ; WAIT
	dc.w    $6CFF,$FF81    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	; ROUND 3

	dc.w    $6E39,$FFFE    ; WAIT
	RULER

	dc.w    $7035,$FFFE    ; WAIT
	dc.w    $70FF,$FF03    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $7235,$FFFE    ; WAIT
	dc.w    $72FF,$FF05    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $7435,$FFFE    ; WAIT
	dc.w    $74FF,$FF09    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $7635,$FFFE    ; WAIT
	dc.w    $76FF,$FF11    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $7835,$FFFE    ; WAIT
	dc.w    $78FF,$FF21    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $7A35,$FFFE    ; WAIT
	dc.w    $7AFF,$FF41    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $7C35,$FFFE    ; WAIT
	dc.w    $7CFF,$FF81    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	; ROUND 4

	dc.w    $7E39,$FFFE    ; WAIT
	RULER

	dc.w    $8037,$FFFE    ; WAIT
	dc.w    $80FF,$FF03    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $8237,$FFFE    ; WAIT
	dc.w    $82FF,$FF05    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $8437,$FFFE    ; WAIT
	dc.w    $84FF,$FF09    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $8637,$FFFE    ; WAIT
	dc.w    $86FF,$FF11    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $8837,$FFFE    ; WAIT
	dc.w    $88FF,$FF21    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $8A37,$FFFE    ; WAIT
	dc.w    $8AFF,$FF41    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $8C37,$FFFE    ; WAIT
	dc.w    $8CFF,$FF81    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	; ROUND 5

	dc.w    $8E39,$FFFE    ; WAIT
	RULER

	dc.w    $9039,$FFFE    ; WAIT
	dc.w    $90FF,$FF03    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $9239,$FFFE    ; WAIT
	dc.w    $92FF,$FF05    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $9439,$FFFE    ; WAIT
	dc.w    $94FF,$FF09    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $9639,$FFFE    ; WAIT
	dc.w    $96FF,$FF11    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $9839,$FFFE    ; WAIT
	dc.w    $98FF,$FF21    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $9A39,$FFFE    ; WAIT
	dc.w    $9AFF,$FF41    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $9C39,$FFFE    ; WAIT
	dc.w    $9CFF,$FF81    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	; ROUND 6

	dc.w    $9E39,$FFFE    ; WAIT
	RULER

	dc.w    $A03B,$FFFE    ; WAIT
	dc.w    $A0FF,$FF03    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $A23B,$FFFE    ; WAIT
	dc.w    $A2FF,$FF05    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $A43B,$FFFE    ; WAIT
	dc.w    $A4FF,$FF09    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $A63B,$FFFE    ; WAIT
	dc.w    $A6FF,$FF11    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $A83B,$FFFE    ; WAIT
	dc.w    $A8FF,$FF21    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $AA3B,$FFFE    ; WAIT
	dc.w    $AAFF,$FF41    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $AC3B,$FFFE    ; WAIT
	dc.w    $ACFF,$FF81    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	; ROUND 7

	dc.w    $AE39,$FFFE    ; WAIT
	RULER

	dc.w    $B03D,$FFFE    ; WAIT
	dc.w    $B0FF,$FF03    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $B23D,$FFFE    ; WAIT
	dc.w    $B2FF,$FF05    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $B43D,$FFFE    ; WAIT
	dc.w    $B4FF,$FF09    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $B63D,$FFFE    ; WAIT
	dc.w    $B6FF,$FF11    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $B83D,$FFFE    ; WAIT
	dc.w    $B8FF,$FF21    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $BA3D,$FFFE    ; WAIT
	dc.w    $BAFF,$FF41    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	dc.w    $BC3D,$FFFE    ; WAIT
	dc.w    $BCFF,$FF81    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$88F
	dc.w    COLOR00,$000

	; ROUND 8

	dc.w    $BE39,$FFFE    ; WAIT
	RULER

	dc.w    $C03F,$FFFE    ; WAIT
	dc.w    $C0FF,$FF03    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $C23F,$FFFE    ; WAIT
	dc.w    $C2FF,$FF05    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $C43F,$FFFE    ; WAIT
	dc.w    $C4FF,$FF09    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $C63F,$FFFE    ; WAIT
	dc.w    $C6FF,$FF11    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $C83F,$FFFE    ; WAIT
	dc.w    $C8FF,$FF21    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $CA3F,$FFFE    ; WAIT
	dc.w    $CAFF,$FF41    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w    $CC3F,$FFFE    ; WAIT
	dc.w    $CCFF,$FF81    ; SKIP
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$F88
	dc.w    COLOR00,$000

	dc.w	$ffdf,$fffe    ; Cross vertical boundary
	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
