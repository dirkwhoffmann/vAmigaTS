LVL3_INT_VECTOR		equ $6c
	
init:

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
	rts

;
; Prepares the Copper list (see copperlist.s)
; to display the values of d0 and d1.
;

coppersetup:

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
	beq.s .exit
	move.w #$CCC,(a0)

.exit
    rts

