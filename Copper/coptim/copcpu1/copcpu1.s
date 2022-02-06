	include "../../../../include/registers.i"
	include "../../../include/ministartup.i"

DDFSTRT_INI			equ $60
DDFSTOP_INI			equ $98

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
	move.w	#$C004,INTENA(a1)

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
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #$0F0,COLOR00(a1)
	move.w  #$FF0,COLOR00(a1)
	move.w  #$44F,COLOR00(a1)
	move.w  #$FF0,COLOR00(a1)
	move.w  #$44F,COLOR00(a1)
	move.w  #$FF0,COLOR00(a1)
	move.w  #$44F,COLOR00(a1)
	move.w  #$FF0,COLOR00(a1)
	move.w  #$44F,COLOR00(a1)
	move.w  #$FF0,COLOR00(a1)
	move.w  #$44F,COLOR00(a1)
	move.w  #$F44,COLOR00(a1)
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
	dc.w    COLOR31,$555
	dc.w    BPLCON0,$0200

	;
	; Round 1
	;

	dc.w    $5039,$FFFE    ; WAIT
	RULER
	dc.w    $5201,$FFFE    ; WAIT
	dc.w    BPLCON0,$4200 

	dc.w    $540D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt

	dc.w    $560D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $5661,$FFFE    ; WAIT

	dc.w    $580D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $5861,$FFFE    ; WAIT
	dc.w    $5871,$FFFE    ; WAIT

	dc.w    $5A0D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $5A61,$FFFE    ; WAIT
	dc.w    $5A71,$FFFE    ; WAIT
	dc.w    $5A81,$FFFE    ; WAIT

	dc.w    $5C0D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $5C71,$FFFE    ; WAIT
	dc.w    $5C71,$FFFE    ; WAIT
	dc.w    $5C71,$FFFE    ; WAIT

	dc.w    $5E0D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $5E79,$FFFE    ; WAIT
	dc.w    $5E79,$FFFE    ; WAIT
	dc.w    $5E79,$FFFE    ; WAIT
	dc.w    $5E79,$FFFE    ; WAIT

	dc.w    $600D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $6069,$FFFE    ; WAIT
	dc.w    $6069,$FFFE    ; WAIT
	dc.w    $6079,$FFFE    ; WAIT
	dc.w    $6079,$FFFE    ; WAIT

	;
	; Round 2
	;

	dc.w    $7039,$FFFE    ; WAIT
	RULER
	dc.w    $7201,$FFFE    ; WAIT
	dc.w    BPLCON0,$5200 

	dc.w    $740D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt

	dc.w    $760D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $7661,$FFFE    ; WAIT

	dc.w    $780D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $7861,$FFFE    ; WAIT
	dc.w    $7871,$FFFE    ; WAIT

	dc.w    $7A0D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $7A61,$FFFE    ; WAIT
	dc.w    $7A71,$FFFE    ; WAIT
	dc.w    $7A81,$FFFE    ; WAIT

	dc.w    $7C0D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $7C71,$FFFE    ; WAIT
	dc.w    $7C71,$FFFE    ; WAIT
	dc.w    $7C71,$FFFE    ; WAIT

	dc.w    $7E0D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $7E79,$FFFE    ; WAIT
	dc.w    $7E79,$FFFE    ; WAIT
	dc.w    $7E79,$FFFE    ; WAIT
	dc.w    $7E79,$FFFE    ; WAIT

	dc.w    $800D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $8069,$FFFE    ; WAIT
	dc.w    $8069,$FFFE    ; WAIT
	dc.w    $8079,$FFFE    ; WAIT
	dc.w    $8079,$FFFE    ; WAIT

	;
	; Round 3
	;

	dc.w    $9039,$FFFE    ; WAIT
	RULER
	dc.w    $9201,$FFFE    ; WAIT
	dc.w    BPLCON0,$6200 

	dc.w    $940D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt

	dc.w    $960D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $9661,$FFFE    ; WAIT

	dc.w    $980D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $9861,$FFFE    ; WAIT
	dc.w    $9871,$FFFE    ; WAIT

	dc.w    $9A0D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $9A61,$FFFE    ; WAIT
	dc.w    $9A71,$FFFE    ; WAIT
	dc.w    $9A81,$FFFE    ; WAIT

	dc.w    $9C0D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $9C71,$FFFE    ; WAIT
	dc.w    $9C71,$FFFE    ; WAIT
	dc.w    $9C71,$FFFE    ; WAIT

	dc.w    $9E0D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $9E79,$FFFE    ; WAIT
	dc.w    $9E79,$FFFE    ; WAIT
	dc.w    $9E79,$FFFE    ; WAIT
	dc.w    $9E79,$FFFE    ; WAIT

	dc.w    $A00D,$FFFE    ; WAIT
	dc.w    INTREQ,$8004   ; Level 1 interrupt
	dc.w    $A069,$FFFE    ; WAIT
	dc.w    $A069,$FFFE    ; WAIT
	dc.w    $A079,$FFFE    ; WAIT
	dc.w    $A079,$FFFE    ; WAIT


	dc.w	$ffdf,$fffe    ; Cross vertical boundary
	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
