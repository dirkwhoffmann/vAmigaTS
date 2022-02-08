PROBE 	MACRO
	ds.w    68,$4E71      ; NOP field
	move.w 	VHPOSR(a1),d0
	ENDM

	include "../cycle.i"