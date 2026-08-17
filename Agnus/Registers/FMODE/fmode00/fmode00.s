	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Neither BPL32 nor BPAGEM: 16-bit (1 word) bitplane fetches.
FMODE               equ $0000    ; Fetch mode under test

DDF_START           equ $0030
DDF_STOP_LORES      equ $0088
DDF_STOP_HIRES      equ $0088

; Chosen so a line fetches a whole number of 8-byte staircase periods,
; which is what keeps the picture standing still now that BPLxMOD is zero.
; Three lores stairs and six hires stairs, confirmed on hardware.

	include "../fmode.i"
