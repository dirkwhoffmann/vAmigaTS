	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
CIAA_PRA            equ $BFE001	
CIAA_PRB            equ $BFE101
CIAA_DDRA           equ $BFE201
CIAA_DDRB           equ $BFE301
CIAA_TALO           equ $BFE401
CIAA_TAHI           equ $BFE501
CIAA_TBLO           equ $BFE601
CIAA_TBHI           equ $BFE701
CIAA_TODLO          equ $BFE801
CIAA_TODMID         equ $BFE901
CIAA_TODHI          equ $BFEA01
CIAA_SDR            equ $BFEC01
CIAA_ICR            equ $BFED01
CIAA_CRA            equ $BFEE01
CIAA_CRB            equ $BFEF01

CIAB_PRA            equ $BFD000	
CIAB_PRB            equ $BFD100
CIAB_DDRA           equ $BFD200
CIAB_DDRB           equ $BFD300
CIAB_TALO           equ $BFD400
CIAB_TAHI           equ $BFD500
CIAB_TBLO           equ $BFD600
CIAB_TBHI           equ $BFD700
CIAB_TODLO          equ $BFD800
CIAB_TODMID         equ $BFD900
CIAB_TODHI          equ $BFDA00
CIAB_SDR            equ $BFDC00
CIAB_ICR            equ $BFDD00
CIAB_CRA            equ $BFDE00
CIAB_CRB            equ $BFDF00

LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
;
; Main
;

entry:	
	; Load OCS base address into a1
	lea CUSTOM,a1

    ; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Configure CIAs
	move.b  #$7F,CIAA_ICR
	move.b  #$81,CIAA_ICR  ; Enable Timer A interrupts
	move.b  #$7F,CIAB_ICR
	move.b  #$81,CIAB_ICR  ; Enable Timer A interrupts
	
	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)

	; Disable all DMA
	move.w  #$7FFF,DMACON(a1)
		
	; Install interrupt handlers
	lea	    irq1(pc),a2
 	move.l  a2,LVL1_INT_VECTOR
	lea	    irq2(pc),a2
 	move.l  a2,LVL2_INT_VECTOR
	lea	    irq3(pc),a2
 	move.l  a2,LVL3_INT_VECTOR
	lea	    irq4(pc),a2
 	move.l	a2,LVL4_INT_VECTOR
	lea	    irq5(pc),a2
 	move.l	a2,LVL5_INT_VECTOR
	lea	    irq6(pc),a2
 	move.l	a2,LVL6_INT_VECTOR

	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable Copper DMA
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_MASTER),DMACON(a1)

	; Enable interrupts
	move.w  #$E01C,INTENA(a1)

;
; Main loop
;

main: 
	jsr     synccpu
;  	move.w  #2000,d3
;loop1:
;	dbra    d3,loop1
;   	move.w  #1000,d3
;	move.w  #$888,d4
;	move.w  #$000,d5
;loop2:
;	move.w  d4,COLOR00(a1)
;	move.w  d5,COLOR00(a1)
;   dbra    d3,loop2
	bra.s   main

;
; IRQ handlers
;

irq1:
	move.w  #$F00,COLOR00(a1)
	move.w  #$0004,INTREQ(a1)   ; Acknowledge

	move.b  #$08,CIAA_CRA       ; One-shot timers
	move.b  #$08,CIAB_CRA       
	move.b  #$10,CIAA_TALO
	move.b  #$20,CIAB_TALO
	move.b  #$00,CIAA_TAHI      ; Start timer	
	move.b  #$00,CIAB_TAHI      ; Start timer	
	move.w  #$00F,COLOR00(a1)
	rte

irq2:
	move.w  #$FF0,COLOR00(a1)
	move.b  CIAA_ICR,d0
	move.w  #$0008,INTREQ(a1)   ; Acknowledge
	rte

irq3:
	move.w  #$0010,INTREQ(a1)   ; Acknowledge
	move.w  #$00F,COLOR00(a1)
	move.w  #$FFF,COLOR00(a1)
	move.w  #$00F,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	rte

irq4:
	move.w  #$0080,INTREQ(a1)   ; Acknowledge
	move.w  #$0FF,COLOR00(a1)
	move.w  #$FFF,COLOR00(a1)
	move.w  #$0FF,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	rte

irq5:
	move.w  #$0800,INTREQ(a1)   ; Acknowledge
	move.w  #$FFF,COLOR00(a1)
	move.w  #$0F0,COLOR00(a1)
	move.w  #$FFF,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	rte

irq6:
	move.w  #$000,COLOR00(a1)
	move.b  CIAB_ICR,d0
	move.w  #$2000,INTREQ(a1)   ; Acknowledge
	rte

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
	rts

;
; Copper
;

copper:
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPL1MOD,$0 
	dc.w	BPL2MOD,$0
	dc.w	BPLCON0,(0<<12)|$200 ; Disable all bitplanes

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

	dc.w    $5539, $FFFE
	dc.w    COLOR00,$FFF
	dc.w 	INTREQ,$8004         ; Level 1 interrupt

	dc.w    $5739, $FFFE
	;dc.w    COLOR00,$0FF0
	;dc.w 	INTREQ,$8008         ; Level 2 interrupt

	dc.w    $5939, $FFFE
	;dc.w    COLOR00,$0FF0
	;dc.w 	INTREQ,$8010         ; Level 3 interrupt

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
	