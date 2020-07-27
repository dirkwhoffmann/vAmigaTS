	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
MAIN:	

    ; Read test register (lo byte in d0, hi byte in d1)
	lea     CUSTOM,a1
	move.w  SERDATR(a1),d1
	move.b  d1,d0
	asr     #8,d1

	jsr init
.mainLoop:
	bra.b	.mainLoop

irq3:
	move.w  #$0020,INTREQ(a1)   ; Acknowledge
	jsr     coppersetup         ; Update Copper list
	rte

copper:	

	include "../copperlist.s"
	dc.l	$fffffffe

	include "../init.s"
	