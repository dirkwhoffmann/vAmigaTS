	include "../stackframe.i"

trap0:
	PREPARE_STACK
		
	; Trigger an address error exception
	move.l  #$41424647,a2
	move.l  #$20212223,d2
	move.l  #$40414243,d4
	move.l  #$30313233,d3
	movem.l	d2-d4,(a2)

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue
	
info: 
    dc.b    'ADDRERR7', 0
	even

expected000:
	dc.w   	$0007, $FFEC, $000E, $413A, $EEF5, $48C5, $4142, $4647
	dc.w   	$48D2, $2010, $0007, $5772, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected010:
	dc.w   	$0007, $FFBE, $003A, $0000, $0020, $2010, $0007, $5772
	dc.w   	$800C, $0005, $4142, $4647, $1111, $2021, $1111, $001C
	dc.w   	$1111, $337C, $0000, $0000, $0000, $0000

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
