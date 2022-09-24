	include "../30buserr.i"
	include "../table_long.i"

trap0:
	; Invalidate the MMU table by setting an index limit
	lea 	rangeA,a2
	move.w  #$000E,(a2)

	; Enable the MMU
	jsr setupTC

	; Trigger a bus error by accessing the $Axxxxx range
	jsr trigger
    rte

exit:
	jmp continue
	
info: 
    dc.b    '30LIMIT2 (upper index violation)', 0
	even

expected:
    dc.b    $00,$00,$00,$00,$00,$5C,$20,$14,$00,$07,$01,$EA,$B0,$08,$00,$00
    dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
