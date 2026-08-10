	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; BPAGEM set, BPL32 clear. The documented 64-bit fetch mode wants *both*
; bits set (see fmode11), so this combination is the odd one out and exists
; precisely to pin down what the hardware actually does with it.
FMODE               equ $0002    ; Fetch mode under test

DDF_START           equ $0030
DDF_STOP_LORES      equ $0080
DDF_STOP_HIRES      equ $0088

; Chosen so a line fetches a whole number of 8-byte staircase periods,
; which is what keeps the picture standing still now that BPLxMOD is zero.
; Windows assumed identical to fmode01. A different stair count here is
; the result this variant exists to produce.

	include "../fmode.i"
