	jmp start

	include "../../../../include/registers.i"
	include "../../../../include/textutil.i"

; Harness for the 68020 trace tests (needs vasm -m68020).
;
; The 68020 has two trace bits: T1 (SR bit 15) traces every instruction, T0 (bit 14,
; with T1 clear) traces only instructions that change the flow of control. Each test
; sets up T0 (or T1), executes the instruction under test and records the trace
; exceptions that follow. The trace handler (vector 9) records up to three of them:
;
;   word 0   Number of trace exceptions
;   word 1   Format / vector word of the first frame ($2024 = format 2, vector 9)
;   word 2   Stacked SR of the first frame
;   word 3   Stacked PC of the first frame, relative to BASEPC
;   word 4   Instruction address of the first frame (format 2), relative to BASEPC
;   word 5-6 Stacked PC and instruction address of the second trace exception
;   word 7-8 Stacked PC and instruction address of the third trace exception
;
; Missing entries read $FFFF. BASEPC is the address behind the "lea $0(pc),a0" of the
; MARK_PC macro. The handler clears T1 and T0 in the stacked SR, so each test sees
; its first trace exception only and the rest of the test runs without tracing.
; A test ends with "clr.w recflag" (stops recording) and "trap #1".

FIXED_STACK			equ $7FF00
MSP_STACK			equ $7FA00

TRC_VECTOR			equ $24
TRP0_INT_VECTOR		equ $80
TRP1_INT_VECTOR		equ $84
LEVEL3_VECTOR		equ $6C

; Disables and clears the instruction cache, so every instruction is fetched
; from memory in the same way
PREPARE_CPU MACRO
	moveq   #8,d0
	movec   d0,cacr
	ENDM

; Fills the result array with $FFFF, clears the counters, sets up the stacks
SETUP_TEST MACRO
	lea     values,a2
	moveq   #15,d2
.fv\@:
	move.w  #$FFFF,(a2)+
	dbra    d2,.fv\@
	clr.w   values
	clr.w   tracecnt
	move.w  #1,recflag
	lea     MSP_STACK,a2
	movec   a2,msp
	lea     FIXED_STACK,a7
	moveq   #0,d0
	ENDM

; Remembers the program counter. The instruction that follows is at BASEPC+2+4+... (see tests)
MARK_PC MACRO
	lea     $0(pc),a0
	move.l  a0,basepc
	ENDM

; Switches T0 on (supervisor mode, interrupts masked). The old T0 is clear, so
; this instruction itself is not traced.
SET_T0 MACRO
	move.w  #$6700,sr
	ENDM

END_TEST MACRO
	clr.w   recflag
	trap    #1
	ENDM

NO_EXCEPTION_GENERATED MACRO
	move.w  #$7FFF,DMACON(a1)
	move.w  #$0F0,COLOR00(a1)
.done:
	bra 	.done
	ENDM

start:
	lea     CUSTOM,a1

	; Disable interrupts, DMA and bitplanes
	move.w  #$7FFF,INTENA(a1)
	move.w  #$7FFF,DMACON(a1)
	move.w  #$200,BPLCON0(a1)

	; Disable CIA interrupts
	move.b  #$7F,$BFDD00  ; CIA B
	move.b  #$7F,$BFED01  ; CIA A

	; Install exception handlers
	lea		trc(pc),a3
	move.l	a3,TRC_VECTOR
	lea		lvl3(pc),a3
	move.l	a3,LEVEL3_VECTOR
	lea		trap1(pc),a3
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
    moveq   #8,d2               ; 9 rows

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

; Trace exception. Frame: SR (0), PC (2), format/vector (6), instruction address (8)
trc:
	movem.l d0-d2/a0-a1,-(a7)               ; 20 bytes. Frame is now at 20(a7)
	tst.w   recflag
	beq     .out
	move.w  tracecnt,d0
	lea     values,a0
	cmp.w   #3,d0
	bhs     .count
	tst.w   d0
	bne     .rest
	move.w  26(a7),2(a0)                    ; Format / vector word
	move.w  20(a7),4(a0)                    ; SR
.rest:
	lea     6(a0),a1
	lsl.w   #2,d0
	add.w   d0,a1                           ; Entry of this exception
	move.l  basepc,d2
	move.l  22(a7),d1
	sub.l   d2,d1
	move.w  d1,(a1)+                        ; PC
	move.l  28(a7),d1
	sub.l   d2,d1
	move.w  d1,(a1)+                        ; Instruction address
.count:
	addq.w  #1,tracecnt
	move.w  tracecnt,values
.out:
	and.w   #$3FFF,20(a7)                   ; Switch tracing off
	movem.l (a7)+,d0-d2/a0-a1
	rte

; Level 3 interrupt (vertical blank). Wakes up STOP.
lvl3:
	move.w  #$0020,$DFF09C
	rte

; TRAP #1 ends a test
trap1:
	move.w  #$3FFF,$DFF09A                  ; Interrupts off
	jmp     exit

	even
regnames:
    dc.b ' Trace exceptions = $', 0
    dc.b ' Format / vector  = $', 0
    dc.b ' Stacked SR       = $', 0
    dc.b ' Trace 1 PC       = $', 0
    dc.b ' Trace 1 IA       = $', 0
    dc.b ' Trace 2 PC       = $', 0
    dc.b ' Trace 2 IA       = $', 0
    dc.b ' Trace 3 PC       = $', 0
    dc.b ' Trace 3 IA       = $', 0
	even

tracecnt:
	dc.w    0
recflag:
	dc.w    0
basepc:
	dc.l    0
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
