	include "../trace020.i"

; trap #2
; Is the instruction TRAP traced? (the trace follows the exception)

trap0:
	PREPARE_CPU
	SETUP_TEST
	lea     rtehandler(pc),a3
	move.l  a3,$88
	MARK_PC
	SET_T0
	trap    #2
after:
	END_TEST

	NO_EXCEPTION_GENERATED

rtehandler:
	rte

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_14', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0001, $2024, $2700, $0024, $000C, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
