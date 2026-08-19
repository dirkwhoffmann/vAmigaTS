	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Nibble sweep for ECS super hires colour registers -- see shramp.i.
;
; Section 1 carries red nibble $5, section 2 red nibble $6. Sections 0 and 3
; are the black and full red anchors, present in every frame so each
; photograph can be normalised against itself.
;
; Nominal weights: $5 is 5/15, $6 is 6/15 of full red.

RAMP_A              equ $0500
RAMP_B              equ $0600

	include "../shramp.i"
