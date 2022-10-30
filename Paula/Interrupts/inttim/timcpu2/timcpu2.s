OFFSET1	equ $28
OFFSET2	equ $28
OFFSET3	equ $28

DOIRQ	MACRO
	dc.w    INTREQ,$800C
	dc.w    INTENA,$8004
	ENDM

	include "../timcpu.i"
