	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Scans $E00000 to $E7FFFF for custom chip register mirrors,
; one address per raster line. Everything else lives in custom.i.

PROBE_FIRST         equ $E00180

	include "../custom.i"
