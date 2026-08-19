	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; Does ECS super hires split a colour register across two sub-pixels?
; Read the answer off sections 1 and 2: clearly different brightness means
; no split, equal mid red means split. See shsplit.i.

	include "../shsplit.i"
