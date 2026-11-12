	include "../trace020.i"

; jsr sub(pc)
; Is JSR traced?

trap0:
	PREPARE_CPU
	SETUP_TEST
	MARK_PC
	SET_T0
	jsr     sub(pc)
	bra.s   after
sub:
	rts
after:
	END_TEST

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'TRACE020_9', 0
	even

; Values recorded on a stock Amiga 1200
expected020:
	dc.w   	$0001, $2024, $6700, $0012, $000C, $FFFF, $FFFF, $FFFF
	dc.w   	$FFFF
