	include "../30buserr.i"
	include "../table_long.i"

trap0:
	; Set write protection flag
	lea 	rangeA,a2
	ori.b   #$04,$3(a2)		; Enable write protection

	; Enable the MMU
	jsr 	setupTC

	; Trigger a bus error by accessing the $Axxxxx range
	jsr 	trigger
    rte

exit:
	jmp 	continue

info: 
    dc.b    '30WP1 Long (JMP recovery)', 0
	even

expected:
    dc.b    $00,$00,$00,$00,$00,$5C,$20,$14,$00,$07,$01,$EA,$B0,$08,$00,$00
    dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
