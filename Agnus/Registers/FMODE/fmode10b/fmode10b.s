	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; fmode10b -- fmode10 (FMODE=$2, BPAGEM set, BPL32 clear: the undocumented
; 32-bit fetch variant) with planes 1,2,3,4 pushed 2 bytes off
; their 64-bit boundary. fmode01a-e already ran this probe for the
; documented 32-bit mode (FMODE=$1, BPL32); this repeats the same plane
; subsets and offset for fmode10, which performs the same 2-word fetch
; through a different, undocumented bit combination. Prediction: same
; result as the corresponding fmode01 variant, since alignment sensitivity
; should depend on fetch width, not on which FMODE bit selects it. A
; different result would mean BPAGEM's fetch path handles pointer
; alignment differently from BPL32's.
FMODE               equ $0002    ; Fetch mode under test
DDF_START           equ $0030
DDF_STOP_LORES      equ $0080
DDF_STOP_HIRES      equ $0088

MISALIGN_OFFSET     equ 2        ; <-- the variable under test

PLANE1_MISALIGN     equ 1
PLANE2_MISALIGN     equ 1
PLANE3_MISALIGN     equ 1
PLANE4_MISALIGN     equ 1

	include "../fmode.i"
