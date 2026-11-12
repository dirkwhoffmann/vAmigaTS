	include "../trace020.i"

; rte to user mode with T1
; Where does the trace happen after an RTE that sets T1?

trap0:
	PREPARE_CPU
	SETUP_TEST
	lea     user(pc),a2
	clr.w   -(a7)
	move.l  a2,-(a7)
	move.w  #$8000,-(a7)        ; SR: T1, user mode
	MARK_PC
	rte
user:
	nop
	nop
	bra.s   after
after:
	END_TEST

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_20', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0001, $2024, $8000, $000C, $000A, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
