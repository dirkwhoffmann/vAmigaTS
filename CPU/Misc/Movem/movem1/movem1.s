SHOW_REGS equ 1
CUSTOM_ROWS equ 1
FIXED_STACK equ $7FF00
	include "../../../Exceptions/StackFrame/stackframe.i"

; MOVEM <list>,-(An) with An in the register list
;
; Question this test answers: Which value of An does MOVEM store if An is part
; of the list? The 68000 and the 68010 are expected to store the initial value.
; For the 68020, two variants were in question: the value An has when it is
; written (An updated with each write), or the initial value minus the operand
; size.
;
; Each row shows initial An minus a value (0 = the initial value):
;
;   case 1  movem.l a2/a3,-(a2)   A3 is written first, then A2
;   case 2  movem.l a2,-(a2)      A2 is the only register
;   case 3  movem.w a2/a3,-(a2)   word size, A3 is written first
;
;   row 0, 2, 4   stored value of A2
;   row 1, 3, 5   final value of A2
;
; Stored value (row 0, 2, 4) for both variants:
;
;   68000, 68010               0, 0, 0
;   68020 (updated An)         8, 4, 4
;   68020 (initial - size)     4, 4, 2
;
; Result: The 68000 and the 68010 store the initial value. The 68020 stores the
; initial value minus the operand size.
; The expected values below were recorded on an A500, an A500 with a 68010, and
; an A1200.

trap0:
	PREPARE_STACK

	lea     values,a3

	; Case 1
	lea     buffer+8,a2
	move.l  a2,d2                   ; Initial value
	movem.l a2/a3,-(a2)
	move.l  d2,d0
	sub.l   buffer,d0               ; Initial minus stored A2
	move.w  d0,(a3)+
	move.l  d2,d0
	sub.l   a2,d0                   ; Initial minus final A2
	move.w  d0,(a3)+

	; Case 2
	lea     buffer+8,a2
	move.l  a2,d2
	movem.l a2,-(a2)
	move.l  d2,d0
	sub.l   buffer+4,d0
	move.w  d0,(a3)+
	move.l  d2,d0
	sub.l   a2,d0
	move.w  d0,(a3)+

	; Case 3
	lea     buffer+8,a2
	move.l  a2,d2
	movem.w a2/a3,-(a2)
	move.w  d2,d0
	sub.w   buffer+4,d0
	move.w  d0,(a3)+
	move.l  d2,d0
	sub.l   a2,d0
	move.w  d0,(a3)+

	; Clear the remaining rows
	moveq   #15,d0
.clear:
	clr.w   (a3)+
	dbra    d0,.clear

	jmp     exit

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

	cnop    0,4
buffer:
	dc.l    0, 0, 0, 0

info:
    dc.b    'MOVEM1 (MOVEM -(An) with An in the list)', 0
	even

rownames:
    dc.b ' L A2/A3 stored   = $', 0
    dc.b ' L A2/A3 final    = $', 0
    dc.b ' L A2 stored      = $', 0
    dc.b ' L A2 final       = $', 0
    dc.b ' W A2/A3 stored   = $', 0
    dc.b ' W A2/A3 final    = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
	even

expected000:
	dc.w   	$0000, $0008, $0000, $0004, $0000, $0004, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected010:
	dc.w   	$0000, $0008, $0000, $0004, $0000, $0004, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected020:
	dc.w   	$0004, $0008, $0004, $0004, $0002, $0004, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
