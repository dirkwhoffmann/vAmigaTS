	jmp start

	include "../../../../include/registers.i"
	include "../../../../include/textutil.i"

; Harness for the 68020 stack frame tests (needs vasm -m68020).
;
; Every test provokes one exception and records the stack frame. The handler
; stores 25 words in the "values" array which are compared with "expected020":
;
;   2 words   Stack pointer after the exception
;   1 word    Number of bytes the stack pointer has moved (A0 - SP)
;   2 words   Stacked PC relative to the program counter at MARK_PC
;  16 words   First 32 bytes of the stack frame (SP+0 ... SP+30)
;   2 words   The longword below the old stack pointer (A0-4). The 68020 reserves
;             this slot when the return address of a JSR/BSR cannot be pushed.
;   2 words   D0
;
; A format B frame (bus error / address error) occupies 92 bytes, a format 2
; frame (zero divide, CHK) 12 bytes, a format 0 frame (TRAP) 8 bytes. The stack
; area is cleared with $1111 before each test, so unwritten frame words are
; deterministic.

ADDR_ERR_VECTOR		equ $0C
ILL_EXC_VECTOR		equ $10
ZERODIV_VECTOR		equ $14
CHK_EXC_VECTOR		equ $18
FORMAT_ERR_VECTOR	equ $38
TRP0_INT_VECTOR		equ $80
TRP1_INT_VECTOR	    equ $84

; Disables and clears the instruction cache, so that a fetch from an odd
; address cannot be served by the cache
PREPARE_CPU MACRO
	moveq   #8,d0
	movec   d0,cacr
	ENDM

; Sets up the stack and fills a window around it with $1111
CLEAR_STACK MACRO
	lea 	FIXED_STACK+64,a2
	moveq   #95,d2
.cl\@:
	move.w  #$1111,-(a2)
	dbra    d2,.cl\@
	lea 	FIXED_STACK,a7
	ENDM

; Remembers the stack pointer in A0 and the program counter in A6. The
; instruction under test has to follow immediately.
; (Tests that define ABSOLUTE_PC set A6 to zero. They record the stacked PC as is.)
MARK_PC MACRO
	move.l  a7,a0
	ifd ABSOLUTE_PC
	suba.l  a6,a6
	else
	lea     $0(pc),a6
	endc
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

	; Install exception handlers
	lea		exc(pc),a3
	move.l	a3,ADDR_ERR_VECTOR
	move.l	a3,ILL_EXC_VECTOR
	move.l	a3,ZERODIV_VECTOR
	move.l	a3,CHK_EXC_VECTOR
	move.l	a3,FORMAT_ERR_VECTOR
	move.l	a3,TRP1_INT_VECTOR
	lea		trap0(pc),a3
	move.l	a3,TRP0_INT_VECTOR

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
    lea     expected020,a5      ; Expected values
    lea     regnames(pc),a1     ; Output strings
    moveq   #3,d1               ; First output row
    moveq   #24,d2              ; 25 rows

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

exc:
	move.w 	#$008,COLOR00(a1)
	move.l  a7,a2
	lea     values,a3

	; Stack pointer and stack size (old SP is stored in A0)
	move.l  a2,(a3)+
	move.l  a0,d3
	sub.l   a2,d3
	move.w  d3,(a3)+

	; Stacked PC relative to A6
	move.l  $2(a2),d3
	sub.l   a6,d3
	move.l  d3,(a3)+

	; First 32 bytes of the frame
	moveq   #15,d3
.rec:
	move.w  (a2)+,(a3)+
	dbra    d3,.rec

	; Slot below the old stack pointer, D0
	move.l  -4(a0),(a3)+
	move.l  d0,(a3)+

	; Jump to the exit handler (test case specific)
	jmp exit

	even
regnames:
    dc.b ' Stack pointer HI = $', 0
    dc.b ' Stack pointer LO = $', 0
    dc.b ' Stack size       = $', 0
    dc.b ' PC rel HI        = $', 0
    dc.b ' PC rel LO        = $', 0
    dc.b ' SP+00            = $', 0
    dc.b ' SP+02            = $', 0
    dc.b ' SP+04            = $', 0
    dc.b ' SP+06            = $', 0
    dc.b ' SP+08            = $', 0
    dc.b ' SP+10            = $', 0
    dc.b ' SP+12            = $', 0
    dc.b ' SP+14            = $', 0
    dc.b ' SP+16            = $', 0
    dc.b ' SP+18            = $', 0
    dc.b ' SP+20            = $', 0
    dc.b ' SP+22            = $', 0
    dc.b ' SP+24            = $', 0
    dc.b ' SP+26            = $', 0
    dc.b ' SP+28            = $', 0
    dc.b ' SP+30            = $', 0
    dc.b ' SLOT HI          = $', 0
    dc.b ' SLOT LO          = $', 0
    dc.b ' D0 HI            = $', 0
    dc.b ' D0 LO            = $', 0
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
	dc.w    DIWSTOP,$2CC1
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
