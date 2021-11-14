SHIFT               equ $C1

MODIFY	MACRO
	dc.w    BPL1PTL, 0
	dc.w    BPL2PTL, 0
	ENDM

	include "../bplptr_cop.i"
