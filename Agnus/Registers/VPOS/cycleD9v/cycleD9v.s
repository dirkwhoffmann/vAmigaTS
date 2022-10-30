PROBE 	MACRO
	ds.w    66,$4E71      ; NOP field
	move.w 	VPOSR(a1),d0
	ENDM

	include "../cycle.i"