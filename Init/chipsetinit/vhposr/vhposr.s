	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
MAIN:	

	jsr init
.mainLoop:
	bra.b	.mainLoop

irq3:
    ; Read test register (lo byte in d0, hi byte in d1)
	move.w  VHPOSR(a1),d1
	move.b  d1,d0
	asr     #8,d1

	move.w  #$0020,INTREQ(a1)   ; Acknowledge
	jsr     coppersetup         ; Update Copper list
	rte

copper:	

	include "../copperlist.s"
	dc.l	$fffffffe

	include "../init.s"
	