	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
CIAAPRA             equ $BFE001	
CIABPRB             equ $BFD100	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
entry:	
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	;; install copper list and enable DMA
	lea 	CUSTOM,a1
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	
.mainLoop:
	bra.b	.mainLoop

level3InterruptHandler:
	movem.l	d0-a6,-(sp)

.checkVerticalBlank:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_VERTB,d0	
	beq.w	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; clear interrupt bit	

.check1:
	
	; Check the first fire button
	move.b CIAAPRA,d0
	and.b #$40,d0
	move.b d0,CIAAPRA
	beq .select0

	; Deselect drive 0
	or.b #$08,CIABPRB
	jmp .check2

.select0:

	; Select drive 0
	and.b #$F7,CIABPRB

.check2: 

	; Check the second fire button
	move.b CIAAPRA,d0
	and.b #$80,d0
	move.b d0,CIAAPRA
	beq .select1

	; Deselect drive 1
	or.b #$10,CIABPRB
	jmp .cont

.select1: 

	; select drive 1
	and.b #$EF,CIABPRB

.cont: 

	; Read PRA from CIA A
	move.b CIAAPRA,d0
	
	; Make bits 0-3 visible in COLOR00
	lea    RGB(pc),a1
	move.l d0,d1
	and.w #$F,d1
	;move.w #$02,d1 ; REMOVE
	rol.w  #$1,d1
	add.w d1,a1
	move.w (a1),COLOR00(a5) 

	; Make bits 4-7 visible in COLOR01
	lea    RGB(pc),a1
	move.l d0,d1
	ror.l #4,d1
	and.w #$F,d1
	;move.w #$0F,d1 ; REMOVE
	rol.w  #$1,d1
	add.w d1,a1
	move.w (a1),COLOR01(a5) 

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
 
 	include	"out/image-copper-list.s"

    ; Switch off biplanes in Copper cycle 00 and on again in cycle 80
	;dc.w	$4001,$FFFE  ; WAIT 
	;dc.w    BPLCON0, $200 ; Bitplanes off
	;dc.w	$4081,$FFFE  ; WAIT 
	;dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$200 ; Bitplanes on

	dc.w	$ffdf,$fffe ; Cross vertical boundary

	dc.l	$fffffffe

bitplanes:
	incbin	"out/image.bin"
	