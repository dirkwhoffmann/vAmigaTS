OFFSET1	equ $8
OFFSET2	equ $A
OFFSET3	equ $C

DOIRQ	MACRO
	dc.w    INTREQ,$8004
	dc.w    INTENA,$8004
	ENDM

	include "../enatim.i"
