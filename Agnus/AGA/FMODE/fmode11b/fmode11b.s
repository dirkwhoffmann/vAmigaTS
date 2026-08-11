	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; fmode11b -- planes 1-4 misaligned, planes 5-8 aligned. Already run once as
; the earlier fmode11c: on hardware all 8 planes showed up, meaning a
; misaligned pointer costs a plane only planes 5-8, never planes 1-4 --
; alignment of the lower half does not matter.
;
; Prediction from that rule: all 8 planes visible, same as fmode11.
FMODE               equ $0003    ; Fetch mode under test
DDF_START           equ $0030
DDF_STOP_LORES      equ $0070
DDF_STOP_HIRES      equ $0080

PLANE1_MISALIGN     equ 1
PLANE2_MISALIGN     equ 1
PLANE3_MISALIGN     equ 1
PLANE4_MISALIGN     equ 1

	include "../fmode.i"
