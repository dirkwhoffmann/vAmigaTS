SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../interrupt.i"

trap0:
	PREPARE_STACK

	; A level 5 interrupt is pending, but masked by SR (mask 6)
	move.w  #$E800,INTENA(a1)
	move.w  #$8800,INTREQ(a1)
	move.w  #$2600,sr
	moveq   #20,d0
.wait:
	dbra    d0,.wait

	; Request a level 6 interrupt in the very last instruction before STOP.
	; The question is which level the CPU sees when STOP lowers the mask:
	; Only level 6 (A4 = 0, A5 = 1) or level 5 first (A4 = 1, A5 = 1).
	move.w  #$A000,INTREQ(a1)
	stop    #$2200
	nop
	nop

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'INTERRUPT4 (IPL change before STOP)', 0
	even

; Recorded on real hardware
expected000:
	dc.w   	$0007, $FEFA, $0006, $0000, $0022, $2200, $0007, $591A
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0001

expected010:
	dc.w   	$0007, $FEF8, $0008, $0000, $0022, $2200, $0007, $591A
	dc.w   	$0078, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0001

expected020:
	dc.w   	$0007, $FEF0, $0010, $FFFF, $AA26, $2500, $0007, $031E
	dc.w   	$0078, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0001

