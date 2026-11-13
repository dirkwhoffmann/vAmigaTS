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

	; Request a level 6 interrupt and wait until it is visible on the IPL pins
	move.w  #$A000,INTREQ(a1)
	moveq   #20,d0
.wait2:
	dbra    d0,.wait2

	; Lower the mask to 2. Only the level 6 interrupt must be taken
	; (A5 = 1). The pending level 5 interrupt is taken afterwards.
	stop    #$2200
	nop
	nop

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

info: 
    dc.b    'INTERRUPT3 (STOP, IRQ level changes)', 0
	even

; Recorded on real hardware
expected000:
	dc.w   	$0007, $FEFA, $0006, $0000, $0028, $2200, $0007, $5920
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0001

expected010:
	dc.w   	$0007, $FEF8, $0008, $0000, $0028, $2200, $0007, $5920
	dc.w   	$0078, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0001

expected020:
	dc.w   	$0007, $FEF8, $0008, $0000, $0028, $2200, $0007, $5920
	dc.w   	$0078, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0001

