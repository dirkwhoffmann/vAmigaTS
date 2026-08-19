	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Nibble sweep for ECS super hires colour registers -- see shramp.i.
;
; Section 1 carries red nibble $7, section 2 red nibble $8. Sections 0 and 3
; are the black and full red anchors, present in every frame so each
; photograph can be normalised against itself.
;
; Nominal weights: $7 is 7/15, $8 is 8/15 of full red.

RAMP_A              equ $0700
RAMP_B              equ $0800

	include "../shramp.i"
