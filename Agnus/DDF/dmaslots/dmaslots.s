	include "../../../../include/registers.i"
	include "../../../include/ministartup.i"
	
LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78

BASE                equ $38

MAIN:	
	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00 
	move.b  #$7F,$BFED01

	; Setup bitplane pointers
	lea     bitplanes(pc),a2
	lea     copper(pc),a3
	moveq	#5,d0
.bitplaneloop:
	move.l 	a2,d1
	move.w	d1,2(a3)
	swap	d1
	move.w  d1,6(a3)
	addq	#8,a3
	dbra	d0,.bitplaneloop

	; Set up playfield
	move.w  #$2C81,DIWSTRT(a1)
	move.w	#$572C,DIWSTOP(a1)
	move.w	#$0,BPL1MOD(a1)
	move.w	#$0,BPL2MOD(a1)

	; Install interrupt handlers
	lea	    irq1(pc),a3 
 	move.l	a3,LVL1_INT_VECTOR
	lea	    irq2(pc),a3 
 	move.l	a3,LVL2_INT_VECTOR

	; Setup Copper
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #$8003,COPCON(a1)   ; Allow Copper to write Blitter registers

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 

	; Enable interrupts
	move.w	#$C00C,INTENA(a1)

.mainLoop:

	jsr     synccpu
	bra.s	.mainLoop

synccpu:
	lea     VHPOSR(a1),a3     ; VHPOSR     

	; Wait until we have reached a certain scanline
.loop 
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$2000,d2
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
  	moveq   #10,d2
.adjust:
    dbra    d2,.adjust

	; Sync vertically
.synccpu4:
	nop 
	move.w  #$404,COLOR00(a1)
	ds.w    96,$4E71          ; NOPs to keep the horizontal position in each iteration
	move.w  (a3),d2     
	move.w  #$F0F,COLOR00(a1)  
	and     #$FF00,d2
	cmp.w   #$3000,d2
	bne     .synccpu4
	move.w  #$000,COLOR00(a1)
	rts

irq1:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #$F00,COLOR00(a1)
	move.w  #$FF0,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	rte

irq2:
	move.w  #$3FFF,INTREQ(a1) ; Acknowledge	
	move.w  #$0F0,COLOR00(a1)
	move.w  #$0FF,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	rte

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

	dc.w    DDFSTRT,$38
	dc.w    DDFSTOP,$D0
	dc.w    BPLCON0, (0<<12)|$200

    ; 
	; LORES
	;

	dc.w	$4041,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON0, (6<<12)|$200
	dc.w    DDFSTRT,$38
	dc.w	DDFSTOP,$B0
	dc.w	$40B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4451,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000
	dc.w	$4553,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000

	dc.w	$4841,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$3A
	dc.w	DDFSTOP,$B2
	dc.w	$48B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$4C51,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000
	dc.w	$4D53,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000

	dc.w	$5041,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$3C
	dc.w	DDFSTOP,$B4
	dc.w	$50B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$5451,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000
	dc.w	$5553,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000

	dc.w	$5841,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$3E
	dc.w	DDFSTOP,$B6
	dc.w	$58B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$5C51,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000
	dc.w	$5D53,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000

	dc.w	$6041,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$40
	dc.w	DDFSTOP,$B8
	dc.w	$60B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$6451,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000
	dc.w	$6553,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000

	dc.w	$6841,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$42
	dc.w	DDFSTOP,$BA
	dc.w	$68B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$6C51,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000
	dc.w	$6D53,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000

	dc.w	$7041,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$44
	dc.w	DDFSTOP,$BC
	dc.w	$70B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$7451,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000
	dc.w	$7553,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000

	dc.w	$7841,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$46
	dc.w	DDFSTOP,$BE
	dc.w	$78B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$7C51,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000
	dc.w	$7D53,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000

	dc.w	$8041,$FFFE  ; WAIT 
	dc.w	COLOR00, $08F
	dc.w    BPLCON0, (0<<12)|$200
	dc.w    DDFSTRT,$38
	dc.w	DDFSTOP,$D0
	dc.w	$80B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $9039, $FFFE         ; WAIT
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$000
	dc.w    COLOR00,$F00
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$000
	dc.w    COLOR00,$FF0
	dc.w    COLOR00,$000
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$00F
	dc.w    COLOR00,$000
	dc.w    COLOR00,$00F
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

     ; 
	; HIRES
	;

	dc.w	$A041,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    BPLCON0, (3<<12)|$8200
	dc.w    DDFSTRT,$38
	dc.w	DDFSTOP,$B0
	dc.w	$A0B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$A451,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000
	dc.w	$A553,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000

	dc.w	$A841,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$3A
	dc.w	DDFSTOP,$B2
	dc.w	$A8B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$AC51,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000
	dc.w	$AD53,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000

	dc.w	$B041,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$3C
	dc.w	DDFSTOP,$B4
	dc.w	$B0B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$B451,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000
	dc.w	$B553,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000

	dc.w	$B841,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$3E
	dc.w	DDFSTOP,$B6
	dc.w	$B8B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$BC51,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000
	dc.w	$BD53,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000

	dc.w	$C041,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$40
	dc.w	DDFSTOP,$B8
	dc.w	$C0B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$C451,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000
	dc.w	$C553,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000

	dc.w	$C841,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$42
	dc.w	DDFSTOP,$BA
	dc.w	$C8B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$CC51,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000
	dc.w	$CD53,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000

	dc.w	$D041,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w    DDFSTRT,$44
	dc.w	DDFSTOP,$BC
	dc.w	$D0B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$D451,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000
	dc.w	$D553,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000

	dc.w	$D841,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00 
	dc.w    DDFSTRT,$46
	dc.w	DDFSTOP,$BE
	dc.w	$D8B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$DC51,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000
	dc.w	$DD53,$FFFE  ; WAIT 
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $00F
	dc.w	COLOR00, $FF0
	dc.w	COLOR00, $000

	dc.w	$E041,$FFFE  ; WAIT 
	dc.w	COLOR00, $08F
	dc.w    BPLCON0, (0<<12)|$8200
	dc.w    DDFSTRT,$38
	dc.w	DDFSTOP,$D0
	dc.w	$E0B9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$FFDF,$FFFE  ; Cross vertical boundary

	dc.w	BPLCON0,(0<<12)|$200 ; Bitplane DMA off
	dc.w    DDFSTRT,$0038 ; Reset normal values
	dc.w	DDFSTOP,$00D0

	dc.l	$fffffffe

bitplanes:
	ds.b    32768,$00
	