	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

PRIV_VECTOR         equ $20
TRACE_VECTOR        equ $24

LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR	    equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78
	
MAIN:	
	; Load OCS base address
	lea CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Install interrupt handlers
	lea	    irq1(pc),a2
 	move.l	a2,LVL1_INT_VECTOR
	lea	    irq3(pc),a2
 	move.l	a2,LVL3_INT_VECTOR

 	; Install exception handlers
	lea	    trace(pc),a3
 	move.l	a3,TRACE_VECTOR
	lea	    priv(pc),a3
 	move.l	a3,PRIV_VECTOR

	; Install copper list
	lea    	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d2

	; Enable DMA
	move.w  #$8080,DMACON(a1)   ; Copper
	move.w  #$8200,DMACON(a1)   ; EN

	; Enable innterrupts
	move.w	#$8004,INTENA(a1)   ; Soft
	move.w	#$8020,INTENA(a1)   ; VBLANK
	move.w	#$C000,INTENA(a1)   ; EN

.mainLoop:
	jsr     synccpu
	bra     .mainLoop

trace:
	move.w  #$F00,COLOR00(a1) 
	andi    #$7FFF,SR          ; Clear Trace bit
	move.w  #$000,COLOR00(a1) 
	rte

priv: 
	move.w  #$FF0,COLOR00(a1) 
	move.w  #$000,COLOR00(a1) 
	rte

irq3:
	move.w  #$0020,INTREQ(a1)   ; Acknowledge	
	rte

irq1:
	move.w  #$0004,INTREQ(a1)   ; Acknowledge	
	move.w  #$0F0,COLOR00(a1)
	andi    #$7FFF,SR          ; Clear Trace bit
	stop    #$2000
	move.w  #$FFF,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	rte

synccpu:
	lea     VHPOSR(a1),a3       ; VHPOSR     

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

	dc.w	BPLCON0,(0<<12)|$200
	dc.w    COLOR00,$000

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

	dc.w    $6039,$FFFE
	dc.w    COLOR00,$888
	dc.w    INTREQ,$8004 

	dc.w    $7039,$FFFE
	dc.w    COLOR00,$888
	dc.w    INTREQ,$8020 

	dc.l	$fffffffe

	