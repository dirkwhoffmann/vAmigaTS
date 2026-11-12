	include "../trace020.i"

; rte (T0, S, M unchanged)
; Is an RTE traced when T0 is set before and after it?

trap0:
	PREPARE_CPU
	SETUP_TEST
	lea     after(pc),a2
	clr.w   -(a7)               ; Format 0
	move.l  a2,-(a7)            ; Return address
	move.w  #$6700,-(a7)        ; SR: T0, S, interrupt mask 7
	MARK_PC
	SET_T0
	nop                         ; Not a change of flow
	rte
after:
	END_TEST

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_1', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0001, $2024, $6700, $0010, $000E, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
