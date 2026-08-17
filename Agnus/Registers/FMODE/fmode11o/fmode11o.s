	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; fmode11o -- same misaligned-plane set as fmode11e/fmode11j (planes
; 2,4,6,8), but with MISALIGN_OFFSET set to 6 instead of 4 or 2. 6 is the
; mirror image of 2 (both are 8-6=2 and plain-6 away from the nearer 64-bit
; boundary, on opposite sides of it), so if only distance-from-boundary
; matters, fmode11o should reproduce fmode11j's picture. If it instead
; matches fmode11e (offset 4) or differs from both, the offset's sign --
; which side of the boundary the pointer sits on -- matters too.
FMODE               equ $0003    ; Fetch mode under test
DDF_START           equ $0030
DDF_STOP_LORES      equ $0070
DDF_STOP_HIRES      equ $0080

MISALIGN_OFFSET     equ 6        ; <-- the variable under test (was 4, then 2)

PLANE2_MISALIGN     equ 1
PLANE4_MISALIGN     equ 1
PLANE6_MISALIGN     equ 1
PLANE8_MISALIGN     equ 1

	include "../fmode.i"
