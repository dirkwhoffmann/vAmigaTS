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
   dc.w    $0000 ; 1
    dc.w    $0000 ; 2
    dc.w    $0020 ; 3
    dc.w    $2010 ; 4
    dc.w    $0007 ; 5
    dc.w    $0202 ; 6
    dc.w    $A008 ; 7
    dc.w    $0000 ; 8
    dc.w    $0000 ; 9
    dc.w    $0000 ; 10
    dc.w    $0000 ; 11
    dc.w    $0000 ; 12
    dc.w    $0000 ; 13
    dc.w    $0000 ; 14
    dc.w    $0000 ; 15
    dc.w    $0000 ; 16
