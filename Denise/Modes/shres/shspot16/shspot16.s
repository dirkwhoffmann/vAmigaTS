	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Super hires colour register probe -- see shspot.i. The whole family shares
; one bitmap; only the palette differs from test to test.
;
; COLOR16 is out of reach for two bitplanes -- bit 4 of the index can
; only come from bitplane 5. This test is the negative control: it should
; show no yellow anywhere.

SPOT_REG            equ 16

	include "../shspot.i"
