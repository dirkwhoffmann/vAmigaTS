SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../interrupt.i"

trap0:
	PREPARE_STACK

	; A level 3 interrupt is pending, but masked by SR (mask 7)
	move.w  #$C010,INTENA(a1)
	move.w  #$8010,INTREQ(a1)
	moveq   #20,d0
.wait:
	dbra    d0,.wait

	; Lower the mask. The interrupt is taken right after this instruction.
	; The stacked PC has to point to the first NOP (not behind it).
	move.w  #$2000,sr
	nop
	nop
	nop

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'INTERRUPT1 (Stacked PC of an interrupt)', 0
	even

; Recorded on real hardware
expected000:
	dc.w   	$0007, $FEFA, $0006, $0000, $0010, $2010, $0007, $5908
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected010:
	dc.w   	$0007, $FEF8, $0008, $0000, $0010, $2010, $0007, $5908
	dc.w   	$006C, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected020:
	dc.w   	$0007, $FEF8, $0008, $0000, $0010, $2010, $0007, $5908
	dc.w   	$006C, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

