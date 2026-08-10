	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

FMODE               equ $0003    ; Fetch mode under test
DDF_START           equ $0030
DDF_STOP_LORES      equ $0070
DDF_STOP_HIRES      equ $0070

; Chosen so a line fetches a whole number of 8-byte staircase periods,
; which is what keeps the picture standing still now that BPLxMOD is zero.
; Lores window confirmed on hardware at three stairs. The hires window is
; the one still being pinned down -- see the retuning note in fmode.i.

	include "../fmode.i"
