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
 	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0020
	dc.w   	$2010
	dc.w   	$0007
	dc.w   	$0202
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