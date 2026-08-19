	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Nibble sweep for ECS super hires colour registers -- see shramp.i.
;
; Section 1 carries red nibble $9, section 2 red nibble $A. Sections 0 and 3
; are the black and full red anchors, present in every frame so each
; photograph can be normalised against itself.
;
; Nominal weights: $9 is 9/15, $A is 10/15 of full red.

RAMP_A              equ $0900
RAMP_B              equ $0A00

	include "../shramp.i"
