FIXED_STACK equ $7FF00
	include "../stackframe020.i"

; bsr.w to an odd target

trap0:
	PREPARE_CPU
	CLEAR_STACK
	MARK_PC
	dc.w 	$6100,$0003		; bsr.w *+5

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'FRAME020_5', 0
	even

; Reference values recorded on my stock Amiga 1200
expected020:
	dc.w   	$0007, $FEA0, $0060, $0000, $0002, $2010, $0007, $56D6
	dc.w   	$B00C, $CC28, $2005, $2A48, $337C, $0007, $56D8, $0007
	dc.w   	$FEFC, $0007, $56DA, $6100, $6100, $1111, $1111, $0000
	dc.w   	$0008
