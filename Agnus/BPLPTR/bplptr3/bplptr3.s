SHIFT               equ $91

MODIFY1	MACRO
	move.w  a4,BPL2PTL(a1)
	move.w  a5,BPL1PTL(a1)
	ENDM

MODIFY2	MACRO
	move.w  a5,BPL2PTL(a1)
	move.w  a4,BPL1PTL(a1)
	ENDM

	include "../bplptr_cpu.i"
