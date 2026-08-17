	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; fmode11a -- all eight planes misaligned. This was the original, accidental
; state of fmode11 before its buffers were forced 64-bit aligned: on real
; hardware it showed only planes 1-4, with 5-8 dropping out entirely.
FMODE               equ $0003    ; Fetch mode under test
DDF_START           equ $0030
DDF_STOP_LORES      equ $0070
DDF_STOP_HIRES      equ $0080

PLANE1_MISALIGN     equ 1
PLANE2_MISALIGN     equ 1
PLANE3_MISALIGN     equ 1
PLANE4_MISALIGN     equ 1
PLANE5_MISALIGN     equ 1
PLANE6_MISALIGN     equ 1
PLANE7_MISALIGN     equ 1
PLANE8_MISALIGN     equ 1

	include "../fmode.i"
