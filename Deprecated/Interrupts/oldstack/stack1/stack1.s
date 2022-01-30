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
	moveq	#4,d0
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
	; move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_MASTER),DMACON(a1)

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
	bra.s   cpuwait

;
; IRQ handlers
;

irq1:
	move.w  #$FF0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$F00,COLOR00(a1)

	move.w  #$000,COLOR00(a1)
	move.w  #$000,COLOR01(a1)
	move.w  #$000,COLOR02(a1)

	move.l  #$DFF182,a7   ; Redirect stack pointer to color registers
	move    #$F,SR        ; Restore SR manually  

	bra.s	cpuwait       ; Exit IRQ handler manually

irq2:
	move.w  #$FF0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$F00,COLOR00(a1)
	
	move.w  #$000,COLOR00(a1)
	move.w  #$000,COLOR01(a1)
	move.w  #$000,COLOR02(a1)

	move.l  #$DFF184,a7   ; Redirect stack pointer to color registers
	move    #$F,SR        ; Restore SR manually  
	bra 	cpuwait       ; Exit IRQ handler manually

irq3:
	move.w  #$FF0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$F00,COLOR00(a1)

	move.w  #$000,COLOR00(a1)
	move.w  #$000,COLOR01(a1)
	move.w  #$000,COLOR02(a1)

	move.l  #$DFF186,a7   ; Redirect stack pointer to color registers
	move    #$F,SR        ; Restore SR manually  
	bra 	cpuwait       ; Exit IRQ handler manually

irq4:
	move.w  #$FF0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	move.w  #$F00,COLOR00(a1)

	move.w  #$000,COLOR00(a1)
	move.w  #$000,COLOR01(a1)
	move.w  #$000,COLOR02(a1)

	move.l  #$DFF186,a7   ; Redirect stack pointer to color registers
	move    #$F,SR        ; Restore SR manually  
	bra 	mainLoop      ; Branch back to main loop

irq5:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
	rte 

irq6:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge
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

	dc.w    BPLCON0,$0200 

	dc.w    $5339, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $5539, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $5739, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $5939, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $5B41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $5D41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $5F41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $6141, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $6343, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $6543, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $6743, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $6943, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 1 bitplane
	; 

	dc.w    $7001, $FFFE
	dc.w    BPLCON0,$1200

	dc.w    $7339, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $7539, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $7739, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $7939, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $7B41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $7D41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $7F41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $8141, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $8343, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $8543, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $8743, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $8943, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 2 bitplanes
	; 

	dc.w    $9001, $FFFE
	dc.w    BPLCON0,$2200

	dc.w    $9339, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $9539, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $9739, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $9939, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $9B41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $9D41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $9F41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $A141, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $A343, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $A543, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $A743, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $A943, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 3 bitplanes
	; 

	dc.w    $B001, $FFFE
	dc.w    BPLCON0,$3200

	dc.w    $B339, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $B539, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $B739, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $B939, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $BB41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $BD41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $BF41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $C141, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $C343, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $C543, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $C743, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $C943, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 4 bitplanes
	; 

	dc.w    $D001, $FFFE
	dc.w    BPLCON0,$4200

	dc.w    $D339, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $D539, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $D739, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $D939, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $DB41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $DD41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $DF41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $E141, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $E343, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $E543, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $E743, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $E943, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	;
	; 5 bitplanes
	; 

	dc.w    $F001, $FFFE
	dc.w    BPLCON0,$5200

	dc.w    $F339, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $F539, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $F739, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $F939, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $FB41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $FD41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $FF41, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.w    $0141, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt
	dc.w    $0343, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	dc.w    $0543, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8008         ; Level 2 interrupt
	dc.w    $0743, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8010         ; Level 3 interrupt
	dc.w    $0943, $FFFE         ; Wait
	dc.w    COLOR00,$F4F
	dc.w 	INTREQ,$8080         ; Level 4 interrupt

	dc.w    $0A01, $FFFE
	dc.w    BPLCON0,$0200        ; 0 bitplanes



	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00

stack: 
	ds.b 128,$00
