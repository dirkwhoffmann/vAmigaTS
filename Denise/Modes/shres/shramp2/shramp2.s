	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Nibble sweep for ECS super hires colour registers -- see shramp.i.
;
; Section 1 carries red nibble $3, section 2 red nibble $4. Sections 0 and 3
; are the black and full red anchors, present in every frame so each
; photograph can be normalised against itself.
;
; Nominal weights: $3 is 3/15, $4 is 4/15 of full red.

RAMP_A              equ $0300
RAMP_B              equ $0400

	include "../shramp.i"
