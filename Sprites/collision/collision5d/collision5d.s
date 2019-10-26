	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 6
	
entry:	
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

	;;  Move sprite 0 to $25000.
	MOVE.L  #$25000,a1 ;Point A1 at sprite destination
	LEA     SPRITE0(pc),a2 ;Point A2 at sprite source
SPRLOOP0:	
	MOVE.L  (a2),(a1)+ ;Move a long word
	CMP.L   #$00000000,(a2)+ ;Check for end of sprite
	BNE     SPRLOOP0	 ;Loop until entire sprite is moved

	;;  Move sprite 2 to $26000.
	MOVE.L  #$26000,a1 ;Point A1 at sprite destination
	LEA     SPRITE2(pc),a2 ;Point A2 at sprite source
SPRLOOP2:	
	MOVE.L  (a2),(a1)+ ;Move a long word
	CMP.L   #$00000000,(a2)+ ;Check for end of sprite
	BNE     SPRLOOP2	 ;Loop until entire sprite is moved

	;;  Move sprite 4 to $27000.
	MOVE.L  #$27000,a1 ;Point A1 at sprite destination
	LEA     SPRITE4(pc),a2 ;Point A2 at sprite source
SPRLOOP4:	
	MOVE.L  (a2),(a1)+ ;Move a long word
	CMP.L   #$00000000,(a2)+ ;Check for end of sprite
	BNE     SPRLOOP4	 ;Loop until entire sprite is moved

	;;  Move sprite 6 to $28000.
	MOVE.L  #$28000,a1 ;Point A1 at sprite destination
	LEA     SPRITE6(pc),a2 ;Point A2 at sprite source
SPRLOOP6:	
	MOVE.L  (a2),(a1)+ ;Move a long word
	CMP.L   #$00000000,(a2)+ ;Check for end of sprite
	BNE     SPRLOOP6	 ;Loop until entire sprite is moved

	;;
	;;  Now we write a dummy sprite to $30000, since all eight sprites are activated
	;;  at the same time and we're only going to use one.  The remaining sprites
	;;  will point to this dummy sprite data.
	;;
	MOVE.L  #$00000000,$30000 ;Write it

	;; install copper list and enable DMA
	lea 	CUSTOM,a1
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!32!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	; MOVE.W  #$83A0,DMACON(a1) ;Bitplane, Copper, and sprite DMA

	;; Configure collision detection
	;; Exclude plane 0 and 1 from comparison
	move.w #$FF00,clxcon(a1)


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

.checkCollisionRegister:
	; LEA    RGB(pc),a1
	move.w CLXDAT(a5),d0
	
	; Make bits 0-3 visible in COLOR00
	lea    RGB(pc),a1
	move.l d0,d1
	and.w #$F,d1
	; move.w #$00,d1 ; REMOVE
	rol.w  #$1,d1
	add.w d1,a1
	move.w (a1),COLOR00(a5) 

	; Make bits 4-7 visible in COLOR01
	lea    RGB(pc),a1
	move.l d0,d1
	ror.l #4,d1
	and.w #$F,d1
	; move.w #$01,d1 ; REMOVE
	rol.w  #$1,d1
	add.w d1,a1
	move.w (a1),COLOR01(a5) 

	; Make bits 8-11 visible in COLOR02
	lea    RGB(pc),a1
	move.l d0,d1
	ror.l #7,d1
	ror.l #1,d1
	and.w #$F,d1
	; move.w #$02,d1 ; REMOVE
	rol.w  #$1,d1
	add.w d1,a1
	move.w (a1),COLOR02(a5) 

	; Make bits 12-15 visible in COLOR03
	lea    RGB(pc),a1
	move.l d0,d1
	ror.l #7,d1
	ror.l #5,d1
	and.w #$F,d1
	; move.w #$03,d1 ; REMOVE
	rol.w  #$1,d1
	add.w d1,a1
	move.w (a1),COLOR03(a5) 

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
	DC.W    $F00, $0F0, $00F, $FF0, $0FF, $F0F, $800, $080, $008, $880, $088, $808, $444, $AAA, $FFF, $400 

copper:
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH<<12)|$600 ; set color depth, enable COLOR, enable dual-playfield mode
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"copper-colors.s"

	DC.W    SPR0PTH,$0003 ;Sprite 0 pointer = $30000
	DC.W    SPR0PTL,$0000
	DC.W    SPR1PTH,$0002 ;Sprite 1 pointer = $25000
	DC.W    SPR1PTL,$5000
	DC.W    SPR2PTH,$0003 ;Sprite 2 pointer = $30000
	DC.W    SPR2PTL,$0000
	DC.W    SPR3PTH,$0003 ;Sprite 3 pointer = $30000
	DC.W    SPR3PTL,$0000
	DC.W    SPR4PTH,$0003 ;Sprite 4 pointer = $30000
	DC.W    SPR4PTL,$0000
	DC.W    SPR5PTH,$0003 ;Sprite 5 pointer = $30000
	DC.W    SPR5PTL,$0000
	DC.W    SPR6PTH,$0003 ;Sprite 6 pointer = $30000
	DC.W    SPR6PTL,$0000
	DC.W    SPR7PTH,$0002 ;Sprite 7 pointer = $26000
	DC.W    SPR7PTL,$6000
	DC.W    COLOR17,$0FF0 
	DC.W    COLOR18,$0444 
	DC.W    COLOR19,$0F00 

	dc.w    BPLCON2, $0B

	dc.l	$fffffffe

	;;
	;;  Sprite data 
	;;

SPRITE0:
			DC.W    $2D48,$3D00 ;VSTART, HSTART, VSTOP
	        DC.W    $FFFF,$0000 ; 0
	        DC.W    $FFFF,$0000 ; 1
	        DC.W    $FFFF,$0000 ; 2
	        DC.W    $0000,$0000 ; End of sprite data

SPRITE2:
			DC.W    $2B46,$3B00 ;VSTART, HSTART, VSTOP
	        DC.W    $0F00,$0000 ; 0
	        DC.W    $0F00,$0000 ; 1
	        DC.W    $0F00,$0000 ; 2
	        DC.W    $0F00,$0000 ; 3
	        DC.W    $0F00,$0000 ; 4
	        DC.W    $0F00,$0000 ; 5
	        DC.W    $0F00,$0000 ; 6
	        DC.W    $0F00,$0000 ; 7
	        DC.W    $0F00,$0000 ; 8
	        DC.W    $0F00,$0000 ; 9
	        DC.W    $0F00,$0000 ; 10
	        DC.W    $0F00,$0000 ; 11
	        DC.W    $0F00,$0000 ; 13
	        DC.W    $0F00,$0000 ; 14
	        DC.W    $0F00,$0000 ; 14
	        DC.W    $0F00,$0000 ; 15
	        DC.W    $0000,$0000 ; End of sprite data

SPRITE4:
			DC.W    $2D8C,$3D00 ;VSTART, HSTART, VSTOP
	        DC.W    $03C0,$0000 ; 0
	        DC.W    $0FF0,$0000 ; 1
	        DC.W    $1C78,$0380 ; 2
	        DC.W    $3DFC,$0380 ; 3
	        DC.W    $7DFE,$0380 ; 4
	        DC.W    $7FF8,$0000 ; 5
	        DC.W    $FFE0,$0000 ; 6
	        DC.W    $FF00,$0000 ; 7
	        DC.W    $FF00,$0000 ; 8
	        DC.W    $FFE0,$0000 ; 9
	        DC.W    $7FF8,$0000 ; 10
	        DC.W    $7FFE,$0000 ; 11
	        DC.W    $3FFC,$0000 ; 13
	        DC.W    $1FF8,$0000 ; 14
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
	        DC.W    $0000,$0000 ; End of sprite data

SPRITE6:
			DC.W    $2DB0,$3D00 ;VSTART, HSTART, VSTOP
	        DC.W    $03C0,$0000 ; 0
	        DC.W    $0FF0,$0000 ; 1
	        DC.W    $1C78,$0380 ; 2
	        DC.W    $3DFC,$0380 ; 3
	        DC.W    $7DFE,$0380 ; 4
	        DC.W    $7FF8,$0000 ; 5
	        DC.W    $FFE0,$0000 ; 6
	        DC.W    $FF00,$0000 ; 7
	        DC.W    $FF00,$0000 ; 8
	        DC.W    $FFE0,$0000 ; 9
	        DC.W    $7FF8,$0000 ; 10
	        DC.W    $7FFE,$0000 ; 11
	        DC.W    $3FFC,$0000 ; 13
	        DC.W    $1FF8,$0000 ; 14
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
	        DC.W    $0000,$0000 ; End of sprite data

SPRITE_END: DC.W    $0000,$0001 ; Copy until we get here

bitplanes:
	incbin	"out/image.bin"
	