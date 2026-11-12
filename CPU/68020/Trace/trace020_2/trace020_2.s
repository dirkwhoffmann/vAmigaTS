	include "../trace020.i"

; rte (T0 cleared by the RTE)
; Is an RTE traced when it clears T0?

trap0:
	PREPARE_CPU
	SETUP_TEST
	lea     after(pc),a2
	clr.w   -(a7)
	move.l  a2,-(a7)
	move.w  #$2700,-(a7)        ; SR: S, interrupt mask 7 (T0 cleared)
	MARK_PC
	SET_T0
	nop
	rte
after:
	END_TEST

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_2', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0001, $2024, $2700, $0010, $000E, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
