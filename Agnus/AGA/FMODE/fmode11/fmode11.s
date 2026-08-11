	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; fmode11 -- the standard case: all eight bitplane buffers 64-bit aligned,
; as PLANEk_MISALIGN's default of 0 already gives. This is the baseline the
; five sibling variants (fmode11a-e) are compared against, each misaligning
; a different subset of the eight planes and nothing else.
FMODE               equ $0003    ; Fetch mode under test
DDF_START           equ $0030
DDF_STOP_LORES      equ $0070    ; 3 lores stairs
DDF_STOP_HIRES      equ $0080    ; 6 hires stairs

; All eight PLANEk_MISALIGN flags default to 0 -- nothing to set here.

	include "../fmode.i"
