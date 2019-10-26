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

	;;  Move sprite 1 to $26000.
	MOVE.L  #$26000,a1 ;Point A1 at sprite destination
	LEA     SPRITE1(pc),a2 ;Point A2 at sprite source
SPRLOOP1:	
	MOVE.L  (a2),(a1)+ ;Move a long word
	CMP.L   #$00000000,(a2)+ ;Check for end of sprite
	BNE     SPRLOOP1	 ;Loop until entire sprite is moved

	;;  Move sprite 2 to $27000.
	MOVE.L  #$27000,a1 ;Point A1 at sprite destination
	LEA     SPRITE2(pc),a2 ;Point A2 at sprite source
SPRLOOP2:	
	MOVE.L  (a2),(a1)+ ;Move a long word
	CMP.L   #$00000000,(a2)+ ;Check for end of sprite
	BNE     SPRLOOP2	 ;Loop until entire sprite is moved

	;;  Move sprite 3 to $28000.
	MOVE.L  #$28000,a1 ;Point A1 at sprite destination
	LEA     SPRITE3(pc),a2 ;Point A2 at sprite source
SPRLOOP3:	
	MOVE.L  (a2),(a1)+ ;Move a long word
	CMP.L   #$00000000,(a2)+ ;Check for end of sprite
	BNE     SPRLOOP3	 ;Loop until entire sprite is moved

	;;  Move sprite 4 to $29000.
	MOVE.L  #$29000,a1 ;Point A1 at sprite destination
	LEA     SPRITE4(pc),a2 ;Point A2 at sprite source
SPRLOOP4:	
	MOVE.L  (a2),(a1)+ ;Move a long word
	CMP.L   #$00000000,(a2)+ ;Check for end of sprite
	BNE     SPRLOOP4	 ;Loop until entire sprite is moved

	;;  Move sprite 5 to $2A000.
	MOVE.L  #$2A000,a1 ;Point A1 at sprite destination
	LEA     SPRITE5(pc),a2 ;Point A2 at sprite source
SPRLOOP5:	
	MOVE.L  (a2),(a1)+ ;Move a long word
	CMP.L   #$00000000,(a2)+ ;Check for end of sprite
	BNE     SPRLOOP5	 ;Loop until entire sprite is moved

	;;  Move sprite 6 to $2B000.
	MOVE.L  #$2B000,a1 ;Point A1 at sprite destination
	LEA     SPRITE6(pc),a2 ;Point A2 at sprite source
SPRLOOP6:	
	MOVE.L  (a2),(a1)+ ;Move a long word
	CMP.L   #$00000000,(a2)+ ;Check for end of sprite
	BNE     SPRLOOP6	 ;Loop until entire sprite is moved

	;;  Move sprite 7 to $2C000.
	MOVE.L  #$2C000,a1 ;Point A1 at sprite destination
	LEA     SPRITE7(pc),a2 ;Point A2 at sprite source
SPRLOOP7:	
	MOVE.L  (a2),(a1)+ ;Move a long word
	CMP.L   #$00000000,(a2)+ ;Check for end of sprite
	BNE     SPRLOOP7	 ;Loop until entire sprite is moved

	;;
	;;  Clear bitplanes
	;;
	MOVE.L  #bitplanes,a1 ;Point A1 at bitplane
	MOVE.W  #$3300,d0   ;2000-1(for dbf) long words = 8000 bytes
FLOOP
	MOVE.L  #$0,(a1)+ ;Move a long word
	DBF     d0,FLOOP	 ;Decrement, repeat until false.


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
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
 	include	"out/image-copper-list.s"

	DC.W    SPR0PTH,$0002 ;Sprite 0 pointer = $25000
	DC.W    SPR0PTL,$5000
	DC.W    SPR1PTH,$0002 ;Sprite 1 pointer = $26000
	DC.W    SPR1PTL,$6000
	DC.W    SPR2PTH,$0002 ;Sprite 2 pointer = $27000
	DC.W    SPR2PTL,$7000
	DC.W    SPR3PTH,$0002 ;Sprite 3 pointer = $28000
	DC.W    SPR3PTL,$8000
	DC.W    SPR4PTH,$0002 ;Sprite 4 pointer = $29000
	DC.W    SPR4PTL,$9000
	DC.W    SPR5PTH,$0002 ;Sprite 5 pointer = $2A000
	DC.W    SPR5PTL,$A000
	DC.W    SPR6PTH,$0002 ;Sprite 6 pointer = $2B000
	DC.W    SPR6PTL,$B000
	DC.W    SPR7PTH,$0002 ;Sprite 7 pointer = $2C000
	DC.W    SPR7PTL,$C000
	DC.W    COLOR25,$0FF0 
	DC.W    COLOR26,$0444 
	DC.W    COLOR27,$0F00 

	;dc.w	$4501,$FFFE  ; WAIT 
	;dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$600  ; Enable dual playfield mode

	dc.w    BPLCON2, $0B
	
   ; First color block
	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$3151,$FFFE  ; WAIT 
	dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$600  ; Dual playfields on

	dc.w	$3801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$38D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$3961,$FFFE  ; WAIT 
	dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$200  ; Dual playfields off

	dc.w	$4001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$40D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$4171,$FFFE  ; WAIT 
	dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$600  ; Dual playfields on

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$4981,$FFFE  ; WAIT 
	dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$200  ; Dual playfields off

	dc.w	$5001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$50D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$5191,$FFFE  ; WAIT 
	dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$600  ; Dual playfields on

	dc.w	$5801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$58D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$59A1,$FFFE  ; WAIT 
	dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$200  ; Dual playfields off

  ; Second color block
	dc.w	$7001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$70D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$71B1,$FFFE  ; WAIT 
	dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$600  ; Dual playfields on

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$78D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$79C1,$FFFE  ; WAIT 
	dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$200  ; Dual playfields off

	dc.w	$8001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$80D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$81D1,$FFFE  ; WAIT 
	dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$600  ; Dual playfields on

	dc.w	$8801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$88D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$88E1,$FFFE  ; WAIT 
	dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$200  ; Dual playfields off

	dc.w	$9001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$90D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$9101,$FFFE  ; WAIT 
	dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$600  ; Dual playfields on

	dc.w	$9801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$98D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	$9901,$FFFE  ; WAIT 
	dc.w    BPLCON0, (SCREEN_BIT_DEPTH<<12)|$200  ; Dual playfields off

	; Third color block
	dc.w    $B801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $B8D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $B951,$FFFE  ; WAIT
	dc.w    BPLCON0, (5<<12)|$600  ; Dual playfields on

	dc.w    $C001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $C0D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $C151,$FFFE  ; WAIT
	dc.w    BPLCON0, (5<<12)|$200  ; Dual playfields off

	dc.w    $C801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $C8D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $C951,$FFFE  ; WAIT
	dc.w    BPLCON0, (4<<12)|$600  ; Dual playfields on

	dc.w    $D001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $D0D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $D151,$FFFE  ; WAIT
	dc.w    BPLCON0, (4<<12)|$200  ; Dual playfields off

	dc.w    $D801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $D8D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $D951,$FFFE  ; WAIT
	dc.w    BPLCON0, (3<<12)|$600  ; Dual playfields on

	dc.w    $E001,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $E0D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000
	dc.w    $E151,$FFFE  ; WAIT
	dc.w    BPLCON0, (3<<12)|$200  ; Dual playfields off

	dc.w    $E801,$FFFE  ; WAIT
	dc.w	COLOR00, $F00
	dc.w    $E8D9,$FFFE  ; WAIT
	dc.w	COLOR00, $000


	dc.w    $ffdf,$fffe ; Cross vertical boundary

	; Fourth color block

	dc.w	BPLCON0,$200

	dc.l	$fffffffe

	;;
	;;  Sprite data 
	;;

SPRITE0:
			DC.W    $2D40,$3D00 ;VSTART, HSTART, VSTOP
	        DC.W    $07E0,$0000 ; 0
	        DC.W    $1FF8,$0000 ; 1
	        DC.W    $3FFC,$0000 ; 2
	        DC.W    $3FFC,$0E70 ; 3
	        DC.W    $39CC,$0E70 ; 4
	        DC.W    $79CE,$0E70 ; 5
	        DC.W    $7FFE,$0000 ; 6
	        DC.W    $7FFE,$0000 ; 7
	        DC.W    $7FFE,$0000 ; 8
	        DC.W    $7FFE,$0000 ; 9
	        DC.W    $7FFE,$0000 ; 10
	        DC.W    $7FFE,$0000 ; 11
	        DC.W    $7FFE,$0000 ; 12
	        DC.W    $7BDE,$0000 ; 13
	        DC.W    $7BDE,$0000 ; 14
	        DC.W    $318C,$0000 ; 15
			;
			DC.W    $7D40,$8D80 ;VSTART, HSTART, VSTOP
	        DC.W    $07E0,$0000 ; 0
	        DC.W    $1FF8,$0000 ; 1
	        DC.W    $3FFC,$0000 ; 2
	        DC.W    $3FFC,$0E70 ; 3
	        DC.W    $39CC,$0E70 ; 4
	        DC.W    $79CE,$0E70 ; 5
	        DC.W    $7FFE,$0000 ; 6
	        DC.W    $7FFE,$0000 ; 7
	        DC.W    $7FFE,$0000 ; 8
	        DC.W    $7FFE,$0000 ; 9
	        DC.W    $7FFE,$0000 ; 10
	        DC.W    $7FFE,$0000 ; 11
	        DC.W    $7FFE,$0000 ; 12
	        DC.W    $7BDE,$0000 ; 13
	        DC.W    $7BDE,$0000 ; 14
	        DC.W    $318C,$0000 ; 15
			;
	        DC.W    $07E0,$0000 ; 0
	        DC.W    $1FF8,$0000 ; 1
	        DC.W    $3FFC,$0000 ; 2
	        DC.W    $3FFC,$0E70 ; 3
	        DC.W    $39CC,$0E70 ; 4
	        DC.W    $79CE,$0E70 ; 5
	        DC.W    $7FFE,$0000 ; 6
	        DC.W    $7FFE,$0000 ; 7
	        DC.W    $7FFE,$0000 ; 8
	        DC.W    $7FFE,$0000 ; 9
	        DC.W    $7FFE,$0000 ; 10
	        DC.W    $7FFE,$0000 ; 11
	        DC.W    $7FFE,$0000 ; 12
	        DC.W    $7BDE,$0000 ; 13
	        DC.W    $7BDE,$0000 ; 14
	        DC.W    $318C,$0000 ; 15
			;
	        DC.W    $0000,$0000 ; End of sprite data

SPRITE1:
			DC.W    $2D40,$3D00 ;VSTART, HSTART, VSTOP
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
			;
			DC.W    $7D44,$8D00 ;VSTART, HSTART, VSTOP
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
			;
			DC.W    $BD50,$CD00 ;VSTART, HSTART, VSTOP
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
			;
	        DC.W    $0000,$0000 ; End of sprite data

SPRITE2:
			DC.W    $2D60,$3D80 ;VSTART, HSTART, VSTOP
	        DC.W    $07E0,$0000 ; 0
	        DC.W    $1FF8,$0000 ; 1
	        DC.W    $3FFC,$0000 ; 2
	        DC.W    $3FFC,$0E70 ; 3
	        DC.W    $39CC,$0E70 ; 4
	        DC.W    $79CE,$0E70 ; 5
	        DC.W    $7FFE,$0000 ; 6
	        DC.W    $7FFE,$0000 ; 7
	        DC.W    $7FFE,$0000 ; 8
	        DC.W    $7FFE,$0000 ; 9
	        DC.W    $7FFE,$0000 ; 10
	        DC.W    $7FFE,$0000 ; 11
	        DC.W    $7FFE,$0000 ; 12
	        DC.W    $7BDE,$0000 ; 13
	        DC.W    $7BDE,$0000 ; 14
	        DC.W    $318C,$0000 ; 15
			;
			DC.W    $7D60,$8D80 ;VSTART, HSTART, VSTOP
	        DC.W    $07E0,$0000 ; 0
	        DC.W    $1FF8,$0000 ; 1
	        DC.W    $3FFC,$0000 ; 2
	        DC.W    $3FFC,$0E70 ; 3
	        DC.W    $39CC,$0E70 ; 4
	        DC.W    $79CE,$0E70 ; 5
	        DC.W    $7FFE,$0000 ; 6
	        DC.W    $7FFE,$0000 ; 7
	        DC.W    $7FFE,$0000 ; 8
	        DC.W    $7FFE,$0000 ; 9
	        DC.W    $7FFE,$0000 ; 10
	        DC.W    $7FFE,$0000 ; 11
	        DC.W    $7FFE,$0000 ; 12
	        DC.W    $7BDE,$0000 ; 13
	        DC.W    $7BDE,$0000 ; 14
	        DC.W    $318C,$0000 ; 15
			;
			DC.W    $BD60,$CD80 ;VSTART, HSTART, VSTOP
	        DC.W    $07E0,$0000 ; 0
	        DC.W    $1FF8,$0000 ; 1
	        DC.W    $3FFC,$0000 ; 2
	        DC.W    $3FFC,$0E70 ; 3
	        DC.W    $39CC,$0E70 ; 4
	        DC.W    $79CE,$0E70 ; 5
	        DC.W    $7FFE,$0000 ; 6
	        DC.W    $7FFE,$0000 ; 7
	        DC.W    $7FFE,$0000 ; 8
	        DC.W    $7FFE,$0000 ; 9
	        DC.W    $7FFE,$0000 ; 10
	        DC.W    $7FFE,$0000 ; 11
	        DC.W    $7FFE,$0000 ; 12
	        DC.W    $7BDE,$0000 ; 13
	        DC.W    $7BDE,$0000 ; 14
	        DC.W    $318C,$0000 ; 15
			;
	        DC.W    $0000,$0000 ; End of sprite data

SPRITE3:
			DC.W    $2D60,$3D00 ;VSTART, HSTART, VSTOP
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
			;
			DC.W    $7D64,$8D00 ;VSTART, HSTART, VSTOP
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
			;
			DC.W    $BD70,$CD00 ;VSTART, HSTART, VSTOP
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
			;
	        DC.W    $0000,$0000 ; End of sprite data

SPRITE4:
			DC.W    $2D80,$3D00 ;VSTART, HSTART, VSTOP
	        DC.W    $07E0,$0000 ; 0
	        DC.W    $1FF8,$0000 ; 1
	        DC.W    $3FFC,$0000 ; 2
	        DC.W    $3FFC,$0E70 ; 3
	        DC.W    $39CC,$0E70 ; 4
	        DC.W    $79CE,$0E70 ; 5
	        DC.W    $7FFE,$0000 ; 6
	        DC.W    $7FFE,$0000 ; 7
	        DC.W    $7FFE,$0000 ; 8
	        DC.W    $7FFE,$0000 ; 9
	        DC.W    $7FFE,$0000 ; 10
	        DC.W    $7FFE,$0000 ; 11
	        DC.W    $7FFE,$0000 ; 12
	        DC.W    $7BDE,$0000 ; 13
	        DC.W    $7BDE,$0000 ; 14
	        DC.W    $318C,$0000 ; 15
			;
			DC.W    $7D80,$8D00 ;VSTART, HSTART, VSTOP
	        DC.W    $07E0,$0000 ; 0
	        DC.W    $1FF8,$0000 ; 1
	        DC.W    $3FFC,$0000 ; 2
	        DC.W    $3FFC,$0E70 ; 3
	        DC.W    $39CC,$0E70 ; 4
	        DC.W    $79CE,$0E70 ; 5
	        DC.W    $7FFE,$0000 ; 6
	        DC.W    $7FFE,$0000 ; 7
	        DC.W    $7FFE,$0000 ; 8
	        DC.W    $7FFE,$0000 ; 9
	        DC.W    $7FFE,$0000 ; 10
	        DC.W    $7FFE,$0000 ; 11
	        DC.W    $7FFE,$0000 ; 12
	        DC.W    $7BDE,$0000 ; 13
	        DC.W    $7BDE,$0000 ; 14
	        DC.W    $318C,$0000 ; 15
			;
			DC.W    $BD80,$CD00 ;VSTART, HSTART, VSTOP
	        DC.W    $07E0,$0000 ; 0
	        DC.W    $1FF8,$0000 ; 1
	        DC.W    $3FFC,$0000 ; 2
	        DC.W    $3FFC,$0E70 ; 3
	        DC.W    $39CC,$0E70 ; 4
	        DC.W    $79CE,$0E70 ; 5
	        DC.W    $7FFE,$0000 ; 6
	        DC.W    $7FFE,$0000 ; 7
	        DC.W    $7FFE,$0000 ; 8
	        DC.W    $7FFE,$0000 ; 9
	        DC.W    $7FFE,$0000 ; 10
	        DC.W    $7FFE,$0000 ; 11
	        DC.W    $7FFE,$0000 ; 12
	        DC.W    $7BDE,$0000 ; 13
	        DC.W    $7BDE,$0000 ; 14
	        DC.W    $318C,$0000 ; 15
			;
	        DC.W    $0000,$0000 ; End of sprite data

SPRITE5:
			DC.W    $2D80,$3D80 ;VSTART, HSTART, VSTOP
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
			;
			DC.W    $7D84,$8D80 ;VSTART, HSTART, VSTOP
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
			;
			DC.W    $BD90,$CD80 ;VSTART, HSTART, VSTOP
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
			;
	        DC.W    $0000,$0000 ; End of sprite data

SPRITE6:
			DC.W    $2DA0,$3D80 ;VSTART, HSTART, VSTOP
	        DC.W    $07E0,$0000 ; 0
	        DC.W    $1FF8,$0000 ; 1
	        DC.W    $3FFC,$0000 ; 2
	        DC.W    $3FFC,$0E70 ; 3
	        DC.W    $39CC,$0E70 ; 4
	        DC.W    $79CE,$0E70 ; 5
	        DC.W    $7FFE,$0000 ; 6
	        DC.W    $7FFE,$0000 ; 7
	        DC.W    $7FFE,$0000 ; 8
	        DC.W    $7FFE,$0000 ; 9
	        DC.W    $7FFE,$0000 ; 10
	        DC.W    $7FFE,$0000 ; 11
	        DC.W    $7FFE,$0000 ; 12
	        DC.W    $7BDE,$0000 ; 13
	        DC.W    $7BDE,$0000 ; 14
	        DC.W    $318C,$0000 ; 15
			;
			DC.W    $7DA0,$8D80 ;VSTART, HSTART, VSTOP
	        DC.W    $07E0,$0000 ; 0
	        DC.W    $1FF8,$0000 ; 1
	        DC.W    $3FFC,$0000 ; 2
	        DC.W    $3FFC,$0E70 ; 3
	        DC.W    $39CC,$0E70 ; 4
	        DC.W    $79CE,$0E70 ; 5
	        DC.W    $7FFE,$0000 ; 6
	        DC.W    $7FFE,$0000 ; 7
	        DC.W    $7FFE,$0000 ; 8
	        DC.W    $7FFE,$0000 ; 9
	        DC.W    $7FFE,$0000 ; 10
	        DC.W    $7FFE,$0000 ; 11
	        DC.W    $7FFE,$0000 ; 12
	        DC.W    $7BDE,$0000 ; 13
	        DC.W    $7BDE,$0000 ; 14
	        DC.W    $318C,$0000 ; 15
			;
			DC.W    $BDA0,$CD80 ;VSTART, HSTART, VSTOP
	        DC.W    $07E0,$0000 ; 0
	        DC.W    $1FF8,$0000 ; 1
	        DC.W    $3FFC,$0000 ; 2
	        DC.W    $3FFC,$0E70 ; 3
	        DC.W    $39CC,$0E70 ; 4
	        DC.W    $79CE,$0E70 ; 5
	        DC.W    $7FFE,$0000 ; 6
	        DC.W    $7FFE,$0000 ; 7
	        DC.W    $7FFE,$0000 ; 8
	        DC.W    $7FFE,$0000 ; 9
	        DC.W    $7FFE,$0000 ; 10
	        DC.W    $7FFE,$0000 ; 11
	        DC.W    $7FFE,$0000 ; 12
	        DC.W    $7BDE,$0000 ; 13
	        DC.W    $7BDE,$0000 ; 14
	        DC.W    $318C,$0000 ; 15
			;
	        DC.W    $0000,$0000 ; End of sprite data

SPRITE7:
			DC.W    $2DA0,$3D80 ;VSTART, HSTART, VSTOP
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
			;
			DC.W    $7DA4,$8D80 ;VSTART, HSTART, VSTOP
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
			;
			DC.W    $BDB0,$CD80 ;VSTART, HSTART, VSTOP
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
			;
	        DC.W    $0000,$0000 ; End of sprite data

SPRITE_END: DC.W    $0000,$0001 ; Copy until we get here

bitplanes:
	incbin	"out/image.bin"
	