	include "../trace020.i"

; illegal
; Is an illegal instruction traced? (must not)

trap0:
	PREPARE_CPU
	SETUP_TEST
	lea     skiphandler(pc),a3
	move.l  a3,$10
	MARK_PC
	SET_T0
	illegal
after:
	END_TEST

	NO_EXCEPTION_GENERATED

skiphandler:
	addq.l  #2,2(a7)            ; Skip the instruction
	rte

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_15', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0000, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
