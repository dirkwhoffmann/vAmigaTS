SHIFT               equ $91

MODIFY1	MACRO
	move.w  #2,BPL1MOD(a1)
	move.w  #2,BPL2MOD(a1)
	ENDM

MODIFY2	MACRO
	move.w  #0,BPL1MOD(a1)
	move.w  #0,BPL2MOD(a1)
	ENDM

	include "../bplmod_cpu.i"
