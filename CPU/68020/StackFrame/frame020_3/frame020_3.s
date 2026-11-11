FIXED_STACK equ $7FF00
	include "../stackframe020.i"

; jmp (4,a4,d0.l*4), indexed with scale, the effective address is odd

trap0:
	PREPARE_CPU
	CLEAR_STACK
	move.l  #$40001,a4
	moveq   #3,d0
	MARK_PC
	dc.w 	$4EF4,$0C04		; jmp (4,a4,d0.l*4)

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'FRAME020_3', 0
	even

; Reference values recorded on my stock Amiga 1200
expected020:
	dc.w   	$0007, $FEA4, $005C, $0000, $0002, $2010, $0007, $56DE
	dc.w   	$B00C, $FEEC, $3005, $13FC, $007F, $0007, $56E0, $0004
	dc.w   	$0011, $0000, $1111, $4EF4, $4EF4, $0004, $000D, $0000
	dc.w   	$0003
