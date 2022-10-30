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

MAIN:

	; Load OCS base address
	lea CUSTOM,a1
	lea CUSTOM,a6

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a6)
	move.w  #$7FFF,DMACON(a6)
	move.w  #$200,BPLCON0(a6)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Install interrupt handlers
	lea	    irq1(pc),a3
 	move.l	a3,LVL1_INT_VECTOR
	lea     irq2(pc),a3
 	move.l	a3,LVL2_INT_VECTOR
	lea   	irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	lea	    irq4(pc),a3
 	move.l	a3,LVL4_INT_VECTOR
	lea	    irq5(pc),a3
 	move.l	a3,LVL5_INT_VECTOR
	lea	    irq6(pc),a3
 	move.l	a3,LVL6_INT_VECTOR

	; Install copper list
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a6)
	move.w  COPJMP1(a6),d0

	; Enable DMA
	move.w	#$8080,DMACON(a6)   ; Copper DMA 	
	move.w	#$8200,DMACON(a6)   ; DMAEN 

	; Enable interrupts
	move.w #$C000,INTENA(a6)

;
; Main loop
;

main: 
	jsr     synccpu            ; Sync CPU
	bra     main               ; Repeat

synccpu:                      
	lea     VHPOSR(a1),a3     ; VHPOSR     

	; Wait until we have reached the sync start line
.loop 
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$3000,d2
	bne     .loop
	and     #1,VPOSR(a1)
	bne     .loop

	; Sync horizontally
	move.w  #$F0F,COLOR00(a1)
.synccpu1:
	andi.w  #$F,(a3)          ; 16 cycles
	bne     .synccpu1         ; 10 cycles
	move.w  #$606,COLOR00(a1)
.synccpu2:
	andi.w  #$1F,(a3)         ; 16 cycles
	bne     .synccpu2         ; 10 cycles
	move.w  #$A0A,COLOR00(a1)
.synccpu3:
	andi.w  #$FF,(a3)         ; 16 cycles
	nop                       ;  4 cycles
	nop                       ;  4 cycles
	nop                       ;  4 cycles
	bne     .synccpu3         ; 10 cycles (if taken)

	; Adust horizontally
  	moveq #10,d2
.adjust:
    dbra d2,.adjust

	; Sync vertically
.synccpu4:
	nop 
	move.w  #$404,COLOR00(a1)
	ds.w    96,$4E71          ; NOPs to keep the horizontal position in each iteration
	move.w  (a3),d2     
	move.w  #$F0F,COLOR00(a1)  
	and     #$FF00,d2
	cmp.w   #$4500,d2
	bne     .synccpu4
	move.w  #$000,COLOR00(a1)  
	rts

irq1:    ; Does nothing yet

	move.w  #$7FFF,INTREQ(a6) ; Acknowledge
	rte

irq2:
	nop
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

irq3:
	nop
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

irq4:
	move.w  #$F00,$DFF180 
	;nop
	move.w  #$0F0,$DFF180 
	;nop
	move.w  #$00F,$DFF180 
	;nop
	move.w  #$000,$DFF180 
	rte

irq5:
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

irq6:
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
	dc.w	INTENA,$2880         ; Disable interrupts
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPL1MOD,0
	dc.w	BPL2MOD,0
	dc.w	BPLCON0,(0<<12)|$200 ; Disable all bitplanes

	dc.w    $5839, $FFFE         ; WAIT
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

	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts

	dc.w    $6139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE,$FFFE          ; 1
	dc.w    $01FE,$FFFE          ; 2
	dc.w    $01FE,$FFFE          ; 3
	dc.w    $01FE,$FFFE          ; 4
	dc.w    COLOR00,$000

	dc.w    $6839, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE,$FFFE          ; 1
	dc.w    $01FE,$FFFE          ; 2
	dc.w    $01FE,$FFFE          ; 3
	dc.w    $01FE,$FFFE          ; 4
	dc.w    $01FE,$FFFE          ; 5
	dc.w    COLOR00,$000

	dc.w    $7139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE,$FFFE          ; 1
	dc.w    $01FE,$FFFE          ; 2
	dc.w    $01FE,$FFFE          ; 3
	dc.w    $01FE,$FFFE          ; 4
	dc.w    $01FE,$FFFE          ; 5
	dc.w    $01FE,$FFFE          ; 6
	dc.w    COLOR00,$000

	dc.w    $7839, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE,$FFFE          ; 1
	dc.w    $01FE,$FFFE          ; 2
	dc.w    $01FE,$FFFE          ; 3
	dc.w    $01FE,$FFFE          ; 4
	dc.w    $01FE,$FFFE          ; 5
	dc.w    $01FE,$FFFE          ; 6
	dc.w    $01FE,$FFFE          ; 7
	dc.w    COLOR00,$000

	dc.w    $8139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE,$FFFE          ; 1
	dc.w    $01FE,$FFFE          ; 2
	dc.w    $01FE,$FFFE          ; 3
	dc.w    $01FE,$FFFE          ; 4
	dc.w    $01FE,$FFFE          ; 5
	dc.w    $01FE,$FFFE          ; 6
	dc.w    $01FE,$FFFE          ; 7
	dc.w    $01FE,$FFFE          ; 8
	dc.w    COLOR00,$000

	dc.w    $8839, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE,$FFFE          ; 1
	dc.w    $01FE,$FFFE          ; 2
	dc.w    $01FE,$FFFE          ; 3
	dc.w    $01FE,$FFFE          ; 4
	dc.w    $01FE,$FFFE          ; 5
	dc.w    $01FE,$FFFE          ; 6
	dc.w    $01FE,$FFFE          ; 7
	dc.w    $01FE,$FFFE          ; 8
	dc.w    $01FE,$FFFE          ; 9
	dc.w    COLOR00,$000

	dc.w    $9139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE,$FFFE          ; 1
	dc.w    $01FE,$FFFE          ; 2
	dc.w    $01FE,$FFFE          ; 3
	dc.w    $01FE,$FFFE          ; 4
	dc.w    $01FE,$FFFE          ; 5
	dc.w    $01FE,$FFFE          ; 6
	dc.w    $01FE,$FFFE          ; 7
	dc.w    $01FE,$FFFE          ; 8
	dc.w    $01FE,$FFFE          ; 9
	dc.w    $01FE,$FFFE          ; 10
	dc.w    COLOR00,$000

	dc.w    $9839, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE,$FFFE          ; 1
	dc.w    $01FE,$FFFE          ; 2
	dc.w    $01FE,$FFFE          ; 3
	dc.w    $01FE,$FFFE          ; 4
	dc.w    $01FE,$FFFE          ; 5
	dc.w    $01FE,$FFFE          ; 6
	dc.w    $01FE,$FFFE          ; 7
	dc.w    $01FE,$FFFE          ; 8
	dc.w    $01FE,$FFFE          ; 9
	dc.w    $01FE,$FFFE          ; 10
	dc.w    $01FE,$FFFE          ; 11
	dc.w    COLOR00,$000

	dc.w    $A139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE,$FFFE          ; 1
	dc.w    $01FE,$FFFE          ; 2
	dc.w    $01FE,$FFFE          ; 3
	dc.w    $01FE,$FFFE          ; 4
	dc.w    $01FE,$FFFE          ; 5
	dc.w    $01FE,$FFFE          ; 6
	dc.w    $01FE,$FFFE          ; 7
	dc.w    $01FE,$FFFE          ; 8
	dc.w    $01FE,$FFFE          ; 9
	dc.w    $01FE,$FFFE          ; 10
	dc.w    $01FE,$FFFE          ; 11
	dc.w    $01FE,$FFFE          ; 12
	dc.w    COLOR00,$000

	dc.w    $A839, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE,$FFFE          ; 1
	dc.w    $01FE,$FFFE          ; 2
	dc.w    $01FE,$FFFE          ; 3
	dc.w    $01FE,$FFFE          ; 4
	dc.w    $01FE,$FFFE          ; 5
	dc.w    $01FE,$FFFE          ; 6
	dc.w    $01FE,$FFFE          ; 7
	dc.w    $01FE,$FFFE          ; 8
	dc.w    $01FE,$FFFE          ; 9
	dc.w    $01FE,$FFFE          ; 10
	dc.w    $01FE,$FFFE          ; 11
	dc.w    $01FE,$FFFE          ; 12
	dc.w    $01FE,$FFFE          ; 13
	dc.w    COLOR00,$000

	dc.w    $B139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE, $FFFE         ; 1
	dc.w    $01FE, $FFFE         ; 2
	dc.w    $01FE, $FFFE         ; 3
	dc.w    $01FE, $FFFE         ; 4
	dc.w    $01FE, $FFFE         ; 5
	dc.w    $01FE, $FFFE         ; 6
	dc.w    $01FE, $FFFE         ; 7
	dc.w    $01FE, $FFFE         ; 8
	dc.w    $01FE, $FFFE         ; 9
	dc.w    $01FE, $FFFE         ; 10
	dc.w    $01FE, $FFFE         ; 11
	dc.w    $01FE, $FFFE         ; 12
	dc.w    $01FE, $FFFE         ; 13
	dc.w    $01FE,$FFFE          ; 14
	dc.w    COLOR00,$000

	dc.w    $B839, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE,$FFFE          ; 1
	dc.w    $01FE,$FFFE          ; 2
	dc.w    $01FE,$FFFE          ; 3
	dc.w    $01FE,$FFFE          ; 4
	dc.w    $01FE,$FFFE          ; 5
	dc.w    $01FE,$FFFE          ; 6
	dc.w    $01FE,$FFFE          ; 7
	dc.w    $01FE,$FFFE          ; 8
	dc.w    $01FE,$FFFE          ; 9
	dc.w    $01FE,$FFFE          ; 10
	dc.w    $01FE,$FFFE          ; 11
	dc.w    $01FE,$FFFE          ; 12
	dc.w    $01FE,$FFFE          ; 13
	dc.w    $01FE,$FFFE          ; 14
	dc.w    $01FE,$FFFE          ; 15
	dc.w    COLOR00,$000

	dc.w    $C139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE,$FFFE          ; 1
	dc.w    $01FE,$FFFE          ; 2
	dc.w    $01FE,$FFFE          ; 3
	dc.w    $01FE,$FFFE          ; 4
	dc.w    $01FE,$FFFE          ; 5
	dc.w    $01FE,$FFFE          ; 6
	dc.w    $01FE,$FFFE          ; 7
	dc.w    $01FE,$FFFE          ; 8
	dc.w    $01FE,$FFFE          ; 9
	dc.w    $01FE,$FFFE          ; 10
	dc.w    $01FE,$FFFE          ; 11
	dc.w    $01FE,$FFFE          ; 12
	dc.w    $01FE,$FFFE          ; 13
	dc.w    $01FE,$FFFE          ; 14
	dc.w    $01FE,$FFFE          ; 15
	dc.w    $01FE,$FFFE          ; 16
	dc.w    COLOR00,$000

	dc.w    $C839, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE,$FFFE          ; 1
	dc.w    $01FE,$FFFE          ; 2
	dc.w    $01FE,$FFFE          ; 3
	dc.w    $01FE,$FFFE          ; 4
	dc.w    $01FE,$FFFE          ; 5
	dc.w    $01FE,$FFFE          ; 6
	dc.w    $01FE,$FFFE          ; 7
	dc.w    $01FE,$FFFE          ; 8
	dc.w    $01FE,$FFFE          ; 9
	dc.w    $01FE,$FFFE          ; 10
	dc.w    $01FE,$FFFE          ; 11
	dc.w    $01FE,$FFFE          ; 12
	dc.w    $01FE,$FFFE          ; 13
	dc.w    $01FE,$FFFE          ; 14
	dc.w    $01FE,$FFFE          ; 15
	dc.w    $01FE,$FFFE          ; 16
	dc.w    $01FE,$FFFE          ; 17
	dc.w    COLOR00,$000

	dc.w    $D139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE,$FFFE          ; 1
	dc.w    $01FE,$FFFE          ; 2
	dc.w    $01FE,$FFFE          ; 3
	dc.w    $01FE,$FFFE          ; 4
	dc.w    $01FE,$FFFE          ; 5
	dc.w    $01FE,$FFFE          ; 6
	dc.w    $01FE,$FFFE          ; 7
	dc.w    $01FE,$FFFE          ; 8
	dc.w    $01FE,$FFFE          ; 9
	dc.w    $01FE,$FFFE          ; 10
	dc.w    $01FE,$FFFE          ; 11
	dc.w    $01FE,$FFFE          ; 12
	dc.w    $01FE,$FFFE          ; 13
	dc.w    $01FE,$FFFE          ; 14
	dc.w    $01FE,$FFFE          ; 15
	dc.w    $01FE,$FFFE          ; 16
	dc.w    $01FE,$FFFE          ; 17
	dc.w    $01FE,$FFFE          ; 18
	dc.w    COLOR00,$000

	dc.w    $D839, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE,$FFFE          ; 1
	dc.w    $01FE,$FFFE          ; 2
	dc.w    $01FE,$FFFE          ; 3
	dc.w    $01FE,$FFFE          ; 4
	dc.w    $01FE,$FFFE          ; 5
	dc.w    $01FE,$FFFE          ; 6
	dc.w    $01FE,$FFFE          ; 7
	dc.w    $01FE,$FFFE          ; 8
	dc.w    $01FE,$FFFE          ; 9
	dc.w    $01FE,$FFFE          ; 10
	dc.w    $01FE,$FFFE          ; 11
	dc.w    $01FE,$FFFE          ; 12
	dc.w    $01FE,$FFFE          ; 13
	dc.w    $01FE,$FFFE          ; 14
	dc.w    $01FE,$FFFE          ; 15
	dc.w    $01FE,$FFFE          ; 16
	dc.w    $01FE,$FFFE          ; 17
	dc.w    $01FE,$FFFE          ; 18
	dc.w    $01FE,$FFFE          ; 19
	dc.w    COLOR00,$000

	dc.w    $E139, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	; dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w    $01FE,$FFFE          ; 1
	dc.w    $01FE,$FFFE          ; 2
	dc.w    $01FE,$FFFE          ; 3
	dc.w    $01FE,$FFFE          ; 4
	dc.w    $01FE,$FFFE          ; 5
	dc.w    $01FE,$FFFE          ; 6
	dc.w    $01FE,$FFFE          ; 7
	dc.w    $01FE,$FFFE          ; 8
	dc.w    $01FE,$FFFE          ; 9
	dc.w    $01FE,$FFFE          ; 10
	dc.w    $01FE,$FFFE          ; 11
	dc.w    $01FE,$FFFE          ; 12
	dc.w    $01FE,$FFFE          ; 13
	dc.w    $01FE,$FFFE          ; 14
	dc.w    $01FE,$FFFE          ; 15
	dc.w    $01FE,$FFFE          ; 16
	dc.w    $01FE,$FFFE          ; 17
	dc.w    $01FE,$FFFE          ; 18
	dc.w    $01FE,$FFFE          ; 19
	dc.w    $01FE,$FFFE          ; 20
	dc.w    COLOR00,$000

	; dc.w	INTENA,$2880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.l	$fffffffe