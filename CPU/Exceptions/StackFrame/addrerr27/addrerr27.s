SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

; divu.w (a4)+,d0 (fault on source)
;
; Records the address registers A4 and A5 in the last four rows (A4 HI/LO, A5 HI/LO).
; The stack is moved to a fixed location. The expected values below are Moira's
; prediction, not hardware results.

trap0:
	PREPARE_STACK

	; Trigger the exception
	move.l  #$12345678,d0
	move.l  #$00414243,a4
	move.l  #$00000300,a5
	divu.w  (a4)+,d0

	NO_EXCEPTION_GENERATED

exit:
	RECORD_REGS
	jmp 	continue

info: 
    dc.b    'ADDRERR27', 0
	even

expected000:
	dc.w   	$0007, $FEF2, $000E, $0039, $EA81, $80D5, $0041, $4243
	dc.w   	$80DC, $2010, $0007, $57D6, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0041, $4243, $0000, $0300

expected010:
	dc.w   	$0007, $FEC6, $003A, $0000, $0014, $2010, $0007, $57D6
	dc.w   	$800C, $1105, $0041, $4243, $1111, $1111, $1111, $337C
	dc.w   	$1111, $337C, $0041, $4245, $0000, $0300

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
