	include "../trace020.i"

; stop #$6000 (T0, S, M unchanged)
; Is STOP traced when it leaves T0, S and M unchanged? (vblank wakes it up)

trap0:
	PREPARE_CPU
	SETUP_TEST
	move.w  #$C020,INTENA(a1)   ; Vertical blank interrupt
	MARK_PC
	SET_T0
	nop
	stop    #$6000
after:
	END_TEST

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_18', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0000, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
