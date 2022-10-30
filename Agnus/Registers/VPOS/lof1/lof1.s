	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

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
	lea CUSTOM,a1

	; Disable interrupts and DMA
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)

	; Disable all bitplanes 
	move.w  #$200,BPLCON0(a1)

	; Install interrupt handlers
	lea	irq1(pc),a3
 	move.l	a3,LVL1_INT_VECTOR
	lea	    irq3(pc),a2
 	move.l	a2,LVL3_INT_VECTOR

	; Install copper list
	lea    	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8200,DMACON(a1)   ; DMAEN 

	; Enable Interrupts
	move.w 	#$8004,INTENA(a1)   ; Level 1
	;move.w 	#$8008,INTENA(a1)   ; Level 2
	move.w 	#$8020,INTENA(a1)   ; Level 3 (VERTB)
	;move.w 	#$8080,INTENA(a1)   ; Level 4
	;move.w 	#$8800,INTENA(a1)   ; Level 5
	;move.w 	#$A000,INTENA(a1)   ; Level 6
	move.w 	#$C000,INTENA(a1)   ; INTEN
	
.mainLoop:
	bra.b	.mainLoop
	
irq1: 
	move.w  #$3FFF,INTREQ(a1)   ; Acknowledge
    move.w  #$8001,VPOSW(a1)	; Make long frames

    moveq   #0,d1
.loop: 
	move.l  d1,d0
	move.b  VHPOSR(a1),d1
	cmp     d0,d1
	bge     .loop

	; At this point, the number of the last rasterline is in d0
	; Disable level 1 IRQ (we only want to process it once)
	move.w 	#$0004,INTENA(a1)
	rte

irq3:
	movem.l	d0-a6,-(sp)
	move.w  #$0020,INTREQ(a1)   ; Acknowledge

	; Visualize d0
	move.w #$CCC,d5
.test0:
	lea	(bit0+2)(pc),a0
	move.w #$333,(a0)
	btst #0,d0
	beq.s .test1
	move.w d5,(a0)

.test1:
	lea	(bit1+2)(pc),a0
	move.w #$333,(a0)
	btst #1,d0
	beq.s .test2
	move.w d5,(a0)

.test2:
	lea	(bit2+2)(pc),a0
	move.w #$333,(a0)
	btst #2,d0
	beq.s .test3
	move.w d5,(a0)

.test3:
	lea	(bit3+2)(pc),a0
	move.w #$333,(a0)
	btst #3,d0
	beq.s .test4
	move.w d5,(a0)

.test4:
	lea	(bit4+2)(pc),a0
	move.w #$333,(a0)
	btst #4,d0
	beq.s .test5
	move.w d5,(a0)

.test5:
	lea	(bit5+2)(pc),a0
	move.w #$333,(a0)
	btst #5,d0
	beq.s .test6
	move.w d5,(a0)

.test6:
	lea	(bit6+2)(pc),a0
	move.w #$333,(a0)
	btst #6,d0
	beq.s .test7
	move.w d5,(a0)

.test7:
	lea	(bit7+2)(pc),a0
	move.w #$333,(a0)
	btst #7,d0
	beq.s .test8
	move.w d5,(a0)

.test8:
	lea	(bit8+2)(pc),a0
	move.w #$333,(a0)
	btst #8,d0
	beq.s .test9
	move.w d5,(a0)

.test9:
	lea	(bit9+2)(pc),a0
	move.w #$333,(a0)
	btst #9,d0
	beq.s .test10
	move.w d5,(a0)

.test10:
	lea	(bit10+2)(pc),a0
	move.w #$333,(a0)
	btst #10,d0
	beq.s .test11
	move.w d5,(a0)

.test11:
	lea	(bit11+2)(pc),a0
	move.w #$333,(a0)
	btst #11,d0
	beq.s .test12
	move.w d5,(a0)

.test12:
	lea	(bit12+2)(pc),a0
	move.w #$333,(a0)
	btst #12,d0
	beq.s .test13
	move.w d5,(a0)

.test13:
	lea	(bit13+2)(pc),a0
	move.w #$333,(a0)
	btst #13,d0
	beq.s .test14
	move.w d5,(a0)

.test14:
	lea	(bit14+2)(pc),a0
	move.w #$333,(a0)
	btst #14,d0
	beq.s .test15
	move.w d5,(a0)

.test15:
	lea	(bit15+2)(pc),a0
	move.w #$333,(a0)
	btst #15,d0
	beq.s .interruptComplete
	move.w d5,(a0)

.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte

copper:	
	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$30D9,$FFFE  ; WAIT 
bit15:
	dc.w	COLOR00, $000

	dc.w	$3801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$38D9,$FFFE  ; WAIT 
bit14:
	dc.w	COLOR00, $000

	dc.w	$4001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$40D9,$FFFE  ; WAIT 
bit13:
	dc.w	COLOR00, $000

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$48D9,$FFFE  ; WAIT 
bit12:
	dc.w	COLOR00, $000

	dc.w	$5001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$50D9,$FFFE  ; WAIT 
bit11:
	dc.w	COLOR00, $000

	dc.w	$5801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$58D9,$FFFE  ; WAIT 
bit10:
	dc.w	COLOR00, $000

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$60D9,$FFFE  ; WAIT 
bit9:
	dc.w	COLOR00, $000

	dc.w	$6801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$68D9,$FFFE  ; WAIT 
bit8:
	dc.w	COLOR00, $000

	dc.w	$7001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$70D9,$FFFE  ; WAIT 
bit7:
	dc.w	COLOR00, $000

	dc.w	$7801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$78D9,$FFFE  ; WAIT 
bit6:
	dc.w	COLOR00, $000

	dc.w	$8001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$80D9,$FFFE  ; WAIT 
bit5:
	dc.w	COLOR00, $000

	dc.w	$8801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$88D9,$FFFE  ; WAIT 
bit4:
	dc.w	COLOR00, $000

	dc.w	$9001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$90D9,$FFFE  ; WAIT 
bit3:
	dc.w	COLOR00, $000

	dc.w	$9801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$98D9,$FFFE  ; WAIT 
bit2:
	dc.w	COLOR00, $000

	dc.w	$A001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A0D9,$FFFE  ; WAIT 
bit1:
	dc.w	COLOR00, $000

	dc.w	$A801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A8D9,$FFFE  ; WAIT 
bit0:
	dc.w	COLOR00, $000

	dc.w	$B001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$B0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w	$ffdf,$fffe          ; Cross vertical boundary
	dc.w    $0201,$FFFE

	dc.w 	INTREQ,$8004         ; Run the test (level 1 interrupt handler)

	dc.l	$fffffffe