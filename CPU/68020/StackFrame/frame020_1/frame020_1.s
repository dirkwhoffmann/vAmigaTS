FIXED_STACK equ $7FF00
	include "../stackframe020.i"

; jmp (a4) with an odd address in A4

trap0:
	PREPARE_CPU
	CLEAR_STACK
	move.l  #$40001,a4
	MARK_PC
	jmp 	(a4)

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'FRAME020_1', 0
	even

; Reference values recorded on my stock Amiga 1200
expected020:
	dc.w   	$0007, $FEA4, $005C, $0000, $0002, $2010, $0007, $56DC
	dc.w   	$B00C, $FEEC, $3005, $0096, $337C, $0007, $56E0, $0007
	dc.w   	$56DA, $0000, $1111, $4ED4, $4ED4, $0007, $0144, $0000
	dc.w   	$0008
