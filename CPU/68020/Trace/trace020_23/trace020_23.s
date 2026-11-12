	include "../trace020.i"

; same with the M bit
; Same, with the M bit set in the frame

trap0:
	PREPARE_CPU
	SETUP_TEST
	move.w  #$C020,INTENA(a1)
	lea     user(pc),a2
	clr.w   -(a7)
	move.l  a2,-(a7)
	move.w  #$9000,-(a7)        ; SR: T1, M, user mode, interrupt mask 0
	MARK_PC
	move.w  #$8020,INTREQ(a1)
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
    dc.b    'TRACE020_23', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0001, $2024, $9000, $0012, $0010, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
