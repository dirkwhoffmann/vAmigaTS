	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Scans $E80000 to $EFFFFF for custom chip register mirrors,
; one address per raster line. Everything else lives in custom.i.

PROBE_FIRST         equ $E80180

	include "../custom.i"
