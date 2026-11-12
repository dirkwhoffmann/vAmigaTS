	include "../trace020.i"

; chk.w #0,d1 (traps)
; Is CHK traced when it takes the exception?

trap0:
	PREPARE_CPU
	SETUP_TEST
	lea     rtehandler(pc),a3
	move.l  a3,$18
	moveq   #-1,d1
	MARK_PC
	SET_T0
	chk.w   #0,d1
after:
	END_TEST

	NO_EXCEPTION_GENERATED

rtehandler:
	rte

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_16', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0001, $2024, $2709, $0026, $000C, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
