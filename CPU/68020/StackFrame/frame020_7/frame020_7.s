FIXED_STACK equ $7FF00
	include "../stackframe020.i"

; rtr with an odd return address on the stack

trap0:
	PREPARE_CPU
	CLEAR_STACK
	clr.w   FIXED_STACK
	move.l  #$00040001,FIXED_STACK+2
	MARK_PC
	rtr

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'FRAME020_7', 0
	even

; Reference values recorded on my stock Amiga 1200
expected020:
	dc.w   	$0007, $FEAA, $0056, $0000, $0002, $2000, $0007, $56E6
	dc.w   	$B00C, $FEEC, $3065, $0096, $337C, $0007, $FF04, $0007
	dc.w   	$FF02, $0004, $0001, $4E77, $4E77, $0000, $0000, $0000
	dc.w   	$0008
