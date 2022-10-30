	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
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

;
; Main
;

entry:	
	; Load OCS base address into a1
	lea CUSTOM,a1
		
    ; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,CIAB_ICR     ; CIA B
	move.b  #$7F,CIAA_ICR     ; CIA A

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)

	; Disable DMA
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

  	; Configure CIAs
	;move.b #$08,CIAB_CRA  ; Start timer A in one shot mode
	;move.b #$08,CIAB_CRB  ; Start timer B in one shot mode
	move.b #$87,CIAB_ICR  ; Enable CIA interrupt

	; Enable interrupts   -110 0111 1001 1100
	move.w  #$E79C,INTENA(a1)

;
; Main loop
;

main: 
	jsr     synccpu
	bra.s   main

;
; IRQ handlers
;

irq1:
	move.w  #$00F,COLOR00(a1)
	move.w  #$0004,INTREQ(a1)   ; Acknowledge
	move.b  #$80,CIAB_CRB       ; Set alarm
	move.b  #$00,CIAB_TODMID    ; 
	move.b  #$00,CIAB_TODHI     ; 
	move.b  #$08,CIAB_TODLO     ;
	move.b  #$00,CIAB_CRB       ; Set counter
	move.b  #$00,CIAB_TODMID    ; 
	move.b  #$00,CIAB_TODHI     ; 
	move.b  #$00,CIAB_TODLO     ;

	move.b  #$00,CIAB_TODLO     ; Does this write stop the timer?
	rte

irq2:
	move.w  #$00F,COLOR00(a1)
	move.w  #$0008,INTREQ(a1)   ; Acknowledge
	move.b  #$80,CIAB_CRB       ; Set alarm
	move.b  #$00,CIAB_TODMID    ; 
	move.b  #$00,CIAB_TODHI     ; 
	move.b  #$08,CIAB_TODLO     ;
	move.b  #$00,CIAB_CRB       ; Set counter
	move.b  #$00,CIAB_TODMID    ; 
	move.b  #$00,CIAB_TODHI     ; 
	move.b  #$00,CIAB_TODLO     ;

	move.b  #$00,CIAB_TODMID    ; Does this write stop the timer?
	rte

irq3:
	move.w  #$00F,COLOR00(a1)
	move.w  #$0010,INTREQ(a1)   ; Acknowledge
	move.b  #$80,CIAB_CRB       ; Set alarm
	move.b  #$00,CIAB_TODMID    ; 
	move.b  #$00,CIAB_TODHI     ; 
	move.b  #$08,CIAB_TODLO     ;
	move.b  #$00,CIAB_CRB       ; Set counter
	move.b  #$00,CIAB_TODMID    ; 
	move.b  #$00,CIAB_TODHI     ; 
	move.b  #$00,CIAB_TODLO     ;

	move.b  #$00,CIAB_TODHI     ; Does this write stop the timer?
	rte

irq4:
	move.w  #$00F,COLOR00(a1)
	btst    #0,INTREQR(a1)
	bne     irq4_aud1
	btst    #1,INTREQR(a1)
	bne     irq4_aud2
	btst    #2,INTREQR(a1)
	bne     irq4_aud3
        
	move.w  #$0080,INTREQ(a1)   ; Acknowledge
	move.b  #$00,CIAB_CRB       ; Set counter
	move.b  #$00,CIAB_TODMID    ; 
	move.b  #$00,CIAB_TODHI     ; 
	move.b  #$00,CIAB_TODLO     ;
	move.b  #$80,CIAB_CRB       ; Set alarm
	move.b  #$00,CIAB_TODMID    ; 
	move.b  #$00,CIAB_TODHI     ; 
	move.b  #$08,CIAB_TODLO     ;

	move.b  #$08,CIAB_TODLO     ; Does this write stop the timer?
	rte

irq4_aud1:

	move.w  #$0100,INTREQ(a1)   ; Acknowledge
	move.b  #$00,CIAB_CRB       ; Set counter
	move.b  #$00,CIAB_TODMID    ; 
	move.b  #$00,CIAB_TODHI     ; 
	move.b  #$00,CIAB_TODLO     ;
	move.b  #$80,CIAB_CRB       ; Set alarm
	move.b  #$00,CIAB_TODMID    ; 
	move.b  #$00,CIAB_TODHI     ; 
	move.b  #$08,CIAB_TODLO     ;

	move.b  #$00,CIAB_TODMID    ; Does this write stop the timer?
	rte

irq4_aud2:

	move.w  #$0200,INTREQ(a1)   ; Acknowledge
	move.b  #$00,CIAB_CRB       ; Set counter
	move.b  #$00,CIAB_TODMID    ; 
	move.b  #$00,CIAB_TODHI     ; 
	move.b  #$00,CIAB_TODLO     ;
	move.b  #$80,CIAB_CRB       ; Set alarm
	move.b  #$00,CIAB_TODMID    ; 
	move.b  #$00,CIAB_TODHI     ; 
	move.b  #$08,CIAB_TODLO     ;

	move.b  #$00,CIAB_TODHI     ; Does this write stop the timer?
	rte

irq4_aud3:

	move.w  #$F0F,COLOR00(a1)
	move.w  #$0400,INTREQ(a1)   ; Acknowledge
	rte

irq5:
	move.w  #$F0F,COLOR00(a1)
	move.w  #$0400,INTREQ(a1)   ; Acknowledge
	rte

irq6:                           ; Handler for CIA IRQ
	move.w  #$FF0,COLOR00(a1) 
	move.b  CIAB_ICR,d0         ; Acknowledge
	move.b  #$0,CIAB_CRB        ; Stop timer
	move.w	#$2000,INTREQ(a1)   ; Acknowledge 
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

copper:

	dc.w    $6001, $FFFE
	dc.w    COLOR00,$F00
	dc.w    $6101, $FFFE
	dc.w 	INTREQ,$8004         ; Level 1 interrupt
	
	dc.w    $7001, $FFFE
	dc.w    COLOR00,$F00
	dc.w    $7101, $FFFE
	dc.w 	INTREQ,$8008         ; Level 2 interrupt

	dc.w    $8001, $FFFE
	dc.w    COLOR00,$F00
	dc.w    $8101, $FFFE
	dc.w 	INTREQ,$8010         ; Level 3 interrupt

	dc.w    $9001, $FFFE
	dc.w    COLOR00,$F00
	dc.w    $9101, $FFFE
	dc.w 	INTREQ,$8080         ; Level 4 interrupt (channel 0)

	dc.w    $A001, $FFFE
	dc.w    COLOR00,$F00
	dc.w    $A101, $FFFE
	dc.w 	INTREQ,$8100         ; Level 4 interrupt (channel 1)

	dc.w    $B001, $FFFE
	dc.w    COLOR00,$F00
	dc.w    $B101, $FFFE
	dc.w 	INTREQ,$8200         ; Level 4 interrupt (channel 2)

	dc.w    $C001, $FFFE
	dc.w    COLOR00,$F00
	dc.w    $C101, $FFFE
	dc.w    COLOR00,$000

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.l	$fffffffe
