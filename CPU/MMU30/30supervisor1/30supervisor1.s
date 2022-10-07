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
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0020
	dc.w   	$0000
	dc.w   	$0007
	dc.w   	$0218
	dc.w   	$A008
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000