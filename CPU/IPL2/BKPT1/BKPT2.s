PAYLOAD	MACRO
        bkpt    #1
        ENDM

TSTCODE MACRO
		move.w  #0,SERPER(a1)
		TESTRUN $4000,$3

		move.w  #1,SERPER(a1)
		TESTRUN $6000,$3

		move.w  #1,SERPER(a1)
		TESTRUN $8000,$3

		move.w  #1,SERPER(a1)
		TESTRUN $A000,$F

		move.w  #1,SERPER(a1)
		TESTRUN $C000,$3F
		ENDM

	include "../../../include/registers.i"
	include "../../../include/ministartup.i"

RUN		MACRO
        move.w  #\1,d0
		jsr     waitline
		move.w  #\2,d0
		jsr     runUart
        ENDM

TESTRUN MACRO
		RUN 	\1+$0200,\2
		RUN 	\1+$0400,(\2<<1|1)
		RUN 	\1+$0600,(\2<<2|1)
		RUN 	\1+$0800,(\2<<3|1)
		RUN 	\1+$0A00,(\2<<4|1)
		RUN 	\1+$0C00,(\2<<5|1)
		RUN 	\1+$0E00,(\2<<6|1)
		RUN 	\1+$1000,(\2<<7|1)
		RUN 	\1+$1200,(\2<<8|1)
		RUN 	\1+$1400,(\2<<9|1)
		RUN 	\1+$1600,(\2<<10|1)
		ENDM

DDFSTRT_INI			equ $48
DDFSTOP_INI			equ $A8

ILL_EXC_VECTOR		equ $10
LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78

MAIN:
	; Load OCS base address
	lea     CUSTOM,a1
	lea     CUSTOM,a6

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Install interrupt handlers
	lea	    illex(pc),a3
 	move.l	a3,ILL_EXC_VECTOR
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

	; Setup Copper
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #$8003,COPCON(a1)   ; Allow Copper to write Blitter registers

	; Enable DMA
	move.w	#$8040,DMACON(a1)   ; Blitter DMA 	
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 

	; Enable interrupts
	move.w	#$C001,INTENA(a1)
	moveq   #0,d0

.mainLoop:
	jsr     synccpu

	; Preload some values
	move.w  #$3FFF,d1
	move.w  #$8001,d2
	move.w  #$F88,d3
	move.w  #$88F,d4
	move.l  #$80013FFF,d5
	lea     SERPER(a1),a2
	lea 	SERDAT(a1),a3
	lea 	INTREQ(a1),a4
	lea 	INTENA(a1),a5

	; Run the test script
	TSTCODE

	bra  	.mainLoop

runUart:
	move 	#$444,COLOR00(a1)
	move.w  #$0001,INTENA(a1)	; (1) Disable TBE interrupt
	move.w  d0,(a3)				; (3) Load shift register
	;move.w  d1,(a4)   			; (4) Ignore the first TBE interrupt
	;move.w  d2,(a5)			; (5) Enable TBE interrupt
	move.l  d5,(a5)				; (4) + (5) in one chunk
	move.w  d0,(a3)				; (6) Load shift register again

	; Instruction under test
	PAYLOAD

	move 	d3,COLOR00(a1)
	move 	d4,COLOR00(a1)
	move 	d3,COLOR00(a1)
	move 	d4,COLOR00(a1)
	move 	#$000,COLOR00(a1)
	rts

illex:
    move.w  #$FFF,COLOR00(a1)
	add.w   #2,$4(a7)          ; Saved PC += 2
    ; move.w  #$000,COLOR00(a1)
	rte

irq1:
    move.w  #$FF0,COLOR00(a1)
	move.w  #$3FFF,INTREQ(a1)  ; Acknowledge	
	rte

waitline:
	lea     VHPOSR(a1),a6     ; VHPOSR     

	; Wait until we have reached the scanline given in d0
.loop 
	move.w  (a6),d2     
	and     #$FF00,d2
	cmp.w   d0,d2
	bne     .loop
	and     #1,VPOSR(a1)
	bne     .loop
	ds.w    6,$4E71		; Some NOPs
	rts
	
synccpu:
	lea     VHPOSR(a1),a3     ; VHPOSR     

	; Wait until we have reached a certain scanline
.loop 
	move.w  (a3),d6     
	and     #$FF00,d6
	cmp.w   #$2000,d6
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
    ; Section 1
	;

  	dc.w    $4039, $FFFE
	include "../copperline.i"
	dc.w    BPLCON0, (0<<12)|$200

    ;
    ; Section 2
	;

  	dc.w    $6039, $FFFE
	include "../copperline.i"
	dc.w    BPLCON0, (0<<12)|$200

    ;
    ; Section 3
	;

  	dc.w    $8039, $FFFE
	include "../copperline.i"
	dc.w    BPLCON0, (4<<12)|$200

    ;
    ; Section 4
	;

  	dc.w    $A039, $FFFE
	include "../copperline.i"
	dc.w    BPLCON0, (5<<12)|$200

    ;
    ; Section 5
	;

  	dc.w    $C039, $FFFE
	include "../copperline.i"
	dc.w    BPLCON0, (6<<12)|$200

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 
	dc.w    BPLCON0, (0<<12)|$200

	dc.l    $fffffffe

bitplanes:
	ds.b 	61440,$00

