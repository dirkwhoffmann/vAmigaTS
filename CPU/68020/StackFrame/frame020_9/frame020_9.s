FIXED_STACK equ $7FF00
	include "../stackframe020.i"

; trap #1 with an odd stack pointer

trap0:
	PREPARE_CPU
	CLEAR_STACK
	subq.l  #1,a7
	MARK_PC
	trap 	#1

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'FRAME020_9', 0
	even

; Reference values recorded on my stock Amiga 1200
expected020:
	dc.w   	$0007, $FEF7, $0008, $0000, $0004, $2010, $0007, $56DA
	dc.w   	$0084, $1111, $1111, $1111, $1111, $1111, $1111, $1111
	dc.w   	$1111, $1111, $1111, $1111, $1111, $56DA, $0084, $0000
	dc.w   	$0008
