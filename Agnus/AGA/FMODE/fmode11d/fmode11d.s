	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; fmode11d -- odd planes (1,3,5,7) misaligned, even planes (2,4,6,8)
; aligned. This and fmode11e are the ones that actually distinguish "planes
; 5-8 are the sensitive ones" from "the sensitive planes are exactly the
; even-numbered ones" -- fmode11b/c can't tell those apart, because {5,6,7,8}
; and {the even lores fetch slots} happen to be the same set there.
;
; Prediction under "planes 5-8 need alignment, 1-4 don't care": planes 5 and
; 7 drop (misaligned and in the sensitive half); planes 1, 3 survive
; (misaligned but not sensitive); planes 2, 4, 6, 8 all survive (aligned).
; Visible planes: 1, 2, 3, 4, 6, 8.
FMODE               equ $0003    ; Fetch mode under test
DDF_START           equ $0030
DDF_STOP_LORES      equ $0070
DDF_STOP_HIRES      equ $0080

PLANE1_MISALIGN     equ 1
PLANE3_MISALIGN     equ 1
PLANE5_MISALIGN     equ 1
PLANE7_MISALIGN     equ 1

	include "../fmode.i"
