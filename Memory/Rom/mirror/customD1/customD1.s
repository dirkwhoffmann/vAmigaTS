	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Scans $D00000 to $D7FFFF for custom chip register mirrors,
; one address per raster line. Everything else lives in custom.i.

PROBE_FIRST         equ $D00180

	include "../custom.i"
