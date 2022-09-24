	include "../30buserr.i"
	include "../table_short.i"

trap0:
	; Invalidate the MMU table
	lea 	rangeAF,a2
	move.l  #0,(a2)

	; Enable the MMU
	jsr setupTC

	; Trigger a bus error by accessing the $Axxxxx range
	jsr trigger
    rte

exit:
	jmp continue

info: 
    dc.b    '30INVALID2 (Short table, JMP recovery)', 0
	even

expected:
    dc.b    $00,$00,$00,$00,$00,$5C,$20,$14,$00,$07,$01,$EA,$B0,$08,$00,$00
    dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
