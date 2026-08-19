	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Nibble sweep for ECS super hires colour registers -- see shramp.i.
;
; Section 1 carries red nibble $D, section 2 red nibble $E. Sections 0 and 3
; are the black and full red anchors, present in every frame so each
; photograph can be normalised against itself.
;
; Nominal weights: $D is 13/15, $E is 14/15 of full red.

RAMP_A              equ $0D00
RAMP_B              equ $0E00

	include "../shramp.i"
