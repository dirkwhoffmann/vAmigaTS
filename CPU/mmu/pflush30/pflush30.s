	jmp start

	include "../../../include/registers.i"
	include "../../../include/textutil.i"

LINE_F_INSTR_VECTOR     equ $2C
TRP0_INT_VECTOR		    equ $80

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
	lea	trap0(pc),a3
	move.l	a3,TRP0_INT_VECTOR
	lea	illegal(pc),a3
    move.l	a3,LINE_F_INSTR_VECTOR

    ; Run the test code
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
    bra     done
error:
    move.w  #$F00,$DFF180
done:
    bra.s   done

trap0:
    pflusha
    lea     copper1,a0
    move.w  #$040,$2(a0)

    pflush  #0,#0
    lea     copper2,a0
    move.w  #$060,$2(a0)

    pflush  #0,#0,(a0)
    lea     copper3,a0
    move.w  #$080,$2(a0)

    pflush  #0,#0,$FF(a0)
    lea     copper4,a0
    move.w  #$0A0,$2(a0)

    pflush  #0,#0,$FF.w
    lea     copper5,a0
    move.w  #$0C0,$2(a0)

    pflush  #0,#0,$FFFF.l
    lea     copper6,a0
    move.w  #$0E0,$2(a0)
    rte

illegal:
    jmp     continue

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

    dc.w    $4001,$fffe
copper1:
    dc.w    COLOR00,$400
    dc.w    $6001,$fffe
copper2:
    dc.w    COLOR00,$600
    dc.w    $8001,$fffe
copper3:
    dc.w    COLOR00,$800
    dc.w    $A001,$fffe
copper4:
    dc.w    COLOR00,$A00
    dc.w    $C001,$fffe
copper5:
    dc.w    COLOR00,$C00
    dc.w    $E001,$fffe
copper6:
    dc.w    COLOR00,$E00

	; Cross vertical boundary
	dc.w    $ffdf,$fffe 

	dc.l    $fffffffe

    even
    
bitplane1:
	ds.b    320*256/8,$00
bitplane2:
	ds.b    320*256/8,$00
info: 
    dc.b    'PFLUSH30', 0
    even 
