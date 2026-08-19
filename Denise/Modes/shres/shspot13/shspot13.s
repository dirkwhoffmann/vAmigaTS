	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Super hires colour register probe -- see shspot.i. The whole family shares
; one bitmap; only the palette differs from test to test.
;
; Lights COLOR13 yellow; every other register is blue, except
; COLOR00 which stays black.

SPOT_REG            equ 13

	include "../shspot.i"
