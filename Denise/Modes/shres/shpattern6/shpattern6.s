	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Super hires (BPLCON0 bit 6) with up to two bitplanes -- an ECS Denise
; feature, so nothing AGA is used here. See shpattern.i.
;
; RULER_BYTE is chosen for what it does at PAIR granularity, because that
; is the granularity ECS super hires works at: successive plane 1 bit pairs
; map to colour indices 00->0, 10->1, 01->4, 11->5, and this byte's four
; pairs come out as
;
;     1,4,1,4    alternating
;
; Bytes that are merely phase shifts of one another collapse to the same
; super hires picture, so the family varies this word instead of the phase.

RULER_BYTE          equ %10011001
SOLID_BYTE          equ %10101010

	include "../shpattern.i"
