	include "../stackframe.i"

trap0:
	PREPARE_STACK
		
	; Trigger an address error exception
	movea.l $0001.w,a2

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue
	
info: 
    dc.b    'ADDRERR6', 0
	even

expected000:
	dc.w   	$0007, $FFEC, $000E, $FFF8, $A8AF, $2475, $0000, $0001
	dc.w   	$2478, $2010, $0007, $5758, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected010:
	dc.w   	$0007, $FFBE, $003A, $0000, $0006, $2010, $0007, $5758
	dc.w   	$800C, $1105, $0000, $0001, $1111, $1111, $1111, $FFFF
	dc.w   	$1111, $337C, $0000, $0000, $0000, $0000

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
