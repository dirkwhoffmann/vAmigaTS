	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 6
	
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
	; beq.s	.checkCopper
	bne.s	.verticalBlank
	jmp .checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; clear interrupt bit	

.checkDENISEID:

	; Read test register
	move.w $DFF004,d0

.test0:
	lea	bit0(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #0,d0
	beq.s .test1
	move.w #$CCC,(a0)

.test1:
	lea	bit1(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #1,d0
	beq.s .test2
	move.w #$CCC,(a0)

.test2:
	lea	bit2(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #2,d0
	beq.s .test3
	move.w #$CCC,(a0)

.test3:
	lea	bit3(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #3,d0
	beq.s .test4
	move.w #$CCC,(a0)

.test4:
	lea	bit4(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #4,d0
	beq.s .test5
	move.w #$CCC,(a0)

.test5:
	lea	bit5(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #5,d0
	beq.s .test6
	move.w #$CCC,(a0)

.test6:
	lea	bit6(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #6,d0
	beq.s .test7
	move.w #$CCC,(a0)

.test7:
	lea	bit7(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #7,d0
	beq.s .test8
	move.w #$CCC,(a0)

.test8:
	lea	bit8(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #8,d0
	beq.s .test9
	move.w #$CCC,(a0)

.test9:
	lea	bit9(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #9,d0
	beq.s .test10
	move.w #$CCC,(a0)

.test10:
	lea	bit10(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #10,d0
	beq.s .test11
	move.w #$CCC,(a0)

.test11:
	lea	bit11(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #11,d0
	beq.s .test12
	move.w #$CCC,(a0)

.test12:
	lea	bit12(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #12,d0
	beq.s .test13
	move.w #$CCC,(a0)

.test13:
	lea	bit13(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #13,d0
	beq.s .test14
	move.w #$CCC,(a0)

.test14:
	lea	bit14(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #14,d0
	beq.s .test15
	move.w #$CCC,(a0)

.test15:
	lea	bit15(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #15,d0
	beq.s .resetBitplanePointers
	move.w #$CCC,(a0)

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

copper:
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPLCON0,$1200
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"copper-colors.s"

	dc.w    BPLCON2, $0B
	
	; First color block

	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$30D9,$FFFE  ; WAIT 
bit15:
	dc.w	COLOR00, $000

	dc.w	$3801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$38D9,$FFFE  ; WAIT 
bit14:
	dc.w	COLOR00, $000

	dc.w	$4001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$40D9,$FFFE  ; WAIT 
bit13:
	dc.w	COLOR00, $000

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$48D9,$FFFE  ; WAIT 
bit12:
	dc.w	COLOR00, $000

	dc.w	$5001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$50D9,$FFFE  ; WAIT 
bit11:
	dc.w	COLOR00, $000

	dc.w	$5801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$58D9,$FFFE  ; WAIT 
bit10:
	dc.w	COLOR00, $000

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$60D9,$FFFE  ; WAIT 
bit9:
	dc.w	COLOR00, $000

	dc.w	$6801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$68D9,$FFFE  ; WAIT 
bit8:
	dc.w	COLOR00, $000

	dc.w	$7001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$70D9,$FFFE  ; WAIT 
bit7:
	dc.w	COLOR00, $000

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$78D9,$FFFE  ; WAIT 
bit6:
	dc.w	COLOR00, $000

	dc.w	$8001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$80D9,$FFFE  ; WAIT 
bit5:
	dc.w	COLOR00, $000

	dc.w	$8801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$88D9,$FFFE  ; WAIT 
bit4:
	dc.w	COLOR00, $000

	dc.w	$9001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$90D9,$FFFE  ; WAIT 
bit3:
	dc.w	COLOR00, $000

	dc.w	$9801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$98D9,$FFFE  ; WAIT 
bit2:
	dc.w	COLOR00, $000

	dc.w	$A001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A0D9,$FFFE  ; WAIT 
bit1:
	dc.w	COLOR00, $000

	dc.w	$A801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A8D9,$FFFE  ; WAIT 
bit0:
	dc.w	COLOR00, $000

	dc.w	$B001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$B0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,0
	