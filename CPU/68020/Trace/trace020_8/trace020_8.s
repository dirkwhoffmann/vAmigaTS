	include "../trace020.i"

; jmp after(pc)
; Is JMP traced?

trap0:
	PREPARE_CPU
	SETUP_TEST
	MARK_PC
	SET_T0
	jmp     after(pc)
after:
	END_TEST

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_8', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0001, $2024, $6700, $0010, $000C, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
