	include "../trace020.i"

; move.w #$6700,sr (T0 stays set)
; Is a MOVE to SR traced when T0 was set before?

trap0:
	PREPARE_CPU
	SETUP_TEST
	MARK_PC
	SET_T0
	move.w  #$6700,sr
after:
	END_TEST

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_12', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0001, $2024, $6700, $0010, $000C, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
