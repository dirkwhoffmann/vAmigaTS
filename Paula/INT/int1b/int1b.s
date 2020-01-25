	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
CIAAPRA             equ $BFE001	
CIABPRB             equ $BFD100	
LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
entry:	
   ; Setup bitplane pointers
	lea     bitplanes(pc),a1
	lea     copper(pc),a2
	moveq	#4,d0
.bitplaneloop:
	move.l 	a1,d1
	move.w	d1,2(a2)
	swap	d1
	move.w  d1,6(a2)
	addq	#8,a2
	dbra	d0,.bitplaneloop

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Install interrupt handlers
	lea	level1InterruptHandler(pc),a3
 	move.l	a3,LVL1_INT_VECTOR
	lea	level2InterruptHandler(pc),a3
 	move.l	a3,LVL2_INT_VECTOR
	lea	level3InterruptHandler(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	lea	level4InterruptHandler(pc),a3
 	move.l	a3,LVL4_INT_VECTOR
	lea	level5InterruptHandler(pc),a3
 	move.l	a3,LVL5_INT_VECTOR
	lea	level6InterruptHandler(pc),a3
 	move.l	a3,LVL6_INT_VECTOR

	; Install copper list
	lea CUSTOM,a1
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Disable VBLANK interrupt
	move.w  #$20,$DFF09A

	; Enable DMA
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
		
	lea     mainLoop(pc),a3	
mainLoop:
	jmp     (a3)           ; 8 cycles

level1InterruptHandler:    ; SYNC CPU (Wait until HPOS % 7 == 0)

	move.w  #$F0F,$DFF180
	lea     $DFF006,a4
sync:
	andi.w  #$7,(a4)       ; 16 cycles
	bne     sync           ; 10 cycles
	move.w  #$000,$DFF180
	move.w  #$3FFF,$DFF09C ; Acknowledge
	rte

level2InterruptHandler:
	move.w  #$FFF,$DFF180 
	nop
	move.w  #$0F0,$DFF180 
	nop
	nop
	move.w  #$FF0,$DFF180 
	nop
	nop
	nop
	move.w  #$000,$DFF180 
	rte

level3InterruptHandler:
	move.w  #$FFF,$DFF180 
	nop
	move.w  #$888,$DFF180 
	nop
	nop
	move.w  #$F0F,$DFF180 
	nop
	nop
	nop
	move.w  #$000,$DFF180 
	rte

level4InterruptHandler:
	move.w  #$F00,$DFF180 
	nop
	move.w  #$0F0,$DFF180 
	nop
	nop
	move.w  #$00F,$DFF180 
	nop
	nop
	nop
	move.w  #$000,$DFF180 
	rte

level5InterruptHandler:
	move.w  #$00F,$DFF180 
	nop
	move.w  #$FFF,$DFF180 
	nop
	nop
	move.w  #$F00,$DFF180 
	nop
	nop
	nop
	move.w  #$000,$DFF180 
	rte

level6InterruptHandler:
	move.w  #$FF0,$DFF180 
	nop
	move.w  #$0F0,$DFF180 
	nop
	nop
	move.w  #$0FF,$DFF180 
	nop
	nop
	nop
	move.w  #$000,$DFF180 
	rte

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

	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPLCON0,(0<<12)|$200 ; Disable all bitplanes
	dc.w	INTENA,$C004         ; Enable level interrupt

	dc.w    $2001, $FFFE
	dc.w 	INTREQ,$8004         ; Level 1 interrupt (Sync CPU)

	dc.w    $2201, $FFFE
	dc.w	BPLCON0,(4<<12)|$200 ; Enable 4 bitplanes to sync CPU to bitplane raster

	dc.w    $2501, $FFFE
	dc.w	BPLCON0,(0<<12)|$200 ; Disable all bitplanes

	dc.w    $2C39, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$0F0
	dc.w    COLOR00,$000

	dc.w    $3139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $4139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $5139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $6139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $7139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $8139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $9139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $A139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $B139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $C139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $D139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $E139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.w	INTENA,$2880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
	