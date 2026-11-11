SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

; move.w (a4)+,(a5)+ (fault on dest, source is valid)
;
; Records the address registers A4 and A5 after the address error. They are
; shown in the last four rows (A4 HI/LO, A5 HI/LO). The stack is moved to a
; fixed location, so the stack pointer does not depend on the host system.

trap0:
	PREPARE_STACK

	; Trigger an address error exception
	move.l  #$12345678,d0
	move.l  #$00000200,a4
	move.l  #$00414243,a5
	move.w (a4)+,(a5)+

	NO_EXCEPTION_GENERATED

exit:
	RECORD_REGS
	jmp 	continue

info: 
    dc.b    'ADDRERR21', 0
	even

expected000:
	dc.w   	$0007, $FEF2, $000E, $0039, $EA81, $3AC5, $0041, $4243
	dc.w   	$3ADC, $2010, $0007, $57D8, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0202, $0041, $4243

expected010:
	dc.w   	$0007, $FEC6, $003A, $0000, $0016, $2010, $0007, $57D8
	dc.w   	$800C, $0005, $0041, $4243, $1111, $00FC, $1111, $00FC
	dc.w   	$1111, $337C, $0000, $0202, $0041, $4243

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
