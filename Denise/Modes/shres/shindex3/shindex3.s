	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Super hires colour index readout -- see shindex.i.
;
; Sixteen flat sections, one per pair of alternating pixel values. This test
; colours every register whose bit 2 is set yellow, and the rest blue, so the
; sections that come out yellow are exactly those whose colour index has
; bit 2 set. Five tests give five bits and name the index outright.

INDEX_BIT           equ 2

	include "../shindex.i"
