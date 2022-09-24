	jmp start

	include "../../../include/registers.i"
	include "../../../include/textutil.i"

LINE_F_INSTR_VECTOR     equ $2C
TRP0_INT_VECTOR		    equ $80
TRP1_INT_VECTOR		    equ $84
MMU_CONFIG_ERROR        equ $E0

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
	lea		trap0(pc),a3
	move.l	a3,TRP0_INT_VECTOR
	lea		trap1(pc),a3
	move.l	a3,TRP1_INT_VECTOR
	lea		illegal(pc),a3
    move.l	a3,LINE_F_INSTR_VECTOR
	lea		mmuconferr(pc),a3
    move.l	a3,MMU_CONFIG_ERROR

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

	; Load info string
	lea 	info,a2 

	; Check CPU model (we need a 68030)
	move.l  $4,a6
.check030:
	btst    #2,$129(a6)	
	bne     .check040		; Branch if 030 flag is set
	lea     wrongcpu,a2
.check040:
	btst    #3,$129(a6)	
	beq     .printinfo		; Branch if 040 flag is cleared
	lea     wrongcpu,a2
.printinfo:
    ; Print info message 
	lea     bitplane1,a0
    move.l  a2,a1
    bsr     writestring
	lea     bitplane2,a0
    move.l  a2,a1
    bsr     writestring
	lea     CUSTOM,a1

	; Setup the MMU
	move.w  #$A00,COLOR00(a1)
    trap    #1

    ; Run the test code
	move.w  #$AA0,COLOR00(a1)
    trap    #0
done:
    bra.s   done
error:
    move.w  #$F00,COLOR00(a1)
	bra     done

trap1: 
	jsr 	setupMMU
	rte

illegal:
	move.w  #$A0A,COLOR00(a1)
    bra     illegal

mmuconferr:
	move.w  #$00A,COLOR00(a1)
	bra     mmuconferr

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
    
wrongcpu:
    dc.b    'A 68030 CPU is required to run this test', 0
bitplane1:
	ds.b    320*256/8,$00
bitplane2:
	ds.b    320*256/8,$00
    even 
