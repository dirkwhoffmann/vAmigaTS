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

	;;  Move sprite 2 to $27000.
	MOVE.L  #$27000,a1 ;Point A1 at sprite destination
	LEA     SPRITE4(pc),a2 ;Point A2 at sprite source
SPRLOOP4:	
	MOVE.L  (a2),(a1)+ ;Move a long word
	CMP.L   #$00000000,(a2)+ ;Check for end of sprite
	BNE     SPRLOOP4	 ;Loop until entire sprite is moved

	;;  Move sprite 2 to $28000.
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

.mainLoop:
	bra.b	.mainLoop

level3InterruptHandler:
	movem.l	d0-a6,-(sp)

.checkVerticalBlank:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_VERTB,d0	
	beq.s	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; clear interrupt bit	

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
 
 	include	"out/image-copper-list.s"

	DC.W    SPR0PTH,$0002 ;Sprite 0 pointer = $25000
	DC.W    SPR0PTL,$5000
	DC.W    SPR1PTH,$0003 ;Sprite 1 pointer = $30000
	DC.W    SPR1PTL,$0000
	DC.W    SPR2PTH,$0002 ;Sprite 2 pointer = $26000
	DC.W    SPR2PTL,$6000
	DC.W    SPR3PTH,$0003 ;Sprite 3 pointer = $30000
	DC.W    SPR3PTL,$0000
	DC.W    SPR4PTH,$0002 ;Sprite 4 pointer = $27000
	DC.W    SPR4PTL,$7000
	DC.W    SPR5PTH,$0003 ;Sprite 5 pointer = $30000
	DC.W    SPR5PTL,$0000
	DC.W    SPR6PTH,$0002 ;Sprite 6 pointer = $28000
	DC.W    SPR6PTL,$8000
	DC.W    SPR7PTH,$0003 ;Sprite 7 pointer = $30000
	DC.W    SPR7PTL,$0000

	DC.W    COLOR16,$0F80 
	DC.W    COLOR17,$04f1 
	DC.W    COLOR18,$0F88 
	DC.W    COLOR25,$0FF0 
	DC.W    COLOR26,$0444 
	DC.W    COLOR27,$0F00 

	dc.w    BPLCON2, $0B
	
	dc.w	$2801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$28D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$2901,$FFFE  ; WAIT 

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$60D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$6101,$FFFE  ; WAIT

    ; First test (using Sprite 0)
	dc.w	$6E11,$FFFE  ; WAIT
	dc.w    SPR0CTL,$0000 ; Write bogus CTL 
	dc.w	$7031,$FFFE  ; WAIT
	dc.w    SPR0CTL,$1000 ; Write bogus CTL 
	; The next write happens in the POS / CTL line of the sprite. 
	; We write some bogus CTL value before DMA happens. DMA won't stop, because
	; vpos does not match SPRVPOS. Because vpos still does not match, sprite data is 
	; read instead of POS / CTL words. 
	dc.w    SPR0CTL,$2000 ; Write bogus CTL

    ; Second test (using sprite 2)
	dc.w	$7911,$FFFE  ; WAIT
	dc.w    SPR2CTL,$0000 ; Write bogus CTL 
	dc.w	$8031,$FFFE  ; WAIT
	dc.w    SPR2CTL,$1000 ; Write bogus CTL
	dc.w    $8811,$FFFE ; WAIT
	; The next write happens in the POS / CTL line of the sprite. 
	; We restore the old (correct) CTL value. DMA won't stop, because
	; vpos does not match SPRVPOS when we write into SPR2CRTL. 
	dc.w    SPR2CTL,$8800

	; Third test (using sprite 4) 
	dc.w	$8961,$FFFE  ; WAIT 
	dc.w    SPR4CTL,$0000 ; Write bogus CTL
	dc.w	$9121,$FFFE  ; WAIT 
	dc.w    SPR4CTL,$9200 ; Restore old (correct) CTL
	dc.w	$9221,$FFFE  ; WAIT 
	; The next write happens in the POS / CTL line of the sprite. 
	; We restore the old (correct) CTL value. DMA won't stop, because
	; vpos still matches SPRVPOS when we write into SPR4CRTL. 
	dc.w    SPR4CTL,$9200 

	; Fourth test (using sprite 6) 
	dc.w	$9369,$FFFE  ; WAIT 
	dc.w    SPR6CTL,$0000 ; Write bogus CTL
	dc.w	$9569,$FFFE  ; WAIT 
	dc.w    SPR6CTL,$9D00 ; Restore old (correct) CTL
	dc.w	$9D21,$FFFE  ; WAIT 
	; The next write happens in the POS / CTL line of the sprite. 
	; We write some bogus CTL value before DMA happens. DMA will stop, because
	; vpos matches SPRVPOS when we write into SPR4CRTL. 
	dc.w    SPR6CTL,$1000

	dc.w	$A001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$A101,$FFFE  ; WAIT 

	dc.w	$E001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$E0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$E101,$FFFE  ; WAIT 

	dc.w    $ffdf,$fffe ; Cross vertical boundary

	dc.w	$2001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$20D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$2101,$FFFE  ; WAIT 

	dc.l	$fffffffe

	;;
	;;  Sprite data 
	;;

SPRITE0:
			DC.W    $2D44,$3D00 ;VSTART, HSTART, VSTOP
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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			;
			DC.W    $6D44,$7D00 ;VSTART, HSTART, VSTOP
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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			;
			DC.W    $AD44,$BD00 ;VSTART, HSTART, VSTOP
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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			;
			DC.W    $ED44,$FD00 ;VSTART, HSTART, VSTOP
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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			;
	        DC.W    $0000,$0000 ; End of sprite data

SPRITE2:
			DC.W    $3868,$4800 ;VSTART, HSTART, VSTOP
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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			;
			DC.W    $7868,$8800 ;VSTART, HSTART, VSTOP
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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			;
			DC.W    $B868,$C800 ;VSTART, HSTART, VSTOP
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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			;
			DC.W    $F868,$0802 ;VSTART, HSTART, VSTOP
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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			;
	        DC.W    $0000,$0000 ; End of sprite data

SPRITE4:
			DC.W    $428C,$5200 ;VSTART, HSTART, VSTOP
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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			;
			DC.W    $828C,$9200 ;VSTART, HSTART, VSTOP
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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			;
			DC.W    $C28C,$D200 ;VSTART, HSTART, VSTOP
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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			;
			DC.W    $028C,$1206 ;VSTART, HSTART, VSTOP
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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			;
	        DC.W    $0000,$0000 ; End of sprite data

SPRITE6:
			DC.W    $4DB0,$5D00 ;VSTART, HSTART, VSTOP
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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			;
			DC.W    $8DB0,$9D00 ;VSTART, HSTART, VSTOP
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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			;
			DC.W    $CDB0,$DD00 ;VSTART, HSTART, VSTOP
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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			;
			DC.W    $0DB0,$1D04 ;VSTART, HSTART, VSTOP
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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			;
	        DC.W    $0000,$0000 ; End of sprite data

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
	        DC.W    $3FFC,$0000 ; 12
	        DC.W    $1FF8,$0000 ; 13
	        DC.W    $0FF0,$0000 ; 14
	        DC.W    $03C0,$0000 ; 15
			 
SPRITE_END: DC.W    $0000,$0001 ; Copy until we get here

bitplanes:
	ds.b 61440,$00
	;incbin	"out/image.bin"
	