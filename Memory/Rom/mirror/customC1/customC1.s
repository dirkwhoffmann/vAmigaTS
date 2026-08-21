	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Scans $C00000 to $C7FFFF for custom chip register mirrors,
; one address per raster line. Everything else lives in custom.i.

PROBE_FIRST         equ $C00180

	include "../custom.i"
