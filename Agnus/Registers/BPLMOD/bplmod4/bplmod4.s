SHIFT               equ $91

MODIFY1	MACRO
	move.l  #$00020002,BPL1MOD(a1)
	ENDM

MODIFY2	MACRO
	move.l  #$00000000,BPL1MOD(a1)
	ENDM

	include "../bplmod_cpu.i"
