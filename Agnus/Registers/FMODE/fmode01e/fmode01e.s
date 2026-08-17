	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; fmode01e -- fmode01 (FMODE=$1, BPL32 set: 32-bit fetch) with planes
; 2,4,6,8 pushed 2 bytes off their 64-bit boundary. The 64-bit alignment
; probes so far (fmode11a-o) all ran at FMODE=$3, the only mode that actually
; performs a 64-bit fetch; this repeats the same plane subsets and offset at
; FMODE=$1, which only needs 32-bit (2-word) alignment. Prediction: no effect
; -- all 8 planes visible, identical to fmode01 -- since a pointer 2 bytes
; off a 64-bit boundary is still 32-bit aligned. A different result would
; mean 32-bit fetches are pickier about pointer alignment than they appear.
FMODE               equ $0001    ; Fetch mode under test
DDF_START           equ $0030
DDF_STOP_LORES      equ $0080
DDF_STOP_HIRES      equ $0088

MISALIGN_OFFSET     equ 2        ; <-- the variable under test

PLANE2_MISALIGN     equ 1
PLANE4_MISALIGN     equ 1
PLANE6_MISALIGN     equ 1
PLANE8_MISALIGN     equ 1

	include "../fmode.i"
