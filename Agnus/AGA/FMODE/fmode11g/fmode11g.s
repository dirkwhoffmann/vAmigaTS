	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; fmode11g -- same misaligned-plane set as fmode11b (planes 1,2,3,4),
; but with MISALIGN_OFFSET set to 2 instead of the default 4. Both offsets
; leave the pointer word-aligned (legal for BPLxPT); only the distance from
; the 64-bit boundary differs. If this variant reproduces fmode11b's picture
; exactly, being off a 64-bit boundary is what matters, not by how much. If
; it differs -- e.g. shows more planes than fmode11b -- the distance itself
; is significant, which a single-bit "aligned or not" model cannot explain.
FMODE               equ $0003    ; Fetch mode under test
DDF_START           equ $0030
DDF_STOP_LORES      equ $0070
DDF_STOP_HIRES      equ $0080

MISALIGN_OFFSET     equ 2        ; <-- the variable under test (was 4)

PLANE1_MISALIGN     equ 1
PLANE2_MISALIGN     equ 1
PLANE3_MISALIGN     equ 1
PLANE4_MISALIGN     equ 1

	include "../fmode.i"
