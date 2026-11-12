	include "../trace020.i"

; dbf d3,after (not taken)
; Is a DBcc that falls through traced? (must not)

trap0:
	PREPARE_CPU
	SETUP_TEST
	moveq   #0,d3
	MARK_PC
	SET_T0
	dbf     d3,after
after:
	END_TEST

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_7', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0000, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
