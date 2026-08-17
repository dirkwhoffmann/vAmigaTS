	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; fmode11c -- the mirror of fmode11b: planes 5-8 misaligned, planes 1-4
; aligned. Not run before; this is the direct test of "only planes 5-8 are
; alignment-sensitive."
;
; Prediction: planes 5-8 drop out, planes 1-4 show -- the same picture as
; fmode11a (all misaligned), because 1-4's alignment never mattered there
; either.
FMODE               equ $0003    ; Fetch mode under test
DDF_START           equ $0030
DDF_STOP_LORES      equ $0070
DDF_STOP_HIRES      equ $0080

PLANE5_MISALIGN     equ 1
PLANE6_MISALIGN     equ 1
PLANE7_MISALIGN     equ 1
PLANE8_MISALIGN     equ 1

	include "../fmode.i"
