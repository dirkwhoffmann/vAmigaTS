	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Super hires colour index readout -- see shindex.i.
;
; Sixteen flat sections, one per pair of alternating pixel values. This test
; colours every register whose bit 1 is set yellow, and the rest blue, so the
; sections that come out yellow are exactly those whose colour index has
; bit 1 set. Five tests give five bits and name the index outright.

INDEX_BIT           equ 1

	include "../shindex.i"
