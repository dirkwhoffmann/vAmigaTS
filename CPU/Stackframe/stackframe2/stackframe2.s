NUMROWS		equ 9

	include "../stackframe.i"

trap0:
	; Save current stack pointer in A0 and PC in a6
	move.l  a7,a0
	lea     $0(pc),a6

	; Trigger an exception on the 68010 by manipulating the stack frame type
	move.w  #$2000,$6(a7)
	rte
	move.w  #$0000,$6(a7)	; Rectify frame stack type 
	rte 					; Return without causing an exception

exit:
	jmp 	continue
	
info: 
    dc.b    'STACKFRAME2 (RTE format error)', 0
	even

expected:
	dc.w   	$0007
	dc.w   	$FFF0
	dc.w   	$0008
	dc.w   	$0000
	dc.w   	$0008
	dc.w   	$2011
	dc.w   	$0007
	dc.w   	$574C
	dc.w   	$0038
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
