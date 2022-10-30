COPPER 	MACRO
    ; 0
    dc.w    $4081,$FFFE
    ; dc.w    BPLCON0,$2202        ; Freeze
    dc.w    INTREQ, $8004        ; Level 1 interrupt
	ENDM
    
	;include "../probe.i"
 	include "../../../include/registers.i"
	include "../../../include/ministartup.i"
	include "../../../include/textutil.i"
 
LVL1_INT_VECTOR		equ $64
LVL2_INT_VECTOR		equ $68
LVL3_INT_VECTOR		equ $6c

MAIN:
	; Load OCS base address
	lea     CUSTOM,a1
	move.w  #$0F0,COLOR00(a1)

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Install interrupt handlers
	lea	    irq1(pc),a3
 	move.l	a3,LVL1_INT_VECTOR
	lea	    irq2(pc),a3
 	move.l	a3,LVL2_INT_VECTOR
	lea	    irq3(pc),a3
 	move.l	a3,LVL3_INT_VECTOR

    ; Open font (a4 will contain the font data)
    bsr     openfont

    ; Print info message 
	lea     bitplane1,a0
    lea     info,a1
    bsr     writestring
	lea     bitplane2,a0
    lea     info,a1
    bsr     writestring

    lea     values,a2           ; Measured values
    lea     expected,a5         ; Expected values
    lea     regnames(pc),a1     ; Output strings
    moveq   #3,d1               ; First output row
    moveq   #15,d2              ; Line counter
    lea     CUSTOM,a1

    ; Setup colors
	move.w  #$000,COLOR00(a1)
	move.w  #$F00,COLOR01(a1)
	move.w  #$0F0,COLOR02(a1)
	move.w  #$FFF,COLOR03(a1)

	; Setup Copper
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #$8003,COPCON(a1)   ; Allow Copper to write Blitter registers

	; Enable innterrupts
	move.w	#$C02C,INTENA(a1) 

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 
	move.w	#$8400,DMACON(a1)   ; BlitPri = 1 

    ; Initialize counters
    moveq   #0,d4
done:
    bra.s   done
error:
    move.w  #$F00,$DFF180
    bra.s   done

irq1:
    move.w  #$300,COLOR00(a1)

    move.w  #$2202,BPLCON0(a1) ; External sync

    lea     values,a2
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+
    move.w  VHPOSR(a1),d5
    move.w  d5,(a2)+

    move.w  #$2200,BPLCON0(a1) ; Internal sync

	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	
    move.w  #$000,COLOR00(a1)
	rte

irq2:
    movem.l	d0-a6,-(sp)

    ; Setup
    lea     values,a2           ; Measured values
    lea     expected,a5         ; Expected values
    lea     regnames(pc),a1     ; Output strings
    moveq   #3,d1               ; First output row
    moveq   #15,d2              ; Line counter
.l:
    ; Read measured value
    move.w  d2,$DFF180
    moveq   #0,d0
    move.w  (a2)+,d0

    ; Compare with the expected value and select the target bitplane accordingly
    lea     bitplane1+2,a0
    cmp.w   (a5)+,d0
    bne     .skip
    lea     bitplane2+2,a0
.skip:
    ; Print line
    move.w  d1,d3  
    mulu    #40*8,d3
    add.w   d3,a0
    bsr     writestring
    bsr     write16
    addq    #1,d1
    dbf     d2,.l

    lea     CUSTOM,a1
	move.w  #$3FFF,INTREQ(a1)         ; Acknowledge	

    movem.l	(sp)+,d0-a6

    move.w  #$000,COLOR00(a1)
    moveq   #0,d4
	rte

irq3:
	movem.l	d0-a6,-(sp)
	lea 	CUSTOM,a1
	move.w	#$3FFF,INTREQ(a1)	; Acknowledge
	move.l  #bitplane1,BPL1PTH(a1)
	move.l  #bitplane2,BPL2PTH(a1)
	move.w  #$38,DDFSTRT(a1)
	move.w  #$D0,DDFSTOP(a1)
	move.w  #$2C81,DIWSTRT(a1)
	move.w  #$F4C1,DIWSTOP(a1)
	move.w  #$2200,BPLCON0(a1)
	move.w  #0,BPLCON1(a1)
	move.w  #0,BPLCON2(a1)
	move.w  #0,BPL1MOD(a1)
	move.w  #0,BPL2MOD(a1)
	movem.l	(sp)+,d0-a6
	rte

regnames:
    dc.b '0: $', 0
    dc.b '1: $', 0
    dc.b '2: $', 0
    dc.b '3: $', 0
    dc.b '4: $', 0
    dc.b '5: $', 0
    dc.b '6: $', 0
    dc.b '7: $', 0
    dc.b '8: $', 0
    dc.b '9: $', 0
    dc.b 'A: $', 0
    dc.b 'B: $', 0
    dc.b 'C: $', 0
    dc.b 'D: $', 0
    dc.b 'E: $', 0
    dc.b 'F: $', 0
	even

    ALIGN 2
values:
    ds.w 	16,0

copper:

    ; Run the test
    COPPER

    ; Print values
    dc.w    $6001,$FFFE
    dc.w    INTREQ, $8008        ; Level 2 interrupt

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 
    
    ; Disable Copper DMA (if the Copper should be executed for one frame only)
	dc.w    $20df,$fffe 
    ; dc.w    DMACON,$0080

	dc.l    $fffffffe

bitplane1:
	ds.b    320*256/8,$00
bitplane2:
	ds.b    320*256/8,$00

 info: 
    dc.b    'ERSY2', 0
    ALIGN 2
expected:
    dc.w    $40BF,$40C9,$40D3,$40DD,$4000,$4000,$4000,$4000
    dc.w    $4000,$4000,$4000,$4000,$4000,$4000,$4000,$4000
