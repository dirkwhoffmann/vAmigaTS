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

MAIN:	

	; Load OCS base address into a1
	lea    CUSTOM,a1

	; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Disable DMA and interrupts
	move.w  #$7FFF,DMACON(a1)
	move.w  #$7FFF,INTENA(a1)

	; Install interrupt handlers
	lea	    irq1(pc),a3 
 	move.l	a3,LVL1_INT_VECTOR
	lea	    irq2(pc),a3 
 	move.l	a3,LVL2_INT_VECTOR
	lea	    irq3(pc),a3 
 	move.l	a3,LVL3_INT_VECTOR
	lea	    irq6(pc),a3 
 	move.l	a3,LVL6_INT_VECTOR

	; Enable Interrupts
	move.w	#$8020,INTENA(a1)   ; VERTB (3)
	move.w	#$A000,INTENA(a1)   ; CIA B (6)
	move.w	#$8008,INTENA(a1)   ; CIA A (2)
	move.w	#$8004,INTENA(a1)   ; SOFT  (1)
	move.w	#$C000,INTENA(a1)   ; Enable

	; Setup Copper
	lea	    copper(pc),a0       ; Get pointer to Copper list
	move.l	a0,COP1LC(a1)       ; Write pointer to Copper location register 1
 	move.w  COPJMP1(a1),d1      ; Jump to the first Copper list
	moveq   #0,d0

	; Enable DMA
	; move.w	#$8080,DMACON(a1)   ; Copper DMA
	move.w	#$8200,DMACON(a1)   ; DMA enable

.mainLoop:
	; jsr     synccpu
	bra.s   .mainLoop

irq1: 
	move.w	#$0004,INTREQ(a1)	        ; Acknowledge

	cmp     #0,d0
	bne     .contB
	addq    #1,d0

	; Start CIAA timer
	move.b  #$82,CIAA_ICR               ; Enable Timer B interrupt
	move.b  #$82,CIAA_TBLO
	move.b  #$37,CIAA_TBHI              ; Start timer	
	move.b  #$11,CIAA_CRB               ; Continuous mode
	bra     .exit

.contB:

	cmp     #1,d0
	bne     .exit
	addq    #1,d0

	; Start CIAB timer
	move.b  #$82,CIAB_ICR               ; Enable Timer B interrupt
	move.b  #$82,CIAB_TBLO
	move.b  #$37,CIAB_TBHI              ; Start timer	
	move.b  #$11,CIAB_CRB               ; Continuous mode

.exit:
	rte

irq2: 
	move.b  CIAA_ICR,d4                 ; Acknowledge (CIA)
	move.w	#$0008,INTREQ(a1)	        ; Acknowledge

	move.w  #$00F,COLOR00(a1)
	move.w  #$FF,d4
.loop:
	dbra    d4,.loop
	move.w  #$000,COLOR00(a1)
	rte

irq6:
	move.b  CIAB_ICR,d4                 ; Acknowledge (CIA)
	move.w	#$2000,INTREQ(a1)	        ; Acknowledge

	move.w  #$0FF,COLOR00(a1)
	move.w  #$FF,d4
.loop:
	dbra    d4,.loop
	move.w  #$000,COLOR00(a1)
	rte

irq3:
	move.w	#$0020,INTREQ(a1)	        ; Acknowledge
	move.w	#$8080,DMACON(a1)           ; Copper DMA

;	move.w  #$1FF,d4
;.loop:
;	dbra    d4,.loop
	;move.w  #$8004,INTREQ(a1)           ; Level 1 IRQ (Start timer A if not started already)

;	move.w  #$3FF,d5
;.loop2:
;	dbra    d5,.loop2
	;move.w  #$8004,INTREQ(a1)           ; Level 1 IRQ (Start timer A if not started already)

	rte

synccpu:
	lea     VHPOSR(a1),a3     ; VHPOSR     
	
	; Wait until we have reached the middle of a frame
.loop 
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$A000,d2
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
	cmp.w   #$B000,d2
	bne     .synccpu4
	move.w  #$000,COLOR00(a1)  
	rts

copper: 	
	; dc.w    COLOR00,$F0F

	dc.w    $7001,$FFFE  ; WAIT
	dc.w    INTREQ,$8004 ; Level 1 IRQ (Start timer A if not started already)

	dc.w    $9001,$FFFE  ; WAIT
	dc.w    INTREQ,$8004 ; Level 1 IRQ (Start timer A if not started already)

	dc.l	$fffffffe
