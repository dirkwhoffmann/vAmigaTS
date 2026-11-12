	include "../trace020.i"

; stop #$2000 (T0 cleared by the STOP)
; Is STOP traced when it clears T0? (vblank wakes it up)

trap0:
	PREPARE_CPU
	SETUP_TEST
	move.w  #$C020,INTENA(a1)
	MARK_PC
	SET_T0
	nop
	stop    #$2000
after:
	END_TEST

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_19', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0000, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
