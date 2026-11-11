SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

; clr.l $414243 (write, abs.l)
;
; Records the address registers A4 and A5 in the last four rows (A4 HI/LO, A5 HI/LO).
; The stack is moved to a fixed location. The expected values below are Moira's
; prediction, not hardware results.

trap0:
	PREPARE_STACK

	; Trigger the exception
	clr.l   $414243

	NO_EXCEPTION_GENERATED

exit:
	RECORD_REGS
	jmp 	continue

info: 
    dc.b    'ADDRERR31', 0
	even

expected000:
	dc.w   	$0007, $FEF2, $000E, $0039, $EA81, $42B5, $0041, $4243
	dc.w   	$42B9, $2010, $0007, $57CA, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $1558, $0007, $0000

expected010:
	dc.w   	$0007, $FEC6, $003A, $0000, $000A, $2014, $0007, $57CC
	dc.w   	$800C, $0005, $0041, $4245, $1111, $0000, $1111, $7FFF
	dc.w   	$1111, $7FFF, $0000, $5C40, $0007, $0000

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
