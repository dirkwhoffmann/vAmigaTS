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
TRP0_INT_VECTOR		equ $80
TRP1_INT_VECTOR		equ $84
TRP2_INT_VECTOR		equ $88
TRPV_INT_VECTOR		equ $1C
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 6

MAIN:	

	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Disable DMA
	move.w  #$7FFF,DMACON(a1)

	; Install interrupt handlers
	lea	trapv(pc),a3
 	move.l	a3,TRPV_INT_VECTOR
	lea	irq1(pc),a3
 	move.l	a3,LVL1_INT_VECTOR
	lea	irq2(pc),a3
 	move.l	a3,LVL2_INT_VECTOR
	lea	irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR
	lea	irq4(pc),a3
 	move.l	a3,LVL4_INT_VECTOR
	lea	irq5(pc),a3
 	move.l	a3,LVL5_INT_VECTOR
	lea	irq6(pc),a3
 	move.l	a3,LVL6_INT_VECTOR

	; Setup bitplane pointers
	lea     bitplanes(pc),a2
	lea     copper(pc),a3
	moveq	#5,d0
.bitplaneloop:
	move.l 	a2,d1
	move.w	d1,2(a3)
	swap	d1
	move.w  d1,6(a3)
	addq	#8,a3
	dbra	d0,.bitplaneloop

	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w  #$8080,DMACON(a1)  ; Copper DMA
	move.w  #$8100,DMACON(a1)  ; Bitplane DMA
	move.w  #$8200,DMACON(a1)  ; DMA enable

	; Enable interrupts
	move.w  #$E89C,INTENA(a1)

;
; Main loop
;

mainLoop: 

synccpu:
	lea     VHPOSR(a1),a3     ; VHPOSR     

	; Wait until we have reached the middle of a frame
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
	cmp.w   #$4000,d2
	bne     .synccpu4
	move.w  #$000,COLOR00(a1)  

cpuwait:
	bra     mainLoop

;
; IRQ handlers
;

trapv:
	move.w  #$FF0,COLOR00(a1)
	bra 	retirq            ; Exit trap handler manually

irq1:
	move.w  #$0F0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.l  a7,a6             ; Save stack pointer to color registers
	move.l  #$DFF182,a7       ; Redirect stack pointer to color registers
	move    #$02,CCR
	trapv

irq2:
	move.w  #$0F0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.l  a7,a6             ; Save stack pointer to color registers
	move.l  #$DFF184,a7       ; Redirect stack pointer to color registers
	move    #$02,CCR
	trapv

irq3:
	move.w  #$0F0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.l  a7,a6             ; Save stack pointer to color registers
	move.l  #$DFF186,a7       ; Redirect stack pointer to color registers
	move    #$02,CCR
	trapv

irq4:
	move.w  #$0F0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.l  a7,a6             ; Save stack pointer to color registers
	move.l  #$DFF188,a7       ; Redirect stack pointer to color registers
	move    #$02,CCR
	trapv

irq5:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	rte 

irq6:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	rte 

retirq:
	move.w  #$000,COLOR00(a1)
	move.l  a6,a7             ; Restore stack pointer
	rte

;
; Copper
;

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
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0

	dc.w    $5039, $FFFE         ; WAIT
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

	;
	; 0 bitplanes
	; 

	dc.w    BPLCON0,$6200 

	dc.w    $5319, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $5519, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $5719, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $5919, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $5B21, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $5D21, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $5F21, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $6121, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $6323, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $6523, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $6723, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $6923, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 1 bitplane
	; 

	dc.w    $7001, $FFFE
	dc.w    BPLCON0,$6200

	dc.w    $7325, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $7525, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $7725, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $7925, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $7B27, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $7D27, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $7F27, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $8127, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $8329, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $8529, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $8729, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $8929, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 2 bitplanes
	; 

	dc.w    $9001, $FFFE
	dc.w    BPLCON0,$6200

	dc.w    $932B, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $952B, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $972B, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $992B, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $9B2D, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $9D2D, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $9F2D, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $A12D, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $A32F, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $A52F, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $A72F, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $A92F, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 3 bitplanes
	; 

	dc.w    $B001, $FFFE
	dc.w    BPLCON0,$6200

	dc.w    $B331, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $B531, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $B731, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $B931, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $BB33, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $BD33, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $BF33, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $C133, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $C335, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $C535, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $C735, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $C935, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 4 bitplanes
	; 

	dc.w    $D001, $FFFE
	dc.w    BPLCON0,$6200

	dc.w    $D313, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $D513, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $D713, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $D913, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $DB15, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $DD15, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $DF15, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $E115, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $E317, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $E517, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $E717, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $E917, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 5 bitplanes
	; 

	dc.w    $F001, $FFFE
	dc.w    BPLCON0,$6200

	dc.w    $F319, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $F519, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $F719, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $F919, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $FB21, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $FD21, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $FF21, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.w    $0123, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $0323, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $0523, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $0723, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $0923, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $0A01, $FFFE
	dc.w    BPLCON0,$0200        ; 0 bitplanes



	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00

stack: 
	ds.b 128,$00
