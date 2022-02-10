OFFSET	equ $10

IRQ1	MACRO
	move    SR,d0 ; Consume an unusual number of some cycles
	ENDM

	include "../irqbpl.i"
