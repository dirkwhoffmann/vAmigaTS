FIXED_STACK equ $7FF00
	include "../stackframe020.i"

; jmp 6(a4), the effective address is odd

trap0:
	PREPARE_CPU
	CLEAR_STACK
	move.l  #$40001,a4
	MARK_PC
	jmp 	6(a4)

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'FRAME020_2', 0
	even

; Reference values recorded on my stock Amiga 1200
expected020:
	dc.w   	$0007, $FEA4, $005C, $0000, $0002, $2010, $0007, $56DC
	dc.w   	$B00C, $CEEC, $2005, $0100, $007C, $0007, $56E0, $0004
	dc.w   	$0007, $0000, $1111, $4EEC, $4EEC, $0007, $0144, $0000
	dc.w   	$0008
