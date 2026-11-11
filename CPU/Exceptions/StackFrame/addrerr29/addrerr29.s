SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

; move.w sr,(a4)+ (write, post-increment)
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
	move.w  sr,(a4)+

	NO_EXCEPTION_GENERATED

exit:
	RECORD_REGS
	jmp 	continue

info: 
    dc.b    'ADDRERR29', 0
	even

expected000:
	dc.w   	$0007, $FEF2, $000E, $0039, $EA81, $40D5, $0041, $4243
	dc.w   	$40DC, $2010, $0007, $57D6, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0041, $4243, $0000, $0300

expected010:
	dc.w   	$0007, $FEC6, $003A, $0000, $0016, $2010, $0007, $57D8
	dc.w   	$800C, $0005, $0041, $4243, $1111, $2010, $1111, $7FFF
	dc.w   	$1111, $7FFF, $0041, $4245, $0000, $0300

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
