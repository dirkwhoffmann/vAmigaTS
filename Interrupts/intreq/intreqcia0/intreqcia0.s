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
LVL2_INT_VECTOR	    equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78

SCREEN_WIDTH		equ 320
SCREEN_HEIGHT		equ 256
SCREEN_WIDTH_BYTES	equ (SCREEN_WIDTH/8)
SCREEN_BIT_DEPTH	equ 5
SCREEN_RES	        equ 8 	; 8=lo resolution, 4=hi resolution
RASTER_X_START		equ $81	; hard coded coordinates from hardware manual
RASTER_Y_START		equ $2c
RASTER_X_STOP		equ RASTER_X_START+SCREEN_WIDTH
RASTER_Y_STOP		equ RASTER_Y_START+SCREEN_HEIGHT

entry:
	; Load OCS base address into a1
	lea CUSTOM,a1
	lea CUSTOM,a6 

	; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)

	; Install interrupt handlers
	lea	irq1(pc),a2
 	move.l	a2,LVL1_INT_VECTOR
	lea	irq2(pc),a2
 	move.l	a2,LVL2_INT_VECTOR
	lea	irq3(pc),a2
 	move.l	a2,LVL3_INT_VECTOR
	lea	irq4(pc),a2
 	move.l	a2,LVL4_INT_VECTOR
	lea	irq5(pc),a2
 	move.l	a2,LVL5_INT_VECTOR
	lea	irq6(pc),a2
 	move.l	a2,LVL6_INT_VECTOR
	
	;; Set up playfield
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a1)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a1)

	move.w	#(RASTER_X_START/2-SCREEN_RES),DDFSTRT(a1)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a1)
	
	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable Copper DMA
	; move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_MASTER),DMACON(a1)

	; Set BLTPRI bit
	move.w  #$8400,DMACON(a1)

	; Enable interrupts
	move.w	#$C984,INTENA(a1) 
	;move.w	#$8008,INTENA(a1) ; CIA A
 
	; Enable timer A interrupt in both CIAs
	move.b  #$81,CIAA_ICR
	move.b  #$81,CIAB_ICR


;
; Main loop
;

main: 
	moveq   #$0,d6
	move.b  (INTREQR+1)(a1),d6
	move.w  RGB(pc,d6),COLOR00(a1)
	bra.s   main

RGB: 
	DC.W    $FF0, $999, $00F, $FF0, $0FF, $F0F, $800, $080, $008, $880, $088, $808, $444, $AAA, $FFF, $400 
	DC.W    $0FF, $F0F, $880, $00F, $F44, $4F4, $088, $808, $880, $888, $A0A, $0AA, $AA0, $333, $FC8, $8FC 
	DC.W    $444, $FF0, $00F, $FF0, $0FF, $F0F, $800, $080, $008, $880, $088, $808, $444, $AAA, $FFF, $400 
	DC.W    $0FF, $F0F, $880, $00F, $F44, $4F4, $088, $808, $880, $888, $A0A, $0AA, $AA0, $333, $FC8, $8FC 

;
; IRQ handlers
;

irq1: 
	; Acknowledge
	move.w  #$FFF,COLOR00(a1)
	move.w  #$0004,INTREQ(a1)

	; Let CIAA signal an unnderflow in the ICR register
	move.w  #$00F,COLOR00(a1)
	move.b  #$08,CIAA_CRA      ; Select one-shot mode
	move.b  #$60,CIAA_TALO 
	move.b  #$04,CIAA_TAHI     ; Start timer

	move.w  #$000,COLOR00(a1)
	rte

irq2:                          ; Unused (CIA A interrupt level)
	;move.w  #$FFF,COLOR00(a1)	                
	move.w  #$0008,INTREQ(a1)  ; Acknowledge

	;move.w  #$0F0,COLOR00(a1)
	;move.w  #$FFF,COLOR00(a1)
	;move.w  #$000,COLOR00(a1)
	rte

irq3:                          ; Unused (VBLANK)
	move.w  #$0020,INTREQ(a1)  ; Acknowledge
	rte

irq4:
	btst    #7,(INTREQR+1)(a1)
	beq     .second

	move.w  #$FFF,COLOR00(a1)                
	move.w  #$0080,INTREQ(a1)  ; Acknowledge

	move.w  #$FF0,COLOR00(a1)                
	move.w  #$2008,INTREQ(a1)  ; Clear CIA IRQ bits in INTREQ

	move.w  #$000,COLOR00(a1)	                
	rte

.second

	move.w  #$FFF,COLOR00(a1)	                
	move.w  #$0100,INTREQ(a1) ; Acknowledge

	move.w  #$F0F,COLOR00(a1)     
	move.b  CIAA_ICR,d6        ; Clear CIA IRQ bits
	move.b  CIAB_ICR,d6    
	              
	move.w  #$000,COLOR00(a1)	                
	rte

irq5:
	; Acknowledge
	move.w  #$FFF,COLOR00(a1)	                	
	move.w  #$1800,INTREQ(a1)

	move.w  #$2008,INTREQ(a1) ; Clear CIA IRQ bits in INTREQ

	move.w  #$FF0,COLOR00(a1)	 
	rte

irq6:                          ; Unused (CIA A interrupt level)
	; Acknowledge
	move.w  #$FFF,COLOR00(a1)	                
	move.w  #$2000,INTREQ(a1)

	move.w  #$0FF,COLOR00(a1)
	move.w  #$FFF,COLOR00(a1)
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
	dc.w    INTREQ,$8004  ; Level 1 interrupt

	dc.w    $A039,$FFFE 
	dc.w    INTREQ,$8080  ; Level 4 interrupt (channel 0)

	dc.w    $E839,$FFFE 
	dc.w    INTREQ,$8100  ; Level 4 interrupt (channel 1)

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.w    $1039,$FFFE 
	dc.w    INTREQ,$8800  ; Level 5 interrupt

	dc.l    $fffffffe	
