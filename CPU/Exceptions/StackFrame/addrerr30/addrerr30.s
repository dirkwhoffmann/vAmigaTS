SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

; divu.w d1,d0 (overflow, no address error; CCR is read from the trap frame)
;
; Records the address registers A4 and A5 (unused here) in the last four rows (A4 HI/LO, A5 HI/LO).
; The stack is moved to a fixed location. The expected values below are Moira's
; prediction, not hardware results.

trap0:
	PREPARE_STACK

	; Trigger the exception
	move.l  #$FFFF0000,d0
	move.l  #$00008000,d1
	divu.w  d1,d0
	trap    #1

	NO_EXCEPTION_GENERATED

exit:
	RECORD_REGS
	jmp 	continue

info: 
    dc.b    'ADDRERR30', 0
	even

expected000:
	dc.w   	$0007, $FEFA, $0006, $0000, $0012, $201A, $0007, $57D4
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $1558, $0007, $0000

expected010:
	dc.w   	$0007, $FEF8, $0008, $0000, $0012, $201A, $0007, $57D4
	dc.w   	$0084, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $5C40, $0007, $0000

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
