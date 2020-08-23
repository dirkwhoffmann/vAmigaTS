	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"

	include "ministartup.s"

LVL3_INT_VECTOR		equ $6c
	
MAIN:	
	; Load OCS base address
	lea CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Install interrupt handlers
	lea	    irq3(pc),a2
 	move.l	a2,LVL3_INT_VECTOR

	; Install copper list
	lea    	copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d2

	; Enable DMA
	move.w  #$8080,DMACON(a1)   ; Copper
	move.w  #$8200,DMACON(a1)   ; EN

	; Enable innterrupts
	move.w	#$8020,INTENA(a1)   ; VBLANK
	move.w	#$C000,INTENA(a1)   ; EN

    ;
	; Scan for Kickstart mirrors 
	; 

	lea     $F80000,a6          ; Real kickstart

	; Scan memory
	lea     $C00000,a3
	jsr     search
	lea     $C40000,a3
	jsr     search
	lea     $C80000,a3
	jsr     search
	lea     $CC0000,a3
	jsr     search
	lea     $D00000,a3
	jsr     search
	lea     $D40000,a3
	jsr     search
	lea     $D80000,a3
	jsr     search
	lea     $DC0000,a3
	jsr     search

	move.l  d0,d1 

	lea     $E00000,a3
	jsr     search
	lea     $E40000,a3
	jsr     search
	lea     $E80000,a3
	jsr     search
	lea     $EC0000,a3
	jsr     search
	lea     $F00000,a3
	jsr     search
	lea     $F40000,a3
	jsr     search
	lea     $F80000,a3
	jsr     search
	lea     $FC0000,a3
	jsr     search

.mainLoop:
	bra.b	.mainLoop

search:
    lsl     #1,d0
	move.l  a6,a2
	moveq   #15,d2
.loop:
    cmp.l   (a2)+,(a3)+
	bne     .done
	dbra    d2,.loop
	or.w    #1,d0
.done: 
	rts


irq3:
	move.w  #$0020,INTREQ(a1)   ; Acknowledge
	
; 
; Visualize d0
; 

.test0:
	lea	(bit0+2)(pc),a0
	move.w #$333,(a0)
	btst #0,d0
	beq.s .test1
	move.w #$CCC,(a0)

.test1:
	lea	(bit1+2)(pc),a0
	move.w #$333,(a0)
	btst #1,d0
	beq.s .test2
	move.w #$CCC,(a0)

.test2:
	lea	(bit2+2)(pc),a0
	move.w #$333,(a0)
	btst #2,d0
	beq.s .test3
	move.w #$CCC,(a0)

.test3:
	lea	(bit3+2)(pc),a0
	move.w #$333,(a0)
	btst #3,d0
	beq.s .test4
	move.w #$CCC,(a0)

.test4:
	lea	(bit4+2)(pc),a0
	move.w #$333,(a0)
	btst #4,d0
	beq.s .test5
	move.w #$CCC,(a0)

.test5:
	lea	(bit5+2)(pc),a0
	move.w #$333,(a0)
	btst #5,d0
	beq.s .test6
	move.w #$CCC,(a0)

.test6:
	lea	(bit6+2)(pc),a0
	move.w #$333,(a0)
	btst #6,d0
	beq.s .test7
	move.w #$CCC,(a0)

.test7:
	lea	(bit7+2)(pc),a0
	move.w #$333,(a0)
	btst #7,d0
	beq.s .test8
	move.w #$CCC,(a0)

; 
; Visualize d1
; 

.test8:
	lea	(bit8+2)(pc),a0
	move.w #$333,(a0)
	btst #0,d1
	beq.s .test9
	move.w #$CCC,(a0)

.test9:
	lea	(bit9+2)(pc),a0
	move.w #$333,(a0)
	btst #1,d1
	beq.s .test10
	move.w #$CCC,(a0)

.test10:
	lea	(bit10+2)(pc),a0
	move.w #$333,(a0)
	btst #2,d1
	beq.s .test11
	move.w #$CCC,(a0)

.test11:
	lea	(bit11+2)(pc),a0
	move.w #$333,(a0)
	btst #3,d1
	beq.s .test12
	move.w #$CCC,(a0)

.test12:
	lea	(bit12+2)(pc),a0
	move.w #$333,(a0)
	btst #4,d1
	beq.s .test13
	move.w #$CCC,(a0)

.test13:
	lea	(bit13+2)(pc),a0
	move.w #$333,(a0)
	btst #5,d1
	beq.s .test14
	move.w #$CCC,(a0)

.test14:
	lea	(bit14+2)(pc),a0
	move.w #$333,(a0)
	btst #6,d1
	beq.s .test15
	move.w #$CCC,(a0)

.test15:
	lea	(bit15+2)(pc),a0
	move.w #$333,(a0)
	btst #7,d1
	beq.s .interruptComplete
	move.w #$CCC,(a0)

.interruptComplete:
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
	dc.w	COLOR00, $000

	dc.w	$8001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$80D9,$FFFE  ; WAIT 
bit7:
	dc.w	COLOR00, $000

	dc.w	$8801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$88D9,$FFFE  ; WAIT 
bit6:
	dc.w	COLOR00, $000

	dc.w	$9001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$90D9,$FFFE  ; WAIT 
bit5:
	dc.w	COLOR00, $000

	dc.w	$9801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$98D9,$FFFE  ; WAIT 
bit4:
	dc.w	COLOR00, $000

	dc.w	$A001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A0D9,$FFFE  ; WAIT 
bit3:
	dc.w	COLOR00, $000

	dc.w	$A801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$A8D9,$FFFE  ; WAIT 
bit2:
	dc.w	COLOR00, $000

	dc.w	$B001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$B0D9,$FFFE  ; WAIT 
bit1:
	dc.w	COLOR00, $000

	dc.w	$B801,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$B8D9,$FFFE  ; WAIT 
bit0:
	dc.w	COLOR00, $000

	dc.w	$C001,$FFFE  ; WAIT 
	dc.w	COLOR00, $F00
	dc.w	$C0D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.l	$fffffffe

	