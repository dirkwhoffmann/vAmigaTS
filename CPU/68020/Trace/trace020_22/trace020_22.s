	include "../trace020.i"

; rte to user mode with T1, interrupt pending
; Interrupt taken right after an RTE that sets T1: where does the trace happen?

trap0:
	PREPARE_CPU
	SETUP_TEST
	move.w  #$C020,INTENA(a1)
	lea     user(pc),a2
	clr.w   -(a7)
	move.l  a2,-(a7)
	move.w  #$8000,-(a7)        ; SR: T1, user mode, interrupt mask 0
	MARK_PC
	move.w  #$8020,INTREQ(a1)   ; Vertical blank request (masked by the current SR)
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
    dc.b    'TRACE020_22', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0001, $2024, $8000, $0012, $0010, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
