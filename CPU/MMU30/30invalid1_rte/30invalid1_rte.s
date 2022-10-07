	include "../30buserr.i"
	include "../table_short.i"

trap0:
	; Invalidate the MMU table
	move.l  rangeA_reloc,a2				
	move.l  #0,(a2)

	; Enable the MMU
	jsr 	setupTC

	; Trigger a bus error by accessing the $Axxxxx range
	jsr 	trigger
    rte

exit:	
	; Rectify the MMU table
	move.l 	rangeA_reloc,a2
	move.l  tableB_reloc,a3
	move.l	a3,(a2)
	andi.b	#$F0,$3(a2)
	ori.b	#$02,$3(a2)
	rte
	
info: 
    dc.b    '30INVALID1 (Short table, RTE recovery)', 0
	even

expected:
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0020
	dc.w   	$2010
	dc.w   	$0007
	dc.w   	$020C
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
