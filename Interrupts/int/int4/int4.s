	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
CIAAPRA             equ $BFE001	
CIABPRB             equ $BFD100	
LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c
LVL4_INT_VECTOR		equ $70
LVL5_INT_VECTOR		equ $74
LVL6_INT_VECTOR		equ $78
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ 5
	
;
; Main
;

entry:	
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
	lea	    irq1(pc),a2
 	move.l  a2,LVL1_INT_VECTOR
	lea	    irq2(pc),a2
 	move.l  a2,LVL2_INT_VECTOR
	lea	    irq3(pc),a2
 	move.l  a2,LVL3_INT_VECTOR
	lea	    irq4(pc),a2
 	move.l	a2,LVL4_INT_VECTOR
	lea	    irq5(pc),a2
 	move.l	a2,LVL5_INT_VECTOR
	lea	    irq6(pc),a2
 	move.l	a2,LVL6_INT_VECTOR

  	; Setup bitplane pointers
	lea     bitplanes(pc),a2
	lea     copper(pc),a3
	moveq	#4,d0
.bitplaneloop:
	move.l 	a2,d1
	move.w	d1,2(a3)
	swap	d1
	move.w  d1,6(a3)
	addq	#8,a3
	dbra	d0,.bitplaneloop

	; Install copper list
	lea	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable Copper DMA
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_MASTER),DMACON(a1)

	; Enable interrupts
	move.w  #$C000,INTENA(a1)

;
; Main loop
;

main: 
	jsr     synccpu

   	move.w  #80,d3
loop1:
	ds.w    42,$4E71          ; NOPs
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

irq1:
	move.w  #$0004,INTREQ(a1)   ; Acknowledge
	lea     COLOR02(a1),a7      ; Redirect stack pointer to color registers
	move.w  #$F00,COLOR00(a1)
	move.w  #$FFF,COLOR00(a1)
	move.w  #$F00,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	move    #$F,SR              ; Restore SR manually  
	bra 	loop1               ; Exit IRQ handler manually
	;rte

irq2:
	move.w  #$0008,INTREQ(a1)   ; Acknowledge
	lea     COLOR03(a1),a7      ; Redirect stack pointer to color registers
	move.w  #$0F0,COLOR00(a1)
	move.w  #$FFF,COLOR00(a1)
	move.w  #$0F0,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	move    #$F,SR              ; Restore SR manually  
	bra 	loop1               ; Exit IRQ handler manually
	rte

irq3:
	move.w  #$0010,INTREQ(a1)   ; Acknowledge
	lea     COLOR01(a1),a7      ; Redirect stack pointer to color registers
	move.w  #$0F0,COLOR00(a1)
	move.w  #$FFF,COLOR00(a1)
	move.w  #$00F,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	move    #$F,SR              ; Restore SR manually  
	bra 	loop1               ; Exit IRQ handler manually
	;rte

irq4:
	move.w  #$0080,INTREQ(a1)   ; Acknowledge
	lea     COLOR01(a1),a7      ; Redirect stack pointer to color registers
	move.w  #$F00,COLOR00(a1)
	move.w  #$FFF,COLOR00(a1)
	move.w  #$0FF,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	move    #$F,SR              ; Restore SR manually  
	bra 	loop1               ; Exit IRQ handler manually
	; rte

irq5:
	move.w  #$0800,INTREQ(a1)   ; Acknowledge
	lea     COLOR01(a1),a7      ; Redirect stack pointer to color registers
	move.w  #$FFF,COLOR00(a1)
	move.w  #$0F0,COLOR00(a1)
	move.w  #$FFF,COLOR00(a1)
	move.w  #$000,COLOR00(a1)
	move    #$F,SR              ; Restore SR manually  
	bra 	loop1               ; Exit IRQ handler manually
	; rte

irq6:
	move.w  #$2000,INTREQ(a1)   ; Acknowledge
	move.w  #$FFF,COLOR00(a1)
	move.w  #$00F,COLOR00(a1)
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

	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPL1MOD,$0 
	dc.w	BPL2MOD,$0
	dc.w	BPLCON0,(0<<12)|$200 ; Disable all bitplanes

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
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $6439, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $6839, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $6C39, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $7039, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $7439, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$0080         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $7839, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $7C39, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $8039, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $8439, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $8839, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $8C39, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $9039, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $9439, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $9839, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000
	
	dc.w    $9C39, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $A039, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w    $A439, $FFFE         ; Wait
	dc.w    COLOR00,$AAA
	dc.w	INTENA,$8880         ; Enable level 4 and level 5 interrupts
	dc.w 	INTREQ,$8080         ; Issue level 4 interrupt
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w    $01FE, $FFFE         ; NOP
	dc.w 	INTREQ,$8800         ; Issue level 5 interrupt
	dc.w 	INTREQ,$0880         ; Acknowledge
	dc.w	INTENA,$0880         ; Disable interrupts
	dc.w    COLOR00,$000

	dc.w	$ffdf,$fffe          ; Cross vertical boundary

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
	