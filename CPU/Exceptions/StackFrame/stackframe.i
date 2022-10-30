	jmp start

	include "../../../../include/registers.i"
	include "../../../../include/textutil.i"

ADDR_ERR_VECTOR		equ $0C
ILL_EXC_VECTOR		equ $10
CHK_EXC_VECTOR		equ $18
FORMAT_ERR_VECTOR	equ $38
TRP0_INT_VECTOR		equ $80
TRP1_INT_VECTOR	    equ $84
TRP2_INT_VECTOR	    equ $88

RECORD_GENERIC MACRO
	move.w 	#$008,COLOR00(a1)
	move.l  a7,a2
    lea     values,a3

	; Record the stack pointer
	move.l  a2,(a3)+

	; Record the stack size (old SP is stored in A0)
	sub     a2,a0
	move.w  a0,(a3)+

	; Compute the relative program counter (old value is stored in A6)
	move.l  $2(a2),a0 
	sub.l   a6,a0
	move.l  a0,(a3)+ 	

	; Read and record SR from stack (SP+0)
	move.w  (a2)+,(a3)+

	; Record the program counter (SP+2, SP+4)
	move.l  (a2)+,(a3)+

	; Record the stack frame type and vector offset (68010)
	move.w  (a2)+,(a3)+
	ENDM

PREPARE_STACK MACRO
	jsr 	clrstack
	move.l  a7,a0		; Save current stack pointer in A0
	lea     $0(pc),a6	; Save current PC in A6
	ENDM

NO_EXCEPTION_GENERATED MACRO
	move.w  #$7FFF,DMACON(a1)
	move.w  #$0F0,COLOR00(a1)
.done:
	bra 	.done
	ENDM

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
	lea		adrerr(pc),a3
	move.l	a3,ADDR_ERR_VECTOR
	lea		illex(pc),a3
	move.l	a3,ILL_EXC_VECTOR
	lea		chkex(pc),a3
	move.l	a3,CHK_EXC_VECTOR
	lea 	fmterr(pc),a3 
	move.l	a3,FORMAT_ERR_VECTOR
	lea		trap0(pc),a3
	move.l	a3,TRP0_INT_VECTOR
	lea		trap1(pc),a3
	move.l	a3,TRP1_INT_VECTOR
	lea		trap2(pc),a3
	move.l	a3,TRP2_INT_VECTOR

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
    jsr     checkcpu            ; A5 will point to the expected values
    lea     regnames(pc),a1     ; Output strings
    moveq   #3,d1               ; First output row
	moveq   #0,d2
	move.w  $4(a2),d2			; Stack size in bytes
	lsr     #1,d2 				; Stack size in words
	cmp     #17,d2
	ble     .skipit
	move.w  #17,d2
.skipit:
	addq	#4,d2				; Total number of output rows

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
	bra.s   done
error: 
	move.w  #$F00,COLOR00(a1)
done:
    bra.s   done

clrstack:
	move.l 	a7,a2
	moveq   #28,d2
.loop:
	move.w  #$1111,-(a2) 
	dbra    d2,.loop
	rts

checkcpu:
	move.l  $4,a5			; Load exec base
.check020:					; Check CPU model
	btst    #1,$129(a5)	
	beq     .check010		; Branch if 020 flag is cleared
	lea     expected020,a5
	rts
.check010:
	btst    #0,$129(a5)	
	beq     .check000		; Branch if 010 flag is cleared
	lea     expected010,a5
	rts
.check000:
	lea     expected000,a5
	rts

illex:
	RECORD_GENERIC

	; Jump to the exit handler (test case specific)
	jmp exit

fmterr:
	RECORD_GENERIC

	; Jump to the exit handler (test case specific)
	jmp exit

trap1:
trap2:
	RECORD_GENERIC

	; Jump to the exit handler (test case specific)
	jmp exit

adrerr:
	RECORD_GENERIC

	; Read auxiliary words
	move.l  (a2)+,(a3)+
	move.l  (a2)+,(a3)+
	move.l  (a2)+,(a3)+
	move.l  (a2)+,(a3)+
	move.w  (a2)+,(a3)+

	; Jump to the exit handler (test case specific)
	jmp exit

chkex:
	RECORD_GENERIC

	; Jump to the exit handler (test case specific)
	jmp exit

	even
regnames:
    dc.b ' Stack pointer HI = $', 0
    dc.b ' Stack pointer LO = $', 0
    dc.b ' Stack size       = $', 0
    dc.b ' PC rel HI        = $', 0
    dc.b ' PC rel LO        = $', 0
    dc.b ' SP+00:           = $', 0
    dc.b ' SP+02:           = $', 0
    dc.b ' SP+04:           = $', 0
    dc.b ' SP+06:           = $', 0
    dc.b ' SP+08:           = $', 0
    dc.b ' SP+10:           = $', 0
    dc.b ' SP+12:           = $', 0
    dc.b ' SP+14:           = $', 0
    dc.b ' SP+16:           = $', 0
    dc.b ' SP+18:           = $', 0
    dc.b ' SP+20:           = $', 0
    dc.b ' SP+22:           = $', 0
    dc.b ' SP+24:           = $', 0
    dc.b ' SP+26:           = $', 0
    dc.b ' SP+28:           = $', 0
    dc.b ' SP+30:           = $', 0
    dc.b ' SP+32:           = $', 0
	even
values:
	ds.b    512,0

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
