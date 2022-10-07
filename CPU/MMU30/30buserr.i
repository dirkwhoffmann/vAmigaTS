	jmp start

	include "../../../include/registers.i"
	include "../../../include/textutil.i"

BUS_ERR_VECTOR      equ $08
TRP0_INT_VECTOR		equ $80
TRP1_INT_VECTOR	    equ $84

start:
	; Load OCS base address
	lea     CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Install trap handlers
	lea	buserr(pc),a3
	move.l	a3,BUS_ERR_VECTOR
	lea	trap0(pc),a3
	move.l	a3,TRP0_INT_VECTOR
	lea	trap1(pc),a3
	move.l	a3,TRP1_INT_VECTOR

	; Setup the MMU
	move.w  #$A00,COLOR00(a1)
    trap    #1

    ; Run the test code
	move.w  #$AA0,COLOR00(a1)
    trap    #0

continue:
	; Setup bitplane pointers
	lea     copper(pc),a3

	lea     bitplane1(pc),a2
	move.l 	a2,d1
	move.w	d1,2(a3)
    swap    d1
	move.w	d1,6(a3)

	lea     bitplane2(pc),a2
	move.l 	a2,d1
	move.w	d1,10(a3)
    swap    d1
	move.w	d1,14(a3)

    ; Open font (a4 will contain the font data)
    bsr     openfont

	; Setup Copper
	lea	    copper(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #$8003,COPCON(a1)   ; Allow Copper to write Blitter registers

	; Enable DMA
	move.w	#$8080,DMACON(a1)   ; Copper DMA 	
	move.w	#$8100,DMACON(a1)   ; Bitplane DMA 
	move.w	#$8200,DMACON(a1)   ; DMAEN 
	move.w	#$8400,DMACON(a1)   ; BlitPri = 1 

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
    moveq   #6,d2               ; Line counter

   	move.w  #$060,$DFF180 
.l:
    ; Read measured value
    moveq   #0,d0
    move.w  (a2)+,d0

    ; Compare with the expected value and select the target bitplane accordingly
    lea     bitplane2+2,a0
    cmp.w   (a5)+,d0
    beq     .skip
    lea     bitplane1+2,a0
	move.w  #$600,$DFF180
.skip:

    ; Print line
    move.w  d1,d3  
    mulu    #40*8,d3
    add.w   d3,a0
    bsr     writestring
    bsr     write16
    addq    #1,d1
    dbf     d2,.l
	bra     done

error:
    move.w  #$F00,$DFF180
done:
    bra.s   done

trap1: 
	jsr 	setupMMU
	rte

trigger:
	; Save current MMUSR in D0
	pmove  	MMUSR,(a2)
	move.w  (a2),d0

	; Save current stack pointer in A0
	move.l  a7,a0

	; Trigger a bus fault by accessing the $Axxxxx range
    move.w  #$060,$aff180
	rts

trigger_usermode:
	; Save current MMUSR in D0
	pmove  	MMUSR,(a2)
	move.w  (a2),d0

	; Save current stack pointer in A0
	move.l  a7,a0

	; Switch to user mode (clear S bit)
	move 	#0,SR

	; Trigger a bus fault by accessing the $Axxxxx range
    move.w  #$060,$AFF180

.shouldnotreach:
	move.w	#$F0F,$DFF180
	bra 	.shouldnotreach
	rts

buserr:
	move.w 	#$008,COLOR00(a1)
    lea     values,a3

	; Record D0.w (contains old MMUSR)
	move.w  d0,(a3)+

	; Record current MMUSR
    pmove  	MMUSR,(a3)
    addq   	#2,a3

	; Compute and record the stack size (old SP is stored in A0)
	sub     a7,a0
	move.w  a0,(a3)+

	; Read and record SR from stack
	move.l  a7,a2
	move.w  (a2)+,(a3)+

	; Read and record PC from stack
	move.l  (a2)+,(a3)+

	; Read and record vector offset from stack
	move.w  (a2)+,(a3)+

	pflusha
	jmp     exit

	even
regnames:
    dc.b ' 0: Old MMUSR      = $', 0
    dc.b ' 1: New MMUSR      = $', 0
    dc.b ' 2: Stack size     = $', 0
    dc.b ' 3: SR   (Stack+0) = $', 0
    dc.b ' 4: PCHI (Stack+2) = $', 0
    dc.b ' 5: PCLO (Stack+4) = $', 0
    dc.b ' 6: Vec  (Stack+6) = $', 0
    dc.b ' ?: ', 0
    dc.b ' ?: ', 0
    dc.b ' ?: ', 0
    dc.b ' ?: ', 0
    dc.b ' ?: ', 0
    dc.b ' ?: ', 0
	
	even
values:
    dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
    dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

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
	dc.w    DIWSTRT,$2C81
	dc.w    DIWSTOP,$F4C1
	dc.w    BPLCON0,(2<<12)|$200
	dc.w    BPLCON1,$0000
	dc.w    BPLCON2,$0000
	dc.w    BPL1MOD,$0000
	dc.w    BPL2MOD,$0000
	dc.w    COLOR01,$F00
	dc.w    COLOR02,$0F0
	dc.w    COLOR03,$FFF

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.l    $fffffffe

    even
    
bitplane1:
	ds.b    320*256/8,$00
bitplane2:
	ds.b    320*256/8,$00
