	include "../trace020.i"

; bne.s (not taken)
; Is a branch that is not taken traced? (must not)

trap0:
	PREPARE_CPU
	SETUP_TEST
	MARK_PC
	SET_T0
	moveq   #0,d4               ; Z = 1
	bne.s   after
	nop
after:
	END_TEST

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_5', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0000, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
