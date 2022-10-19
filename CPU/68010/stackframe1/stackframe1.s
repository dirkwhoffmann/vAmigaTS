	include "../stackframe.i"

trap0:
	; Save current stack pointer in A0
	move.l  a7,a0

	; Trigger an exception on the 68000 and 68010
	movec   CACR,d6

	; If we reach this line, we have at least a 68020
    rte

exit:
	jmp 	continue
	
info: 
    dc.b    'STACKFRAME1', 0
	even

expected:
	dc.w   	$0008
	dc.w   	$2010
	dc.w   	$0007
	dc.w   	$5316
	dc.w   	$0010
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
