	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; fmode11i -- same misaligned-plane set as fmode11d (planes 1,3,5,7),
; but with MISALIGN_OFFSET set to 2 instead of the default 4. Both offsets
; leave the pointer word-aligned (legal for BPLxPT); only the distance from
; the 64-bit boundary differs. If this variant reproduces fmode11d's picture
; exactly, being off a 64-bit boundary is what matters, not by how much. If
; it differs -- e.g. shows more planes than fmode11d -- the distance itself
; is significant, which a single-bit "aligned or not" model cannot explain.
FMODE               equ $0003    ; Fetch mode under test
DDF_START           equ $0030
DDF_STOP_LORES      equ $0070
DDF_STOP_HIRES      equ $0080

MISALIGN_OFFSET     equ 2        ; <-- the variable under test (was 4)

PLANE1_MISALIGN     equ 1
PLANE3_MISALIGN     equ 1
PLANE5_MISALIGN     equ 1
PLANE7_MISALIGN     equ 1

	include "../fmode.i"
