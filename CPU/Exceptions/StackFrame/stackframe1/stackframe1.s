	include "../stackframe.i"

trap0:
	PREPARE_STACK

	; Trigger an exception on the 68000, 68010, and 68020
	movec   MMUSR,d6

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue
	
info: 
    dc.b    'STACKFRAME1 (Illegal instruction)', 0
	even

expected000:
	dc.w   	$0007, $FFF4, $0006, $0000, $0002, $2010, $0007, $57B6
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected010:
	dc.w   	$0007, $FFF0, $0008, $0000, $0002, $2010, $0007, $57B6
	dc.w   	$0010, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
