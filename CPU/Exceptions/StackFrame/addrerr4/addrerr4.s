	include "../stackframe.i"

trap0:
	PREPARE_STACK
		
	; Trigger an address error exception
	move.l  #$41424647,a2
	move.w  #$68,-(a2)

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue
	
info: 
    dc.b    'ADDRERR4', 0
	even

expected000:
	dc.w   	$0007, $FFEC, $000E, $413A, $EEF3, $3365, $4142, $4645
	dc.w   	$337C, $2010, $0007, $5760, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected010:
	dc.w   	$0007, $FFBE, $003A, $0000, $000E, $2010, $0007, $5760
	dc.w   	$800C, $0005, $4142, $4645, $1111, $0068, $1111, $7FFF
	dc.w   	$1111, $7FFF, $0000, $0000, $0000, $0000

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
