	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; The shindex sweep repeated with a SINGLE bitplane -- see shindex.i.
;
; With two bitplanes the colour index is the two bit pixel value replicated,
; index = 5 * v, reaching COLOR00/05/10/15. What one bitplane does is a
; separate question: Denise/Modes/shres/shres00 paints its one plane super
; hires band red, i.e. COLOR01, where a replicated single bit would give
; COLOR05. This family settles it, probing bit 0 of the index.
;
; With only bitplane 1 fed, sections whose bitplane 1 bits agree should look
; identical regardless of their bitplane 2 bits.

SHRES_BPU           equ 1
INDEX_BIT           equ 0

	include "../shindex.i"
