	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; All six sprites are placed at this horizontal position, so a correct
; result lines them up in a single column. It has to stay below 256: at
; 256 and above, bit 8 of HSTART is bit 7 of the POS word, which the scan
; doubled sections need for SSCAN2. See agasprites.i.
SPR_HSTART          equ 160

	include "../agasprites.i"
