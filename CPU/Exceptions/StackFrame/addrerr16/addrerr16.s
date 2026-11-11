SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

; move.l d0,-(a4) (write, pre-decrement)
;
; Records the address registers A4 and A5 after the address error. They are
; shown in the last four rows (A4 HI/LO, A5 HI/LO). The stack is moved to a
; fixed location, so the stack pointer does not depend on the host system.

trap0:
	PREPARE_STACK

	; Trigger an address error exception
	move.l  #$12345678,d0
	move.l  #$00414243,a4
	move.l  #$00000300,a5
	move.l d0,-(a4)

	NO_EXCEPTION_GENERATED

exit:
	RECORD_REGS
	jmp 	continue

info: 
    dc.b    'ADDRERR16', 0
	even

expected000:
	dc.w   	$0007, $FEF2, $000E, $0039, $EA7F, $2905, $0041, $4241
	dc.w   	$2900, $2010, $0007, $57D8, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0041, $4243, $0000, $0300

expected010:
	dc.w   	$0007, $FEC6, $003A, $0000, $0016, $2010, $0007, $57D8
	dc.w   	$800C, $0005, $0041, $4241, $1111, $5678, $1111, $7FFF
	dc.w   	$1111, $7FFF, $0041, $4243, $0000, $0300

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
