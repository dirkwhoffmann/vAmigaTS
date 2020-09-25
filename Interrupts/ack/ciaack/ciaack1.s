	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"
	
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
LVL2_INT_VECTOR	    equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78

MAIN:
	; Load OCS base address into a1
	lea     CUSTOM,a1
	moveq   #0,d0

	; Disable all bitplanes 
	move.w  #$200,BPLCON0(a1)

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Disable DMA
	move.w  #$7FFF,DMACON(a1)

	; Install interrupt handlers
	lea	    irq1(pc),a3
 	move.l	a3,LVL1_INT_VECTOR
	lea	    irq2(pc),a3
 	move.l	a3,LVL2_INT_VECTOR
	;lea	    irq3(pc),a3
 	;move.l	a3,LVL3_INT_VECTOR
	lea	    irq4(pc),a3
 	move.l	a3,LVL4_INT_VECTOR
	;lea	    irq5(pc),a3
 	;move.l	a3,LVL5_INT_VECTOR
	;lea	    irq6(pc),a3
 	;move.l	a3,LVL6_INT_VECTOR
	
	; Install Copper list
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d1

	; Enable DMA
	move.w  #$8080,DMACON(a1)  ; Copper DMA
	move.w  #$8200,DMACON(a1)  ; DMA enable

	; Enable interrupts
	move.w	#$8004,INTENA(a1) ; Level 1 (Soft)
	move.w	#$8008,INTENA(a1) ; Level 2 (CIA A)
	move.w	#$8080,INTENA(a1) ; Level 4
	move.w	#$C000,INTENA(a1) ; INT enable
 

;
; Main loop
;

main: 
	jsr     synccpu            ; Sync CPU
	bra     main               ; Repeat

;
; IRQ handlers
;

irq1: 
	; Acknowledge
	move.w  #$FFF,COLOR00(a1)
	move.w  #$0004,INTREQ(a1)
	
	addq    #1,d0
	cmpi    #5,d0
	bne     .cont
	moveq   #1,d0
.cont:

	; Let CIAA signal an unnderflow in the ICR register
	move.w  #$00F,COLOR00(a1)
	move.b  #$81,CIAA_ICR      ; Enable Timer A interrupt
	move.b  #$08,CIAA_CRA      ; Select one-shot mode
	move.b  #$02,CIAA_TALO 
	move.b  #$00,CIAA_TAHI     ; Start timer
	move.w  #$000,COLOR00(a1)
	rte

irq2:                          ; CIA A IRQ handler
	move.w  #$888,COLOR00(a1)
	cmpi    #1,d0
	beq     test1
	cmpi    #2,d0
	beq     test2
	cmpi    #3,d0
	beq     test3
	cmpi    #4,d0
	beq     test4
	move.w  #$F0F,COLOR00(a1)  ; Should never be reached
	rte

test1:
	move.w  #$F00,COLOR00(a1)
	move.w  #$0008,INTREQ(a1)  ; Acknowledge
	move.w  #$000,COLOR00(a1)
	rte

test2:
	move.w  #$0F0,COLOR00(a1)
	move.w  #$0008,INTREQ(a1)  ; Acknowledge
	move.b  CIAA_ICR,d1	       ; Acknowledge (CIA)
	move.w  #$000,COLOR00(a1)
	rte

test3:
	move.w  #$00F,COLOR00(a1)
	move.b  CIAA_ICR,d1	       ; Acknowledge (CIA)
	move.w  #$0008,INTREQ(a1)  ; Acknowledge
	move.w  #$000,COLOR00(a1)
	rte

test4:
	move.w  #$0FF,COLOR00(a1)
	move.b  #$01,CIAA_ICR      ; 
	move.w  #$0008,INTREQ(a1)  ; Acknowledge
	move.w  #$000,COLOR00(a1)
	rte

irq4:
	; Acknowledge
	move.w  #$FFF,COLOR00(a1)	            
	move.b  CIAA_ICR,d1	       ; Acknowledge (CIA)
	move.w  #$0088,INTREQ(a1)  ; Acknowledge
	move.w  #$000,COLOR00(a1)	 
	rte

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

copper:
	;; bitplane pointers must be first else poking addresses will be incorrect
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

	; Draw 
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

	dc.w    $6039,$FFFE 
	dc.w    INTREQ,$8004  ; Level 1 interrupt (Start CIA)
	dc.w    $7039,$FFFE 
	dc.w    INTREQ,$8080  ; Level 4 interrupt (Force ack CIA IRQ)

 	dc.w    $8039,$FFFE 
	dc.w    INTREQ,$8004  ; Level 1 interrupt (Start CIA)
	dc.w    $9039,$FFFE 
	dc.w    INTREQ,$8080  ; Level 4 interrupt (Force ack CIA IRQ)

	dc.w    $A039,$FFFE 
	dc.w    INTREQ,$8004  ; Level 1 interrupt (Start CIA)
	dc.w    $B039,$FFFE 
	dc.w    INTREQ,$8080  ; Level 4 interrupt (Force ack CIA IRQ)

	dc.w    $C039,$FFFE 
	dc.w    INTREQ,$8004  ; Level 1 interrupt (Start CIA)
	dc.w    $D039,$FFFE 
	dc.w    INTREQ,$8080  ; Level 4 interrupt (Force ack CIA IRQ)

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.l    $fffffffe	
