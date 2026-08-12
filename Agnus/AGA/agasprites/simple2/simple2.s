	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; All four sprites are placed at this horizontal position, so their left
; edges line up and only their width differs.
SPR_HSTART          equ 160

	include "../spres.i"
