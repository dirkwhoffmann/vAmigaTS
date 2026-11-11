FIXED_STACK equ $7FF00
	include "../stackframe020.i"

; rts with an odd return address on the stack

trap0:
	PREPARE_CPU
	CLEAR_STACK
	move.l  #$00040001,FIXED_STACK
	MARK_PC
	rts

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'FRAME020_6', 0
	even

; Reference values recorded on my stock Amiga 1200
expected020:
	dc.w   	$0007, $FEA8, $0058, $0000, $0002, $2010, $0007, $56E0
	dc.w   	$B00C, $FEEC, $3045, $0096, $337C, $0007, $FF00, $0007
	dc.w   	$FF00, $0004, $0001, $4E75, $4E75, $0000, $0000, $0000
	dc.w   	$0008
