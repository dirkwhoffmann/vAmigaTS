	include "../trace020.i"

; bra.s (taken)
; Is a taken branch traced? (control)

trap0:
	PREPARE_CPU
	SETUP_TEST
	MARK_PC
	SET_T0
	nop                         ; Not a change of flow
	bra.s   after
	nop
after:
	END_TEST

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_3', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0001, $2024, $6700, $0012, $000E, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
