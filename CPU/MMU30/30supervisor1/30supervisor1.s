	include "../30buserr.i"
	include "../table_long.i"

trap0:
	; Set supervisor flag
	lea 	rangeA,a2
	ori.b   #$01,$2(a2)

	; Enable the MMU
	jsr 	setupTC

	; Trigger a bus error by accessing the $Axxxxx range in user mode
	jsr 	trigger_usermode
    rte

exit:
	jmp 	continue

info: 
    dc.b    '30SUPERVISOR1 (JMP recovery)', 0
	even

expected:
    dc.b    $00,$00,$00,$00,$00,$5C,$00,$00,$00,$07,$02,$00,$B0,$08,$00,$00
    dc.b    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
