	include "../../../../include/registers.i"
	include "../../../include/ministartup.i"

DDFSTRT_INI			equ $70
DDFSTOP_INI			equ $A8

LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78

RULER	MACRO
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FFF
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F0F
	dc.w    COLOR00,$000
	ENDM

STRIPE	MACRO
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$000
	ENDM

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
	lea	    irq1(pc),a3 
 	move.l	a3,LVL1_INT_VECTOR
	lea	    irq2(pc),a3 
 	move.l	a3,LVL2_INT_VECTOR
	 
	; Setup playfield
	move.w  #$0000,BPL1MOD(a1) 
	move.w  #$0000,BPLCON1(a1)
	move.w  #DDFSTRT_INI,DDFSTRT(a1)
	move.w  #DDFSTOP_INI,DDFSTOP(a1)
	move.w  #$2C81,DIWSTRT(a1) 
	move.w  #$74C1,DIWSTOP(a1)

	; Setup bitplane pointers
	lea     bitplanes,a2
	lea     copper,a3
	moveq	#5,d0
.bitplaneloop:
	move.l 	a2,d1
	move.w	d1,2(a3)
	swap	d1
	move.w  d1,6(a3)
	addq	#8,a3
	dbra	d0,.bitplaneloop

	; Setup bitplane data
	lea bitplanes(pc),a0 
	move.w #2048,d0
.loop:
	move.l #$AAAAAAAA,(a0)+
	dbra d0,.loop
	
	; Install copper list
	lea		copper,a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w  #$8080,DMACON(a1)  ; Copper DMA
	move.w  #$8100,DMACON(a1)  ; Bitplane DMA
	move.w  #$8200,DMACON(a1)  ; DMA enable

	; Enable interrupts
	move.w	#$C00C,INTENA(a1)

;
; Main loop
;

mainloop: 
	jsr     synccpu
delayloop:
   	move.w  #8000,d3
.loop1:
	dbra    d3,.loop1
   	move.w  #300,d3
	move.w  #$888,d4
	move.w  #$000,d5
.loop2:
	move.w  d4,COLOR00(a1)
	move.w  d5,COLOR00(a1)
    dbra    d3,.loop2
	bra.s   mainloop

irq1:
	move.w  #$FF0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #$F00,COLOR00(a1)
	IRQ1
	move.w  #$8008,INTREQ(a1) ; Level 2 interrupt
	nop
	nop
	nop
	nop
	rte

irq2: 
	move.w  #$0F0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #$FFF,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
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

cpuwait:
	rts

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
	dc.w    COLOR00,$000
	dc.w    COLOR15,$555
	dc.w    COLOR31,$555
	dc.w    BPLCON0,$0200

	;
	; Round 1
	;

	dc.w    $5039,$FFFE    ; WAIT
	RULER
	dc.w    $5201,$FFFE    ; WAIT
	dc.w    BPLCON0,$4200 

	dc.w    $5401+OFFSET,$FFFE 
	dc.w    INTREQ,$8004   		

	dc.w    $5603+OFFSET,$FFFE
	dc.w    INTREQ,$8004   

	dc.w    $5805+OFFSET,$FFFE 
	dc.w    INTREQ,$8004  

	dc.w    $5A07+OFFSET,$FFFE   
	dc.w    INTREQ,$8004  

	dc.w    $5C09+OFFSET,$FFFE 
	dc.w    INTREQ,$8004 

	dc.w    $5E0B+OFFSET,$FFFE  
	dc.w    INTREQ,$8004

	dc.w    $600D+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	dc.w    $620F+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	dc.w    $6411+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	dc.w    $6613+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	dc.w    $6815+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	dc.w    $6A17+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	dc.w    $6C19+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	;
	; Round 2
	;

	dc.w    $7039,$FFFE    ; WAIT
	RULER
	dc.w    $7201,$FFFE 
	dc.w    BPLCON0,$5200 

	dc.w    $7401+OFFSET,$FFFE
	dc.w    INTREQ,$8004 

	dc.w    $7603+OFFSET,$FFFE
	dc.w    INTREQ,$8004 

	dc.w    $7805+OFFSET,$FFFE
	dc.w    INTREQ,$8004 

	dc.w    $7A07+OFFSET,$FFFE
	dc.w    INTREQ,$8004 

	dc.w    $7C09+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	dc.w    $7E0B+OFFSET,$FFFE
	dc.w    INTREQ,$8004 

	dc.w    $800D+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	dc.w    $820F+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	dc.w    $8411+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	dc.w    $8613+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	dc.w    $8815+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	dc.w    $8A17+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	dc.w    $8C19+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	;
	; Round 3
	;

	dc.w    $9001,$FFFE    ; WAIT
	dc.w    BPLCON0,$0200
	dc.w    $9039,$FFFE    ; WAIT
	RULER
	dc.w    $9201,$FFFE
	dc.w    BPLCON0,$6200 

	dc.w    $9401+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	dc.w    $9603+OFFSET,$FFFE
	dc.w    INTREQ,$8004 
	dc.w    $9661,$FFFE 

	dc.w    $9805+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	dc.w    $9A07+OFFSET,$FFFE
	dc.w    INTREQ,$8004

	dc.w    $9C09+OFFSET,$FFFE
	dc.w    INTREQ,$8004 

	dc.w    $9E0B+OFFSET,$FFFE
	dc.w    INTREQ,$8004 

	dc.w    $A00D+OFFSET,$FFFE
	dc.w    INTREQ,$8004 

	dc.w    $A20F+OFFSET,$FFFE
	dc.w    INTREQ,$8004 

	dc.w    $A411+OFFSET,$FFFE
	dc.w    INTREQ,$8004 

	dc.w    $A613+OFFSET,$FFFE
	dc.w    INTREQ,$8004 

	dc.w    $A815+OFFSET,$FFFE
	dc.w    INTREQ,$8004 

	dc.w    $AA17+OFFSET,$FFFE
	dc.w    INTREQ,$8004 

	dc.w    $AC19+OFFSET,$FFFE
	dc.w    INTREQ,$8004 

	dc.w	$ffdf,$fffe    ; Cross vertical boundary
	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
