	include "../stackframe.i"

trap0:
	PREPARE_STACK
		
	; Trigger an address error exception
	move.l  #$31323435,d0
	move.w  d0,$414243

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue
	
info: 
    dc.b    'ADDRERR1', 0
	even

expected000:
	dc.w   	$0007, $FFEC, $000E, $0039, $EAF1, $33C5, $0041, $4243
	dc.w   	$33C0, $2010, $0007, $5760, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected010:
	dc.w   	$0007, $FFBE, $003A, $0000, $000E, $2010, $0007, $5760
	dc.w   	$800C, $0005, $0041, $4243, $1111, $3435, $1111, $4243
	dc.w   	$1111, $337C, $0000, $0000, $0000, $0000

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
