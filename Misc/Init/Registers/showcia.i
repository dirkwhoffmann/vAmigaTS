	jmp start

	include "../../../include/registers.i"
	include "../../../include/textutil.i"

start:
    ; Record values
    bsr     runtest 

	; Load OCS base address
	lea     CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

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
    moveq   #15,d2              ; Line counter
    
.l:
    ; Read measured value
    moveq   #0,d0
    move.b  (a2)+,d0

    ; Compare with the expected value and select the target bitplane accordingly
    lea     bitplane1+2,a0
    cmp.b   (a5)+,d0
    bne     .skip
    lea     bitplane2+2,a0
.skip:

    ; Print line
    move.w  d1,d3  
    mulu    #40*8,d3
    add.w   d3,a0
    bsr     writestring
    bsr     write8
    addq    #1,d1
    dbf     d2,.l
	bra     done

error:
    move.w  #$F00,$DFF180
done:
    bra.s   done

regnames:
    dc.b 'PRA    = $', 0
    dc.b 'PRB    = $', 0
    dc.b 'DDRA   = $', 0
    dc.b 'DDRB   = $', 0
    dc.b 'TALO   = $', 0
    dc.b 'TAHI   = $', 0
    dc.b 'TBLO   = $', 0
    dc.b 'TBHI   = $', 0
    dc.b 'TODLO  = $', 0
    dc.b 'TODMID = $', 0
    dc.b 'TODHI  = $', 0
    dc.b 'UNUSED = $', 0
    dc.b 'SDR    = $', 0
    dc.b 'ICR    = $', 0
    dc.b 'CRA    = $', 0
    dc.b 'CRB    = $', 0
	even

values:
    ds.b 	16,0

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
	dc.w    COLOR00,$000
	dc.w    COLOR01,$F00
	dc.w    COLOR02,$0F0
	dc.w    COLOR03,$FFF

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.l    $fffffffe

bitplane1:
	ds.b    320*256/8,$00
bitplane2:
	ds.b    320*256/8,$00
