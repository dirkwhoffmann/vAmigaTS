	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Nibble sweep for ECS super hires colour registers -- see shramp.i.
;
; Section 1 carries red nibble $1, section 2 red nibble $2. Sections 0 and 3
; are the black and full red anchors, present in every frame so each
; photograph can be normalised against itself.
;
; Nominal weights: $1 is 1/15, $2 is 2/15 of full red.

RAMP_A              equ $0100
RAMP_B              equ $0200

	include "../shramp.i"
