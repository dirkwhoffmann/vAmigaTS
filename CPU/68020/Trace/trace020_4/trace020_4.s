	include "../trace020.i"

; beq.s (taken)
; Is a taken conditional branch traced?

trap0:
	PREPARE_CPU
	SETUP_TEST
	MARK_PC
	SET_T0
	moveq   #0,d4               ; Z = 1 (not a change of flow)
	beq.s   after
	nop
after:
	END_TEST

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_4', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0001, $2024, $6704, $0012, $000E, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
