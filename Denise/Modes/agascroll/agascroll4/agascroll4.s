	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; DDFSTRT is the parameter under test: $38 + 4, mirroring simple4 from
; Denise/Registers/BPLCON1. At FMODE = $3 a fetch spans 8 color clocks, so
; this series walks DDFSTRT across a whole 64-bit fetch unit and a bit
; beyond it.
DDF_START           equ $003C

	include "../agascroll.i"
