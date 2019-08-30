	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
CIAAPRA             equ $BFE001	
CIABPRB             equ $BFD100	
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
entry:	
	lea	level2InterruptHandler(pc),a3
 	move.l	a3,LVL2_INT_VECTOR
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	;; install copper list and enable DMA
	lea 	CUSTOM,a1
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	; move.w #$88,intena(a1)
	
.mainLoop:
	bra.b	.mainLoop

level2InterruptHandler:
	movem.l	d0-a6,-(sp)

.checkLv2:
	lea	CUSTOM,a5
	move.w  #$F00,COLOR00(a5) 

	move.w	#$8,INTREQ(a5)	; clear interrupt bit	
	move.b  $BFEC01,d0 ; acknowledge IRQ by reading the CIA ICR reg

	move.w  #$FFF,COLOR00(a5) 

	;move.w	INTREQR(a5),d0
	;and.w	#$8,d0	
	;beq.s	.lv2InterruptComplete

;.portsInterrupt:
;	move.w  #$FFF,COLOR00(a5) 
;	move.w	#$8,INTREQ(a5)	; clear interrupt bit	
;	move.b  $BFEC01,d0 ; clear interrupt bits by reading ICR
	
.lv2InterruptComplete:
	movem.l	(sp)+,d0-a6
	rte


level3InterruptHandler:
	movem.l	d0-a6,-(sp)

.checkVerticalBlank:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_VERTB,d0	
	beq.w	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; clear interrupt bit	

	move.w  #$0F0,COLOR00(a5) ; Clear background color
	move.w #$8008,$9A(a5) ; INTENA

	;; Start CIA A timer A
	lea $bfe001,a0 ; CIA A address 
	;move.b $f00(a0),d0 ; CRB register 
	;andi.b #$c0,d0 ; mask unused bits 
	;ori.b #9,d0 ; mode one-shot 
	;move.b d0,$f00(a0) ; write back
	; move.b #$10,$600(a0) ; TALO
	move.b #$10,$700(a0) ; TBHI  3740 white, 3780 green, green = value too large
	move.b #$60,$600(a0) ; TBLO   
	move.b #$82,$C00(a0) ; enable timer interrupt
	move.b #$09,$F00(a0) ; CRB


.resetBitplanePointers:
	lea	bitplanes(pc),a1
	lea     BPL1PTH(a5),a2
	moveq	#SCREEN_BIT_DEPTH-1,d0
.bitplaneloop:
	move.l	a1,(a2)
	lea	SCREEN_WIDTH_BYTES(a1),a1 ; bit plane data is interleaved
	addq	#4,a2
	dbra	d0,.bitplaneloop
	
.checkCopper:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_COPER,d0	
	beq.s	.interruptComplete
.copperInterrupt:
	move.w	#INTF_COPER,INTREQ(a5)	; clear interrupt bit	
	
.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte

RGB: 
	DC.W    $F00, $0F0, $00F, $FF0, $0FF, $F0F, $800, $080, $008, $880, $088, $808, $444, $AAA, $400, $FFF  

copper:
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"image-copper-list-cropped.s"

    ; Switch off biplanes in Copper cycle 00 and on again in cycle 80
	;dc.w	$4001,$FFFE  ; WAIT 
	;dc.w    BPLCON0, $200 ; Bitplanes off
	;dc.w	$4081,$FFFE  ; WAIT 
	;dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$200 ; Bitplanes on

	dc.w	$ffdf,$fffe ; Cross vertical boundary

	dc.l	$fffffffe

bitplanes:
	incbin	"out/image.bin"
	