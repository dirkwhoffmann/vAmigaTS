FIXED_STACK equ $7FF00
	include "../stackframe020.i"

; dbra to an odd target (branch taken)

trap0:
	PREPARE_CPU
	CLEAR_STACK
	moveq   #5,d0
	MARK_PC
	dc.w 	$51C8,$0003		; dbra d0,*+5

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'FRAME020_8', 0
	even

; Reference values recorded on my stock Amiga 1200
expected020:
	dc.w   	$0007, $FEA4, $005C, $0000, $0002, $2010, $0007, $56D8
	dc.w   	$B00C, $FEAC, $3005, $48E7, $2002, $0007, $56DC, $0007
	dc.w   	$56DC, $0000, $1111, $51C8, $51C8, $0007, $0144, $0000
	dc.w   	$0004
