	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; agaddf16.s -- DDFSTRT $3C, DDFSTOP $00C8, FMODE $0003.
;
; A thin wrapper. Everything except these three values lives in agaddf.i;
; see that file for what the picture means and how to read it.
;
; agaddf1 to agaddf10 sweep DDFSTRT with FMODE 0. This one repeats a point of
; that sweep at a wider fetch, which is the axis bplam4 could not separate:
; the first bitplane pixel has to move with DDFSTRT at one lores pixel per
; two cycles whatever FMODE is, and any offset that changes with FMODE
; belongs to the fetch rather than to the display window.

DDF_START           equ $003C
DDF_STOP            equ $00C8
FMODE               equ $0003

	include "../agaddf.i"
