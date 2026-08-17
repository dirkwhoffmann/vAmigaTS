	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; agaddf9.s -- DDFSTRT $48, DDFSTOP $00C8, FMODE $0000.
;
; A thin wrapper. Everything except these three values lives in agaddf.i;
; see that file for what the picture means and how to read it.

DDF_START           equ $0048
DDF_STOP            equ $00C8
FMODE               equ $0000

	include "../agaddf.i"
