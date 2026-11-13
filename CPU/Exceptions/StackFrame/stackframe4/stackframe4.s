SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

trap0:
	PREPARE_STACK

	; Trigger a CHK exception
	moveq   #10,d0
	moveq   #00,d1
	chk.w   d1,d0

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue
	
info: 
    dc.b    'STACKFRAME4 (CHK exception)', 0
	even

expected000:
	dc.w   	$0007, $FEFA, $0006, $0000, $0008, $2010, $0007, $57CA
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected010:
	dc.w   	$0007, $FEF8, $0008, $0000, $0008, $2010, $0007, $57CA
	dc.w   	$0018, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected020:
	dc.w   	$0007, $FEF4, $000C, $0000, $0008, $2011, $0007, $57CA
	dc.w   	$2018, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000