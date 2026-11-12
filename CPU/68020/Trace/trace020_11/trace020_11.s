	include "../trace020.i"

; rts
; Is RTS traced?

trap0:
	PREPARE_CPU
	SETUP_TEST
	pea     after(pc)
	MARK_PC
	SET_T0
	nop
	rts
after:
	END_TEST

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_11', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0001, $2024, $6700, $0010, $000E, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
