SHIFT               equ $C1

MODIFY	MACRO
	dc.w    BPL1MOD, \1
	dc.w    BPL2MOD, \1
	ENDM

	include "../bplmod_cop.i"
