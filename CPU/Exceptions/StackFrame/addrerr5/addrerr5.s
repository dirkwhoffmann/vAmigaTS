SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

trap0:
	PREPARE_STACK
		
	; Trigger an address error exception
	move.l  #$41424647,a2
	move.w  #$68,$42(a2)

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue
	
info: 
    dc.b    'ADDRERR5', 0
	even

expected000:
	dc.w   	$0007, $FEF2, $000E, $413A, $EEC7, $3565, $4142, $4689
	dc.w   	$357C, $2010, $0007, $57D0, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected010:
	dc.w   	$0007, $FEC6, $003A, $0000, $000E, $2010, $0007, $57D0
	dc.w   	$800C, $0005, $4142, $4689, $1111, $0068, $1111, $0042
	dc.w   	$1111, $337C, $0000, $0000, $0000, $0000

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
