ABSOLUTE_PC equ 1
FIXED_STACK equ $7FF00
	include "../stackframe020.i"

; jsr (a4) with an odd address in A4

trap0:
	PREPARE_CPU
	CLEAR_STACK
	move.l  #$40001,a4
	MARK_PC
	jsr 	(a4)

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'FRAME020_4', 0
	even

; Reference values recorded on my stock Amiga 1200
expected020:
	dc.w   	$0007, $FEA0, $0060, $0007, $56DA, $2010, $0007, $56DA
	dc.w   	$B00C, $FC28, $3005, $0096, $337C, $0007, $56DC, $0007
	dc.w   	$FEFC, $0007, $56DC, $4E94, $4E94, $1111, $1111, $0000
	dc.w   	$0008
