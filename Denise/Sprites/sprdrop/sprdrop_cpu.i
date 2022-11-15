	include "../../../../include/registers.i"
	include "../../../include/ministartup.i"
	
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
	move.b  #$7F,$BFDD00
	move.b  #$7F,$BFED01

	; Install interrupt handlers
	lea	    irq1(pc),a3 
 	move.l	a3,LVL1_INT_VECTOR
	lea	    irq2(pc),a3 
 	move.l	a3,LVL2_INT_VECTOR
	lea	    irq3(pc),a3 
 	move.l	a3,LVL3_INT_VECTOR
	lea	    irq4(pc),a3 
 	move.l	a3,LVL4_INT_VECTOR
	lea	    irq5(pc),a3 
 	move.l	a3,LVL5_INT_VECTOR
	lea	    irq6(pc),a3 
 	move.l	a3,LVL6_INT_VECTOR

	; Setup playfield
	move.w  #$1200,BPLCON0(a1) ; 1 bitplane
	move.w  #$0000,BPL1MOD(a1) 
	move.w  #$0000,BPLCON1(a1) ; No scroll
	move.w  #$0024,BPLCON2(a1) ; Sprites have priority over playfields
	move.w  #$0038,DDFSTRT(a1)
	move.w  #$00D0,DDFSTOP(a1)
	move.w  #$2C81,DIWSTRT(a1) 
	move.w  #$F4C1,DIWSTOP(a1)

	; Setup colors
	move.w  #$0008,COLOR00(a1)
	move.w  #$0000,COLOR01(a1)
	move.w  #$0FF0,COLOR17(a1)
	move.w  #$00FF,COLOR18(a1)
	move.w  #$0F0F,COLOR19(a1)

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
	move.w	#$E8AC,INTENA(a1)

.mainLoop:
	bra.b	.mainLoop

irq1:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	lea     PACMAN0+4,a2
	move.w  a2,SPR0PTL(a1)
	rte

irq2:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	lea     PACMAN1+4,a2
	move.w  a2,SPR1PTL(a1)
	rte

irq3:
	movem.l	d0-a6,-(sp)
	move.w  #$0020,INTREQ(a1)   ; Acknowledge
	move.w  #$000,COLOR00(a1)

	; Reset bitplane pointers
	lea     bitplanes(pc),a2
	move.l	a2,BPL1PTH(a1)

	; Reset sprite pointers
	lea	  	GHOST0(pc),a2
 	move.l	a2,SPR0PTH(a1)
	lea	    GHOST1(pc),a2
 	move.l	a2,SPR1PTH(a1)
	lea	    GHOST2(pc),a2
 	move.l	a2,SPR2PTH(a1)
	lea	    GHOST3(pc),a2
 	move.l	a2,SPR3PTH(a1)
	lea	    GHOST4(pc),a2
 	move.l	a2,SPR4PTH(a1)
	lea	    GHOST5(pc),a2
 	move.l	a2,SPR5PTH(a1)
	lea	    GHOST6(pc),a2
 	move.l	a2,SPR6PTH(a1)
	lea	    GHOST7(pc),a2
 	move.l	a2,SPR7PTH(a1)

	movem.l	(sp)+,d0-a6
	rte

irq4:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	lea     PACMAN2+4,a2
	move.w  a2,SPR2PTL(a1)
	rte

irq5:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	lea     PACMAN3+4,a2
	move.w  a2,SPR3PTL(a1)
	rte

irq6:
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
	lea     PACMAN4+4,a2
	move.w  a2,SPR4PTL(a1)
	rte

;
; Copper list
;

copper:

	;include	"colors.s"
	DC.W    COLOR17,$FF8 
	DC.W    COLOR18,$444 
	DC.W    COLOR19,$F00 

	DC.W    COLOR21,$8FF 
	DC.W    COLOR22,$444 
	DC.W    COLOR23,$F00 

	DC.W    COLOR25,$8F8 
	DC.W    COLOR26,$444 
	DC.W    COLOR27,$F00 

	DC.W    COLOR29,$F8F 
	DC.W    COLOR30,$444 
	DC.W    COLOR31,$00F 

	dc.w    BPLCON2, $0B	
	dc.w    BPLCON0, (1<<12)|$600

	dc.w    $3C00+OFFSET,$FFFE 
	dc.w    INTREQ, $8004   ; Level 1 interrupt
	dc.w    $4C00+OFFSET,$FFFE 
	dc.w    INTREQ, $8008   ; Level 2 interrupt
	dc.w    $5C00+OFFSET,$FFFE 
	dc.w    INTREQ, $8080   ; Level 4 interrupt
	dc.w    $6C00+OFFSET,$FFFE 
	dc.w    INTREQ, $8800   ; Level 5 interrupt
	dc.w    $7C00+OFFSET,$FFFE 
	dc.w    INTREQ, $A000   ; Level 6 interrupt

	dc.w    $ffdf,$fffe     ; Cross vertical boundary

	dc.w	BPLCON0,$200

	dc.l	$fffffffe

	;;
	;;  Sprite data 
	;;

	cnop 0,1024

GHOST0:
			DC.W    $3D80,$4D00 ;VSTART, HSTART, VSTOP
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
	        DC.W    $0000,$0000 ; End of sprite data
GHOST1:
			DC.W    $4D80,$5D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $0000,$0000 ; End of sprite data
GHOST2:
			DC.W    $5D80,$6D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $0000,$0000 ; End of sprite data
GHOST3:
			DC.W    $6D80,$7D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $0000,$0000 ; End of sprite data
GHOST4:
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
			DC.W    $0000,$0000 ; End of sprite data
GHOST5:
			DC.W    $8D80,$9D00 ;VSTART, HSTART, VSTOP
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
			DC.W    $0000,$0000 ; End of sprite data
GHOST6:
			DC.W    $9D80,$AD00 ;VSTART, HSTART, VSTOP
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
			DC.W    $0000,$0000 ; End of sprite data
GHOST7:
			DC.W    $AD80,$BD00 ;VSTART, HSTART, VSTOP
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
			DC.W    $0000,$0000 ; End of sprite data

	cnop 0,512

PACMAN0:
			DC.W    $3D80,$4D00 ;VSTART, HSTART, VSTOP
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
PACMAN1:
			DC.W    $4D80,$5D00 ;VSTART, HSTART, VSTOP
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
PACMAN2:
			DC.W    $5D80,$6D00 ;VSTART, HSTART, VSTOP
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
PACMAN3:
			DC.W    $6D80,$7D00 ;VSTART, HSTART, VSTOP
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
PACMAN4:
			DC.W    $7D80,$8D00 ;VSTART, HSTART, VSTOP
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
PACMAN5:
			DC.W    $8D80,$9D00 ;VSTART, HSTART, VSTOP
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
PACMAN6:
			DC.W    $9D80,$AD00 ;VSTART, HSTART, VSTOP
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
PACMAN7:
			DC.W    $AD80,$BD00 ;VSTART, HSTART, VSTOP
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
bitplanes:
	ds.b    51201