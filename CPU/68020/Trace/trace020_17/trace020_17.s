	include "../trace020.i"

; divu.w #0,d1
; Is a division by zero traced?

trap0:
	PREPARE_CPU
	SETUP_TEST
	lea     rtehandler(pc),a3
	move.l  a3,$14
	moveq   #1,d1
	MARK_PC
	SET_T0
	divu.w  #0,d1
after:
	END_TEST

	NO_EXCEPTION_GENERATED

rtehandler:
	rte

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_17', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0001, $2024, $2706, $0026, $000C, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
