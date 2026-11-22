SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

; movea.w -(a4),a5 (read, pre-decrement, address register destination)
;
; Question this test answers: Does MOVEA stack the same frame as MOVE (see
; addrerr13)? On the 68010, a failing -(An) word read stacks a program counter
; that is 2 lower than on the 68000. addrerr13 shows this for move.w -(a4),d0.
; This test checks whether MOVEA behaves the same way. Both instructions have
; the same length, so the frames should only differ in the opcode.
;
; - If MOVEA behaves like MOVE, the relative PC (rows 2 and 3) is $0014 on the
;   68010, like in addrerr13.
; - If MOVEA stacks the PC like the 68000, the relative PC is $0016.
;
; The last four rows show A4 and A5 (A5 must still hold $300, because the
; destination is not written).
;
; The expected values are placeholders. Record them on an A500 (68000) and on
; an A500 with a 68010.

trap0:
	PREPARE_STACK

	; Trigger an address error exception
	move.l  #$12345678,d0
	move.l  #$00414243,a4
	move.l  #$00000300,a5
	movea.w -(a4),a5

	NO_EXCEPTION_GENERATED

exit:
	RECORD_REGS
	jmp 	continue

info: 
    dc.b    'ADDRERR39', 0
	even

expected000:
	dc.w   	$0007, $FEF2, $000E, $0039, $EA7F, $3A75, $0041, $4241
	dc.w   	$3A64, $2010, $0007, $57D8, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0041, $4241, $0000, $0300

expected010:
	dc.w   	$0007, $FEC6, $003A, $0000, $0014, $2010, $0007, $57D6
	dc.w   	$800C, $1105, $0041, $4241, $1111, $1111, $1111, $337C
	dc.w   	$1111, $337C, $0041, $4241, $0000, $0300

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
