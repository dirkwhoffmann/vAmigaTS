SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

trap0:
	PREPARE_STACK

	; Trigger exception via the BKPT instruction
	bkpt	#2

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue
		
info: 
    dc.b    'STACKFRAME3 (BKPT exception)', 0
	even

expected000:
	dc.w   	$0007, $FEFA, $0006, $0000, $0002, $2010, $0007, $57C4
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected010:
	dc.w   	$0007, $FEF8, $0008, $0000, $0002, $2010, $0007, $57C4
	dc.w   	$0010, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected020:
	dc.w   	$0007, $FEF8, $0008, $0000, $0002, $2010, $0007, $57C4
	dc.w   	$0010, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000