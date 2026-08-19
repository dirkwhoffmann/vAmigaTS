	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Nibble sweep for ECS super hires colour registers -- see shramp.i.
;
; Section 1 carries red nibble $B, section 2 red nibble $C. Sections 0 and 3
; are the black and full red anchors, present in every frame so each
; photograph can be normalised against itself.
;
; Nominal weights: $B is 11/15, $C is 12/15 of full red.

RAMP_A              equ $0B00
RAMP_B              equ $0C00

	include "../shramp.i"
