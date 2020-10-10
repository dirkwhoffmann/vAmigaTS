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
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
MAIN:	

	; Load OCS base address into a1
	lea     CUSTOM,a1

	; Disable all bitplanes 
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)

	; Disable all DMA
	move.w  #$7FFF,DMACON(a1)

	; Install interrupt handlers
	lea	    irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	
	; Setup bitplane data
	lea     bitplane1,a2 
	lea     bitplane2,a3 
	move.w  #20000,d0
.loop:
	move.b  #$00,(a2)+
	move.b  #$00,(a3)+
	dbra    d0,.loop

	lea     bitplane1,a2 
	lea     bitplane2,a3 
	move.w  #1000,d0
.loop2:
	move.b  #$00,(a2)+  
	move.b  #$FF,(a3)+ 
	dbra    d0,.loop2

	; Setup colors
	move.w  #$000,COLOR00(a1)
	move.w  #$FF0,COLOR01(a1)
	move.w  #$FF0,COLOR17(a1)
	move.w  #$0FF,COLOR18(a1)
	move.w  #$F0F,COLOR19(a1)
	move.w  #$880,COLOR21(a1)
	move.w  #$077,COLOR22(a1)
	move.w  #$777,COLOR23(a1)

	; Install copper list
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w  #$8020,DMACON(a1) ; Sprite DMA
	move.w  #$8080,DMACON(a1) ; Copper DMA
	move.w  #$8100,DMACON(a1) ; Bitplane DMA
	move.w  #$8200,DMACON(a1) ; DMA enable
	
	; Enable interrupts
	move.w  #$C020,INTENA(a1)

	; Configure CLXCON
	move.w  #$F0C0,$98(a1)

.mainLoop:
	bra.b	.mainLoop

irq3:
	movem.l	d0-a6,-(sp)
	move.w	#$3FFF,INTREQ(a1)	; Acknowledge

	; Reset bitplane pointers
	lea     bitplane1,a2
	move.l	a2,BPL1PTH(a1)
	lea     bitplane2,a2
	move.l	a2,BPL2PTH(a1)

	; Reset sprite pointers
	lea	    SPRITE1(pc),a2
 	move.l	a2,SPR0PTH(a1)
	lea	    SPRITE2(pc),a2
 	move.l	a2,SPR4PTH(a1)

 	lea  	DUMMYSPRITE(pc),a2
 	move.l	a2,SPR1PTH(a1)
 	move.l	a2,SPR2PTH(a1)
 	move.l	a2,SPR3PTH(a1)
 	move.l	a2,SPR5PTH(a1)
 	move.l	a2,SPR6PTH(a1)
 	move.l	a2,SPR7PTH(a1)

	move.w  $0E(a1),d0       ; CLXDAT
	move.w  #$CCC,d5

.test0:                      ; Visualize d0
	lea	(bit0+2)(pc),a0
	move.w #$333,(a0)
	btst #0,d0
	beq.s .test1
	move.w d5,(a0)

.test1:
	lea	(bit1+2)(pc),a0
	move.w #$333,(a0)
	btst #1,d0
	beq.s .test2
	move.w d5,(a0)

.test2:
	lea	(bit2+2)(pc),a0
	move.w #$333,(a0)
	btst #2,d0
	beq.s .test3
	move.w d5,(a0)

.test3:
	lea	(bit3+2)(pc),a0
	move.w #$333,(a0)
	btst #3,d0
	beq.s .test4
	move.w d5,(a0)

.test4:
	lea	(bit4+2)(pc),a0
	move.w #$333,(a0)
	btst #4,d0
	beq.s .test5
	move.w d5,(a0)

.test5:
	lea	(bit5+2)(pc),a0
	move.w #$333,(a0)
	btst #5,d0
	beq.s .test6
	move.w d5,(a0)

.test6:
	lea	(bit6+2)(pc),a0
	move.w #$333,(a0)
	btst #6,d0
	beq.s .test7
	move.w d5,(a0)

.test7:
	lea	(bit7+2)(pc),a0
	move.w #$333,(a0)
	btst #7,d0
	beq.s .test8
	move.w d5,(a0)

.test8:
	lea	(bit8+2)(pc),a0
	move.w #$333,(a0)
	btst #8,d0
	beq.s .test9
	move.w d5,(a0)

.test9:
	lea	(bit9+2)(pc),a0
	move.w #$333,(a0)
	btst #9,d0
	beq.s .test10
	move.w d5,(a0)

.test10:
	lea	(bit10+2)(pc),a0
	move.w #$333,(a0)
	btst #10,d0
	beq.s .test11
	move.w d5,(a0)

.test11:
	lea	(bit11+2)(pc),a0
	move.w #$333,(a0)
	btst #11,d0
	beq.s .test12
	move.w d5,(a0)

.test12:
	lea	(bit12+2)(pc),a0
	move.w #$333,(a0)
	btst #12,d0
	beq.s .test13
	move.w d5,(a0)

.test13:
	lea	(bit13+2)(pc),a0
	move.w #$333,(a0)
	btst #13,d0
	beq.s .test14
	move.w d5,(a0)

.test14:
	lea	(bit14+2)(pc),a0
	move.w #$333,(a0)
	btst #14,d0
	beq.s .test15
	move.w d5,(a0)

.test15:
	lea	(bit15+2)(pc),a0
	move.w #$333,(a0)
	btst #15,d0
	beq.s .interruptComplete
	move.w d5,(a0)

.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte

copper:
	include	"colors.s"
	DC.W    COLOR17,$FF0
	DC.W    COLOR18,$0FF
	DC.W    COLOR19,$F0F
	DC.W    COLOR25,$FF0 
	DC.W    COLOR26,$444 
	DC.W    COLOR27,$F00 

	dc.w    DDFSTRT,$0038
	dc.w	DDFSTOP,$00D0
	dc.w	BPL1MOD,$0000 ; SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,$0000 ; SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
 
    ; 
	; Block 1 (LORES)
	;

	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	BPLCON0,(2<<12)|$200
	dc.w    COLOR01,$66F
	dc.w	$30D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w	$3601,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$36D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$3C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$3CD9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4201,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$42D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

 	; Disable bitplanes

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$48D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	dc.w	BPLCON0,$200 

	; Visualize register 

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$60D9,$FFFE  ; WAIT 
bit15:
	dc.w	COLOR00, $000

	dc.w	$6801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$68D9,$FFFE  ; WAIT 
bit14:
	dc.w	COLOR00, $000

	dc.w	$7001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$70D9,$FFFE  ; WAIT 
bit13:
	dc.w	COLOR00, $000

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$78D9,$FFFE  ; WAIT 
bit12:
	dc.w	COLOR00, $000

	dc.w	$8001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$80D9,$FFFE  ; WAIT 
bit11:
	dc.w	COLOR00, $000

	dc.w	$8801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$88D9,$FFFE  ; WAIT 
bit10:
	dc.w	COLOR00, $000

	dc.w	$9001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$90D9,$FFFE  ; WAIT 
bit9:
	dc.w	COLOR00, $000

	dc.w	$9801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$98D9,$FFFE  ; WAIT 
bit8:
	dc.w	COLOR00, $000

	dc.w	$A001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A0D9,$FFFE  ; WAIT 
bit7:
	dc.w	COLOR00, $000

	dc.w	$A801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A8D9,$FFFE  ; WAIT 
bit6:
	dc.w	COLOR00, $000

	dc.w	$B001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$B0D9,$FFFE  ; WAIT 
bit5:
	dc.w	COLOR00, $000

	dc.w	$B801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$B8D9,$FFFE  ; WAIT 
bit4:
	dc.w	COLOR00, $000

	dc.w	$C001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$C0D9,$FFFE  ; WAIT 
bit3:
	dc.w	COLOR00, $000

	dc.w	$C801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$C8D9,$FFFE  ; WAIT 
bit2:
	dc.w	COLOR00, $000

	dc.w	$D001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$D0D9,$FFFE  ; WAIT 
bit1:
	dc.w	COLOR00, $000

	dc.w	$D801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$D8D9,$FFFE  ; WAIT 
bit0:
	dc.w	COLOR00, $000

	dc.w	$E001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$E0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000
	
	dc.w	$FFDF,$FFFE  ; Cross vertical boundary

	dc.l	$fffffffe

	;;
	;;  Sprite data 
	;;

SPRITE1:
			DC.W    $3440,$4400 ; VSTART, HSTART, VSTOP
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

			;
SPRITE2:    DC.W    $3445,$4400 ; VSTART, HSTART, VSTOP
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
DUMMYSPRITE:
	        DC.W    $0000,$0000 ; End of sprite data

bitplane1:
	ds.b    20000
bitplane2:
	ds.b    20000

