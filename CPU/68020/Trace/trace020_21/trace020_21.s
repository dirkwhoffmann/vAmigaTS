	include "../trace020.i"

; rte to user mode with T1 and M
; Same, with the M bit set in the frame

trap0:
	PREPARE_CPU
	SETUP_TEST
	lea     user(pc),a2
	clr.w   -(a7)
	move.l  a2,-(a7)
	move.w  #$9000,-(a7)        ; SR: T1, M, user mode
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
    dc.b    'TRACE020_21', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0001, $2024, $9000, $000C, $000A, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
