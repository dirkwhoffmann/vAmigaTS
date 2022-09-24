	include "../30buserr.i"
	include "../table_short.i"

trap0:
	; Invalidate the MMU table
	lea 	rangeA,a2
	move.l  #0,(a2)

	; Enable the MMU
	jsr 	setupTC

	; Trigger a bus error by accessing the $Axxxxx range
	jsr 	trigger
    rte

exit:	
	; Rectify the MMU table
	lea 	rangeA,a2
	lea     tableb,a3
	move.l	a3,(a2)
	andi.b	#$F0,$3(a2)
	ori.b	#$02,$3(a2)
	rte
	
info: 
    dc.b    '30INVALID1 (Short table, RTE recovery)', 0
	even

expected:
    dc.b    $00,$00,$00,$00,$00,$5C,$20,$14,$00,$07,$01,$EA,$B0,$08,$00,$00
    dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
