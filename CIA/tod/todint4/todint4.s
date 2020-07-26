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

CIAA_PRA            equ $BFE001	
CIAA_PRB            equ $BFE101
CIAA_DDRA           equ $BFE201
CIAA_DDRB           equ $BFE301
CIAA_TALO           equ $BFE401
CIAA_TAHI           equ $BFE501
CIAA_TBLO           equ $BFE601
CIAA_TBHI           equ $BFE701
CIAA_TODLO          equ $BFE801
CIAA_TODMID         equ $BFE901
CIAA_TODHI          equ $BFEA01
CIAA_SDR            equ $BFEC01
CIAA_ICR            equ $BFED01
CIAA_CRA            equ $BFEE01
CIAA_CRB            equ $BFEF01

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

MAIN:	

	; Load OCS base address into a1
	lea CUSTOM,a1

	; Disable all bitplanes 
	move.w #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Disable DMA and interrupts
	move.w  #$7FFF,DMACON(a1)
	move.w  #$7FFF,INTENA(a1)

	; Install interrupt handlers
	lea	    irq1(pc),a3 
 	move.l	a3,LVL1_INT_VECTOR
	lea	    irq3(pc),a3 
 	move.l	a3,LVL3_INT_VECTOR
	lea	    irq4(pc),a3 
 	move.l	a3,LVL4_INT_VECTOR
	lea	    irq5(pc),a3
 	move.l	a3,LVL5_INT_VECTOR
	lea	    irq6(pc),a3 
 	move.l	a3,LVL6_INT_VECTOR

	; Configure CIAs
	move.b  #$84,CIAB_ICR        ; Enable TOD interrupts

	; Counters
	moveq   #0,d3               ; Passes
	moveq   #0,d4               ; Alarms 

	; Enable Interrupts
	move.w	#$8004,INTENA(a1)   ; SOFT (1)
	move.w	#$8020,INTENA(a1)   ; VERTB (3)
	move.w	#$8080,INTENA(a1)   ; AUD0 (4)
	move.w	#$8800,INTENA(a1)   ; RBF (5)
	move.w	#$A000,INTENA(a1)   ; CIA B (6)
	move.w	#$C000,INTENA(a1)   ; Enable

	; Setup Copper
	lea	copper(pc),a0           ; Get pointer to Copper list
	move.l	a0,COP1LC(a1)       ; Write pointer to Copper location register 1
 	move.w  COPJMP1(a1),d0      ; Jump to the first Copper list

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA
	move.w	#$8200,DMACON(a1)   ; DMA enable

    moveq    #0,d5              ; d5 contains the visualized value
.mainLoop:
	jsr     synccpu
	bra.s   .mainLoop

irq1: 
	move.w	#$0004,INTREQ(a1)	        ; Acknowledge
	move.w  #$FFF,COLOR00(a1)

	move.b  #$88,CIAB_TODMID            ; Remove matching condition

	move.b  #$80,CIAB_CRB               ; Set alarm
	move.b  #$CC,CIAB_TODMID
	move.b  #$00,CIAB_TODHI             
	move.b  #$00,CIAB_TODLO
 
	move.b  #$00,CIAB_CRB               ; Set counter
	move.b  #$88,CIAB_TODMID
	move.b  #$00,CIAB_TODHI        
	move.b  #$00,CIAB_TODLO

	move.b  #$CC,CIAB_TODMID            ; Let the counter match the alarm

    ; Test objective: Does the TOD interrupt trigger here?
	rte

irq6: 
	move.b  CIAB_ICR,d0
	move.w	#$2000,INTREQ(a1)	        ; Acknowledge
	move.b  CIAB_ICR,d0                 ; Acknowledge (CIA)
	move.w  #$00F,COLOR00(a1)
	addq    #1,d4
	rte

irq3:
	move.w	#$0020,INTREQ(a1)	        ; Acknowledge

	; Visualize passes and alarms
	move.l  d3,d0                       
	asl     #8,d0 
	move.b  d4,d0
	
	addq    #1,d3

.test0:
	lea	bit0(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #0,d0
	beq.s .test1
	move.w #$CCC,(a0)

.test1:
	lea	bit1(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #1,d0
	beq.s .test2
	move.w #$CCC,(a0)

.test2:
	lea	bit2(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #2,d0
	beq.s .test3
	move.w #$CCC,(a0)

.test3:
	lea	bit3(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #3,d0
	beq.s .test4
	move.w #$CCC,(a0)

.test4:
	lea	bit4(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #4,d0
	beq.s .test5
	move.w #$CCC,(a0)

.test5:
	lea	bit5(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #5,d0
	beq.s .test6
	move.w #$CCC,(a0)

.test6:
	lea	bit6(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #6,d0
	beq.s .test7
	move.w #$CCC,(a0)

.test7:
	lea	bit7(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #7,d0
	beq.s .test8
	move.w #$CCC,(a0)

.test8:
	lea	bit8(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #8,d0
	beq.s .test9
	move.w #$CCC,(a0)

.test9:
	lea	bit9(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #9,d0
	beq.s .test10
	move.w #$CCC,(a0)

.test10:
	lea	bit10(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #10,d0
	beq.s .test11
	move.w #$CCC,(a0)

.test11:
	lea	bit11(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #11,d0
	beq.s .test12
	move.w #$CCC,(a0)

.test12:
	lea	bit12(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #12,d0
	beq.s .test13
	move.w #$CCC,(a0)

.test13:
	lea	bit13(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #13,d0
	beq.s .test14
	move.w #$CCC,(a0)

.test14:
	lea	bit14(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #14,d0
	beq.s .test15
	move.w #$CCC,(a0)

.test15:
	lea	bit15(pc),a0
	add #2,a0
	move.w #$333,(a0)
	btst #15,d0
	beq.s .exit
	move.w #$CCC,(a0)

.exit:
	rte

irq4:
	move.w	#$0080,INTREQ(a1)	        ; Acknowledge
	rte

irq5:
	move.w	#$0800,INTREQ(a1)	        ; Acknowledge
	rte

synccpu:
	lea     VHPOSR(a1),a3     ; VHPOSR     
	
	; Wait until we have reached the middle of a frame
.loop 
	move.w  (a3),d2     
	and     #$FF00,d2
	cmp.w   #$A000,d2
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
	cmp.w   #$B000,d2
	bne     .synccpu4
	move.w  #$000,COLOR00(a1)  
	rts

copper: 	
	dc.w	$3001,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$30D9,$FFFE  ; WAIT 
bit15:
	dc.w	COLOR00, $000

	dc.w	$3401,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$34D9,$FFFE  ; WAIT 
bit14:
	dc.w	COLOR00, $000

	dc.w	$3801,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$38D9,$FFFE  ; WAIT 
bit13:
	dc.w	COLOR00, $000

	dc.w	$3C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$3CD9,$FFFE  ; WAIT 
bit12:
	dc.w	COLOR00, $000

	dc.w	$4001,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$40D9,$FFFE  ; WAIT 
bit11:
	dc.w	COLOR00, $000

	dc.w	$4401,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$44D9,$FFFE  ; WAIT 
bit10:
	dc.w	COLOR00, $000

	dc.w	$4801,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$48D9,$FFFE  ; WAIT 
bit9:
	dc.w	COLOR00, $000

	dc.w	$4C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$4CD9,$FFFE  ; WAIT 
bit8:
	dc.w	COLOR00, $000

	dc.w	$5001,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$50D9,$FFFE  ; WAIT 
bit7:
	dc.w	COLOR00, $000

	dc.w	$5401,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$54D9,$FFFE  ; WAIT 
bit6:
	dc.w	COLOR00, $000

	dc.w	$5801,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$58D9,$FFFE  ; WAIT 
bit5:
	dc.w	COLOR00, $000

	dc.w	$5C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$5CD9,$FFFE  ; WAIT 
bit4:
	dc.w	COLOR00, $000

	dc.w	$6001,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$60D9,$FFFE  ; WAIT 
bit3:
	dc.w	COLOR00, $000

	dc.w	$6401,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$64D9,$FFFE  ; WAIT 
bit2:
	dc.w	COLOR00, $000

	dc.w	$6801,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$68D9,$FFFE  ; WAIT 
bit1:
	dc.w	COLOR00, $000

	dc.w	$6C01,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$6CD9,$FFFE  ; WAIT 
bit0:
	dc.w	COLOR00, $000

	dc.w	$7001,$FFFE  ; WAIT 
	dc.w	COLOR00, $FFF
	dc.w	$70D9,$FFFE  ; WAIT 
	dc.w	COLOR00, $000

	dc.w    $E001,$FFFE
	dc.w    COLOR00, $F00 
	dc.w    INTREQ, $8004        ; Prepare TOD (IRQ 1)
	dc.w    $E101,$FFFE
	dc.w    COLOR00, $000 

	dc.l	$fffffffe

bitplanes:
	ds.b 61440,0
