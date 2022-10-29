NUMROWS		equ 9

	include "../stackframe.i"

trap0:
	; Save current stack pointer in A0 and PC in a6
	move.l  a7,a0
	lea     $0(pc),a6
	
	; Trigger a CHK exception
	moveq   #10,d0
	moveq   #00,d1
	chk.w   d1,d0
	rte

shouldnotreach:
	move.w  #$F00,COLOR00(a1)
	move.w  #$FF0,COLOR00(a1)
	bra 	shouldnotreach

exit:
	jmp 	continue
	
info: 
    dc.b    'STACKFRAME4 (CHK exception)', 0
	even

expected:
	dc.w   	$0007
	dc.w   	$FFF0
	dc.w   	$0008
	dc.w   	$0000
	dc.w   	$0008
	dc.w   	$2010
	dc.w   	$0007
	dc.w   	$574C
	dc.w   	$0018
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000

