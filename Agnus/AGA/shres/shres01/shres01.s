	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Fetch mode $0001. The super hires region below asks whether this fetch
; width lifts the bitplane limit of super hires, the way a non-zero FMODE
; lifts the four plane limit of hires. See shres.i.
FMODE               equ $0001

	include "../shres.i"
