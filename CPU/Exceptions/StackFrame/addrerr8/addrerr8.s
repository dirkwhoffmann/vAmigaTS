SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

trap0:
	PREPARE_STACK
		
	; Trigger an address error exception
	move.l  #$41424647,a2
	move.l  #$20212223,d2
	move.l  #$40414243,d4
	move.l  #$30313233,d3
	movem.l	d2-d4,-(a2)

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue
	
info: 
    dc.b    'ADDRERR8', 0
	even

expected000:
	dc.w   	$0007, $FEF2, $000E, $413A, $EE83, $48E5, $4142, $4645
	dc.w   	$48E2, $2010, $0007, $57E2, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected010:
	dc.w   	$0007, $FEC6, $003A, $0000, $0020, $2010, $0007, $57E2
	dc.w   	$800C, $0005, $4142, $4645, $1111, $4243, $1111, $3800
	dc.w   	$1111, $337C, $0000, $0000, $0000, $0000

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
