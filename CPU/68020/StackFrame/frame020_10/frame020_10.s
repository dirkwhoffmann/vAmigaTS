FIXED_STACK equ $7FF00
	include "../stackframe020.i"

; divu.w #0,d0 (format 2 frame)

trap0:
	PREPARE_CPU
	CLEAR_STACK
	moveq   #1,d0
	MARK_PC
	divu.w 	#0,d0

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'FRAME020_10', 0
	even

; Reference values recorded on my stock Amiga 1200
expected020:
	dc.w   	$0007, $FEF4, $000C, $0000, $0006, $2016, $0007, $56DC
	dc.w   	$2014, $0007, $56D8, $1111, $1111, $1111, $1111, $1111
	dc.w   	$1111, $1111, $1111, $1111, $1111, $0007, $56D8, $0000
	dc.w   	$0001
