	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 6
	
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

	; Install single bitplane
	move.w  #$1200,BPLCON0(a1) ; 1 bitplane
	move.w  #$0000,BPL1MOD(a1) 
	move.w  #$0000,BPLCON1(a1) ; No scroll
	move.w  #$0024,BPLCON2(a1) ; Sprites have priority over playfields
	move.w  #$0038,DDFSTRT(a1)
	move.w  #$00D0,DDFSTOP(a1)
	move.w  #$2C81,DIWSTRT(a1) 
	move.w  #$F4C1,DIWSTOP(a1)

	; Install Copper list
	lea    	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA Copper, bitplane, and sprite DMA
	move.w  #$8100,DMACON(a1) ; Bitplane DMA
	move.w  #$8080,DMACON(a1) ; Copper DMA
	move.w  #$8020,DMACON(a1) ; Sprite DMA
	move.w  #$8200,DMACON(a1) ; DMA enable

	; Enable interrupts
	move.w	#$C020,INTENA(a1) 

.mainLoop:
	bra.b	.mainLoop

irq3:
	movem.l	d0-a6,-(sp)
	move.w  #$0020,INTREQ(a1)   ; Acknowledge
	move.w  #$000,COLOR00(a1)

	; Reset bitplane pointers
	lea     bitplanes(pc),a3
	lea     BPL1PTH(a1),a2
	moveq	#SCREEN_BIT_DEPTH-1,d0
.bitplaneloop:
	move.l	a3,(a2)
	lea	    SCREEN_WIDTH_BYTES(a3),a3
	addq	#4,a2
	dbra	d0,.bitplaneloop

	; Reset sprite pointers
	lea	    SPRITE0(pc),a2
 	move.l	a2,SPR0PTH(a1)
	lea	    SPRITE2(pc),a2
 	move.l	a2,SPR2PTH(a1)
	lea	    SPRITE4(pc),a2
 	move.l	a2,SPR4PTH(a1)
	lea	    SPRITE6(pc),a2
 	move.l	a2,SPR6PTH(a1)

	lea	    SPRITE_END(pc),a2
 	move.l	a2,SPR1PTH(a1)
 	move.l	a2,SPR3PTH(a1)
 	move.l	a2,SPR5PTH(a1)
 	move.l	a2,SPR7PTH(a1)

	movem.l	(sp)+,d0-a6
	rte

copper:
 	include	"imagecolors.s"	

	; Change some sprite related colors
	DC.W    COLOR17,$066F 
	DC.W    COLOR18,$0444 
	DC.W    COLOR19,$0F00 
	DC.W    COLOR21,$06F6 
	DC.W    COLOR22,$0444 
	DC.W    COLOR23,$0F00 
	DC.W    COLOR25,$0FF0 
	DC.W    COLOR26,$0444 
	DC.W    COLOR27,$0F00 
	DC.W    COLOR29,$0CCC 
	DC.W    COLOR30,$0444 
	DC.W    COLOR31,$0F00 

    ; Sprite 0
	dc.w    $2D31,$FFFE 
	dc.w    SPR0POS,$2D53 
	dc.w    $2DE1,$FFFE 
	dc.w    SPR0POS,$2D43 
	dc.w    $2E33,$FFFE 
	dc.w    SPR0POS,$2D55 
	dc.w    $2EE1,$FFFE 
	dc.w    SPR0POS,$2D43 
	dc.w    $2F35,$FFFE 
	dc.w    SPR0POS,$2D57 
	dc.w    $2FE1,$FFFE 
	dc.w    SPR0POS,$2D43 
	dc.w    $3037,$FFFE 
	dc.w    SPR0POS,$2D59 
	dc.w    $30E1,$FFFE 
	dc.w    SPR0POS,$2D43 
	dc.w    $3139,$FFFE 
	dc.w    SPR0POS,$2D5B 
	dc.w    $31E1,$FFFE 
	dc.w    SPR0POS,$2D43 
	dc.w    $323B,$FFFE 
	dc.w    SPR0POS,$2D5D 
	dc.w    $2321,$FFFE 
	dc.w    SPR0POS,$2D43 
	dc.w    $333F,$FFFE 
	dc.w    SPR0POS,$2D5F 
	dc.w    $33E1,$FFFE 
	dc.w    SPR0POS,$2D43 
	dc.w    $343F,$FFFE 
	dc.w    SPR0POS,$2D61 
	dc.w    $34E1,$FFFE 
	dc.w    SPR0POS,$2D43 
	dc.w    $3541,$FFFE 
	dc.w    SPR0POS,$2D63 
	dc.w    $35E1,$FFFE 
	dc.w    SPR0POS,$2D43 
	dc.w    $3643,$FFFE 
	dc.w    SPR0POS,$2D65 
	dc.w    $36E1,$FFFE 
	dc.w    SPR0POS,$2D43 
	dc.w    $3745,$FFFE 
	dc.w    SPR0POS,$2D67 
	dc.w    $37E1,$FFFE 
	dc.w    SPR0POS,$2D43 
	dc.w    $3947,$FFFE 
	dc.w    SPR0POS,$2D69 
	dc.w    $39E1,$FFFE 
	dc.w    SPR0POS,$2D43 

    ; Sprite 2
	dc.w    $7D51,$FFFE 
	dc.w    SPR2POS,$2D74
	dc.w    $7DE1,$FFFE 
	dc.w    SPR2POS,$2D64
	dc.w    $7E53,$FFFE 
	dc.w    SPR2POS,$2D76
	dc.w    $7EE1,$FFFE 
	dc.w    SPR2POS,$2D64
	dc.w    $7F55,$FFFE 
	dc.w    SPR2POS,$2D78
	dc.w    $7FE1,$FFFE 
	dc.w    SPR2POS,$2D64
	dc.w    $8057,$FFFE 
	dc.w    SPR2POS,$2D7A
	dc.w    $80E1,$FFFE 
	dc.w    SPR2POS,$2D64
	dc.w    $8159,$FFFE 
	dc.w    SPR2POS,$2D7C
	dc.w    $81E1,$FFFE 
	dc.w    SPR2POS,$2D64
	dc.w    $825B,$FFFE 
	dc.w    SPR2POS,$2D7E
	dc.w    $82E1,$FFFE 
	dc.w    SPR2POS,$2D64
	dc.w    $835F,$FFFE 
	dc.w    SPR2POS,$2D80
	dc.w    $83E1,$FFFE 
	dc.w    SPR2POS,$2D64
	dc.w    $845F,$FFFE 
	dc.w    SPR2POS,$2D82
	dc.w    $84E1,$FFFE 
	dc.w    SPR2POS,$2D64
	dc.w    $8561,$FFFE 
	dc.w    SPR2POS,$2D84
	dc.w    $85E1,$FFFE 
	dc.w    SPR2POS,$2D64
	dc.w    $8663,$FFFE 
	dc.w    SPR2POS,$2D86
	dc.w    $86E1,$FFFE 
	dc.w    SPR2POS,$2D64
	dc.w    $8765,$FFFE 
	dc.w    SPR2POS,$2D88
	dc.w    $87E1,$FFFE 
	dc.w    SPR2POS,$2D64
	dc.w    $8867,$FFFE 
	dc.w    SPR2POS,$2D8A
	dc.w    $88E1,$FFFE 
	dc.w    SPR2POS,$2D64

  ; Sprite 4
	dc.w    $CD71,$FFFE 
	dc.w    SPR4POS,$2D95
	dc.w    $CDE1,$FFFE 
	dc.w    SPR4POS,$2D85
	dc.w    $CE73,$FFFE 
	dc.w    SPR4POS,$2D97
	dc.w    $CEE1,$FFFE 
	dc.w    SPR4POS,$2D85
	dc.w    $CF75,$FFFE 
	dc.w    SPR4POS,$2D99
	dc.w    $CFE1,$FFFE 
	dc.w    SPR4POS,$2D85
	dc.w    $D077,$FFFE 
	dc.w    SPR4POS,$2D9B
	dc.w    $D0E1,$FFFE 
	dc.w    SPR4POS,$2D85
	dc.w    $D179,$FFFE 
	dc.w    SPR4POS,$2D9D
	dc.w    $D1E1,$FFFE 
	dc.w    SPR4POS,$2D85
	dc.w    $D27B,$FFFE 
	dc.w    SPR4POS,$2D9F
	dc.w    $D2E1,$FFFE 
	dc.w    SPR4POS,$2D85
	dc.w    $D37F,$FFFE 
	dc.w    SPR4POS,$2DA1
	dc.w    $D3E1,$FFFE 
	dc.w    SPR4POS,$2D85
	dc.w    $D48F,$FFFE 
	dc.w    SPR4POS,$2DA3
	dc.w    $D4E1,$FFFE 
	dc.w    SPR4POS,$2D85
	dc.w    $D581,$FFFE 
	dc.w    SPR4POS,$2DA5
	dc.w    $D5E1,$FFFE 
	dc.w    SPR4POS,$2D85
	dc.w    $D683,$FFFE 
	dc.w    SPR4POS,$2DA7
	dc.w    $D6E1,$FFFE 
	dc.w    SPR4POS,$2D85
	dc.w    $D785,$FFFE 
	dc.w    SPR4POS,$2DA9
	dc.w    $D7E1,$FFFE 
	dc.w    SPR4POS,$2D85
	dc.w    $D887,$FFFE 
	dc.w    SPR4POS,$2DAB
	dc.w    $D8E1,$FFFE 
	dc.w    SPR4POS,$2D85

	dc.w	$FFDF,$FFFE  ; Cross vertical boundary
	dc.w    $FFFF,$FFFE  ; End of Copper list

	;;
	;;  Sprite data 
	;;

SPRITE0:
			DC.W    $2D43,$3D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $7D43,$8D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $CD43,$DD00 ;VSTART, HSTART, VSTOP
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
			DC.W    $1D43,$2D04 ;VSTART, HSTART, VSTOP
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
			DC.W    $2D64,$3D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $CD64,$DD00 ;VSTART, HSTART, VSTOP
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
			DC.W    $1D64,$2D04 ;VSTART, HSTART, VSTOP
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
			DC.W    $2D85,$3D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $7D85,$8D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $CD85,$DD00 ;VSTART, HSTART, VSTOP
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
			DC.W    $1D85,$2D04 ;VSTART, HSTART, VSTOP
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
			DC.W    $2DA3,$3D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $7DA3,$8D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $CDA3,$DD00 ;VSTART, HSTART, VSTOP
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
			DC.W    $1DA3,$2D04 ;VSTART, HSTART, VSTOP
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
SPRITE_END:
	        DC.W    $0000,$0000 ; End of sprite data

bitplanes:
	ds.b    51201
	