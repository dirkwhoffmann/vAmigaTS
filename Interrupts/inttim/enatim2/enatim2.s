OFFSET1	equ $52
OFFSET2	equ $52
OFFSET3	equ $52

DOIRQ	MACRO
	dc.w    INTREQ,$8004
	dc.w    INTENA,$8004
	ENDM

	include "../enatim.i"
