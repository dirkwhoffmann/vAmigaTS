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
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 6
	
MAIN:	

	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Disable all interrupts
	move.w  #$7FFF,INTENA(a1)

	; Disable all DMA
	move.w  #$7FFF,DMACON(a1)

	; Install interrupt handlers
	lea	    irq4(pc),a2
 	move.l	a2,LVL4_INT_VECTOR

	; Setup audio
	move.l  bitplanes,AUD0LCH(a1)
	move.w  #$00,AUD0VOL(a1)

	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable Copper DMA
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_MASTER),DMACON(a1)

	; Enable interrupts
	move.w  #$C080,INTENA(a1)

;
; Main loop
;

main: 
	jsr     synccpu

   	move.w  #8000,d3
loop1:
	dbra    d3,loop1
   	move.w  #300,d3
	move.w  #$888,d4
	move.w  #$000,d5
loop2:
	move.w  d4,COLOR00(a1)
	move.w  d5,COLOR00(a1)
    dbra    d3,loop2
	bra.s   main

;
; IRQ handlers
;

irq4:
	move.w  #$0080,INTREQ(a1)   ; Acknowledge
	move.w  #$F00,COLOR00(a1)
	move.w  #$FFF,COLOR00(a1)
	move.w  #$0FF,COLOR00(a1)
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
	rts

;
; Copper
;

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

	dc.w    $6039, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $0001
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $6839, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $0001
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $7039, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $0000
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $7839, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $0001
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $8039, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $0002
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $8839, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $0003
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $9039, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $0004
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $9839, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $0005
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $A039, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $0006
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $A839, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $0007
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $B039, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $0008
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $B839, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $0009
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $C039, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $000A
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $C839, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $000B
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $D039, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $000C
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $D839, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $000D
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $E039, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $000E
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $E839, $FFFE
	dc.w    COLOR00,$FF0
	dc.w    AUD0LEN, $000F
	dc.w    AUD0PER, $0000
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.w    $ffdf,$fffe ; Cross vertical boundary

	dc.w    $0039, $FFFE
	dc.w    COLOR00,$00F
	dc.w    AUD0LEN, $0010
	dc.w    AUD0PER, $0001
	dc.w    COLOR00,$F00
	dc.w    AUD0DAT, $0000
	dc.w    COLOR00, $000 

	dc.l	$fffffffe

bitplanes:
	ds.b    61201
	