	include "../../../../include/registers.i"
	include "../../../include/ministartup.i"

LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78

DOIRQ1	MACRO
	dc.w    COLOR00,$444
	dc.w    INTREQ,$8004
	ENDM

DOIRQ2	MACRO
	dc.w    COLOR00,$AAA
	dc.w    INTREQ,$8008
	ENDM

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
	move.w  #$F88,COLOR00(a1)
	move.w  #$88F,COLOR00(a1)
	move.w  #$F88,COLOR00(a1)
	move.w  #$88F,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #$000,COLOR00(a1)
	rte

irq2:
	move.w  #$FF0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
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

	dc.w    $5401+OFFSET1,$FFFE 
	DOIRQ1	
	DOIRQ2

	dc.w    $5601+OFFSET1,$FFFE
	DOIRQ1   
	dc.w    $5601+OFFSET1,$FFFE
	DOIRQ2   

	dc.w    $5801+OFFSET1,$FFFE 
	DOIRQ1  
	dc.w    $580F+OFFSET1,$FFFE 
	DOIRQ2 

	dc.w    $5A01+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $5A11+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $5C01+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $5C13+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $5E01+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $5E15+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $6001+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $6017+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $6201+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $6219+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $6401+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $641B+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $6601+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $661D+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $6801+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $681F+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $6A01+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $6A21+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $6C01+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $6C23+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $6E01+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $6E25+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $7001+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $7027+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $7201+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $7229+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $7401+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $742B+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $7601+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $762D+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $7801+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $782F+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $7A01+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $7A31+OFFSET1,$FFFE   
	DOIRQ2 

	dc.w    $7C01+OFFSET1,$FFFE   
	DOIRQ1 
	dc.w    $7C33+OFFSET1,$FFFE   
	DOIRQ2 

	;
	; Round 2
	;

	dc.w    $8039,$FFFE    ; WAIT
	RULER
	dc.w    $8201,$FFFE 
	dc.w    BPLCON0,$5200 

	dc.w    $8401+OFFSET2,$FFFE 
	DOIRQ1	
	DOIRQ2

	dc.w    $8601+OFFSET2,$FFFE
	DOIRQ1   
	dc.w    $8601+OFFSET2,$FFFE
	DOIRQ2   

	dc.w    $8801+OFFSET2,$FFFE 
	DOIRQ1  
	dc.w    $880F+OFFSET2,$FFFE 
	DOIRQ2 

	dc.w    $8A01+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $8A11+OFFSET2,$FFFE   
	DOIRQ2 

	dc.w    $8C01+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $8C13+OFFSET2,$FFFE   
	DOIRQ2 

	dc.w    $8E01+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $8E15+OFFSET2,$FFFE   
	DOIRQ2 

	dc.w    $9001+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $9017+OFFSET2,$FFFE   
	DOIRQ2 

	dc.w    $9201+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $9219+OFFSET2,$FFFE   
	DOIRQ2 

	dc.w    $9401+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $941B+OFFSET2,$FFFE   
	DOIRQ2 

	dc.w    $9601+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $961D+OFFSET2,$FFFE   
	DOIRQ2 

	dc.w    $9801+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $981F+OFFSET2,$FFFE   
	DOIRQ2 

	dc.w    $9A01+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $9A21+OFFSET2,$FFFE   
	DOIRQ2 
	
	dc.w    $9C01+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $9C23+OFFSET2,$FFFE   
	DOIRQ2 

	dc.w    $9E01+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $9E25+OFFSET2,$FFFE   
	DOIRQ2 

	dc.w    $A001+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $A027+OFFSET2,$FFFE   
	DOIRQ2 

	dc.w    $A201+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $A229+OFFSET2,$FFFE   
	DOIRQ2 

	dc.w    $A401+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $A42B+OFFSET2,$FFFE   
	DOIRQ2 

	dc.w    $A601+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $A62D+OFFSET2,$FFFE   
	DOIRQ2 

	dc.w    $A801+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $A82F+OFFSET2,$FFFE   
	DOIRQ2 

	dc.w    $AA01+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $AA31+OFFSET2,$FFFE   
	DOIRQ2 

	dc.w    $AC01+OFFSET2,$FFFE   
	DOIRQ1 
	dc.w    $AC33+OFFSET2,$FFFE   
	DOIRQ2 

	;
	; Round 3
	;

	dc.w    $B001,$FFFE    ; WAIT
	dc.w    BPLCON0,$0200
	dc.w    $B039,$FFFE    ; WAIT
	RULER
	dc.w    $B201,$FFFE
	dc.w    BPLCON0,$6200 

	dc.w    $B401+OFFSET3,$FFFE 
	DOIRQ1	
	DOIRQ2

	dc.w    $B601+OFFSET3,$FFFE
	DOIRQ1   
	dc.w    $B601+OFFSET3,$FFFE
	DOIRQ2   

	dc.w    $B801+OFFSET3,$FFFE 
	DOIRQ1  
	dc.w    $B80F+OFFSET3,$FFFE 
	DOIRQ2 

	dc.w    $BA01+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $BA11+OFFSET3,$FFFE   
	DOIRQ2 

	dc.w    $BC01+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $BC13+OFFSET3,$FFFE   
	DOIRQ2 

	dc.w    $BE01+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $BE15+OFFSET3,$FFFE   
	DOIRQ2 

	dc.w    $C001+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $C017+OFFSET3,$FFFE   
	DOIRQ2 

	dc.w    $C201+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $C219+OFFSET3,$FFFE   
	DOIRQ2 

	dc.w    $C401+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $C41B+OFFSET3,$FFFE   
	DOIRQ2 

	dc.w    $C601+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $C61D+OFFSET3,$FFFE   
	DOIRQ2 

	dc.w    $C801+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $C81F+OFFSET3,$FFFE   
	DOIRQ2 

	dc.w    $CA01+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $CA21+OFFSET3,$FFFE   
	DOIRQ2 
	
	dc.w    $CC01+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $CC23+OFFSET3,$FFFE   
	DOIRQ2 

	dc.w    $CE01+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $CE25+OFFSET3,$FFFE   
	DOIRQ2 

	dc.w    $D001+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $D027+OFFSET3,$FFFE   
	DOIRQ2 

	dc.w    $D201+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $D229+OFFSET3,$FFFE   
	DOIRQ2 

	dc.w    $D401+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $D42B+OFFSET3,$FFFE   
	DOIRQ2 

	dc.w    $D601+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $D62D+OFFSET3,$FFFE   
	DOIRQ2 

	dc.w    $D801+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $D82F+OFFSET3,$FFFE   
	DOIRQ2 

	dc.w    $DA01+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $DA31+OFFSET3,$FFFE   
	DOIRQ2 

	dc.w    $DC01+OFFSET3,$FFFE   
	DOIRQ1 
	dc.w    $DC33+OFFSET3,$FFFE   
	DOIRQ2 


	dc.w	$ffdf,$fffe    ; Cross vertical boundary
	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
