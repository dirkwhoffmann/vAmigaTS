	include "../stackframe.i"

trap0:
	jsr 	clrstack

	; Save current stack pointer in A0 and PC in a6
	move.l  a7,a0
	lea     $0(pc),a6
		
	; Trigger exception
	bkpt	#2
	rte

shouldnotreach:
	move.w  #$F00,COLOR00(a1)
	move.w  #$FF0,COLOR00(a1)
	bra 	shouldnotreach

exit:
	jmp 	continue
	
info: 
    dc.b    'STACKFRAME8 (BKPT)', 0
	even

expected:
	dc.w   	$0007
	dc.w   	$FFF0
	dc.w   	$0008
	dc.w   	$0000
	dc.w   	$0002
	dc.w   	$2010
	dc.w   	$0007
	dc.w   	$574A
	dc.w   	$0010
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
