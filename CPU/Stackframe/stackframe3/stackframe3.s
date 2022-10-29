NUMROWS		equ 24

	include "../stackframe.i"

trap0:
	jsr 	clrstack

	; Save current stack pointer in A0 and PC in a6
	move.l  a7,a0
	lea     $0(pc),a6
	
	; Trigger an address error exception
	move.l  a1,$414243
	rte

shouldnotreach:
	move.w  #$F00,COLOR00(a1)
	move.w  #$FF0,COLOR00(a1)
	bra 	shouldnotreach

exit:
	jmp 	continue
	
info: 
    dc.b    'STACKFRAME3 (Address error)', 0
	even

expected:
	dc.w   	$0007
	dc.w   	$FFBE
	dc.w   	$003A
	dc.w   	$0000
	dc.w   	$0008
	dc.w   	$2010
	dc.w   	$0007
	dc.w   	$5750
	dc.w   	$800C
	dc.w   	$0005
	dc.w   	$0041
	dc.w   	$4243
	dc.w   	$1111
	dc.w   	$00DF
	dc.w   	$1111
	dc.w   	$4243
	dc.w   	$1111
	dc.w   	$4E73
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
