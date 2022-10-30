	include "../stackframe.i"

trap0:
	PREPARE_STACK

	; Trigger an exception on the 68010 by manipulating the stack frame type
	move.w  #$2000,$6(a7)
	rte
rectify:
	move.w  #$0000,$6(a7)	; Rectify the frame stack type 
	rte 					; Return without causing an exception

	NO_EXCEPTION_GENERATED

exit:
	sub.l  #$0002,$2(a7)	; Modify PC such that RTE returns to 'rectify:'
	rte 					
	
info: 
    dc.b    'STACKFRAME2 (RTE format error on 68010)', 0
	even

expected000:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected010:
	dc.w   	$0007, $FFF0, $0008, $0000, $0008, $2011, $0007, $575A
	dc.w   	$0038, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
