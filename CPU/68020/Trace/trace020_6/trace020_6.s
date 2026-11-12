	include "../trace020.i"

; dbf d3,after (taken)
; Is a taken DBcc traced?

trap0:
	PREPARE_CPU
	SETUP_TEST
	moveq   #1,d3
	MARK_PC
	SET_T0
	dbf     d3,after
after:
	END_TEST

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_6', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0001, $2024, $6700, $0010, $000C, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
