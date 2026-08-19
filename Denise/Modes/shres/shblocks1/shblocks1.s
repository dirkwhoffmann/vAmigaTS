	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Super hires with up to two bitplanes, ECS Denise. Same body as the
; shpattern family (see shpattern.i), but where those tests toggle their
; planes every pixel or two, this one holds one plane constant and toggles
; the other in blocks that grow: runs of 1, 2, 3 and 4 pixels.
;
; That matters because ECS super hires builds a colour index from PAIRS of
; adjacent pixels. Inside a run of 4 both pixels of a pair always agree, so
; the index there is unambiguous whatever the pairing phase turns out to
; be; a run of 1 always straddles a pair boundary; and the odd run of 3
; pins the phase down, because it must break differently depending on
; which boundary the pairs sit on.
;
; This variant: bitplane 1 held at 1, bitplane 2 carries the blocks.
;
; The fill words are given whole rather than as bytes because a one word
; period is the longest that tiles a super hires line without shearing.
; $4C3C = %0100110000111100, whose cyclic runs are 1,2,2,4,4,3.

RULER_WORD          equ $FFFF          ; bitplane 1
SOLID_WORD          equ $4C3C          ; bitplane 2

	include "../shpattern.i"
