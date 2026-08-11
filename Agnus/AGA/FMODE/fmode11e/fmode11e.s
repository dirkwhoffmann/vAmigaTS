	include "../../../../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "ministartup.s"

; fmode11e -- even planes (2,4,6,8) misaligned, odd planes (1,3,5,7)
; aligned. The complement of fmode11d; together they settle whether plane
; parity or plane number (upper vs lower half) governs sensitivity.
;
; Prediction under "planes 5-8 need alignment, 1-4 don't care": planes 6 and
; 8 drop (misaligned and sensitive); planes 2, 4 survive (misaligned but not
; sensitive); planes 1, 3, 5, 7 all survive (aligned). Visible planes:
; 1, 2, 3, 4, 5, 7.
;
; If instead fmode11d shows 1,3,5,7 missing and this one shows 2,4,6,8
; missing (i.e. the misaligned set is always what's lost, regardless of
; which half it's in), then sensitivity is universal, not confined to
; planes 5-8, and fmode11b/c's earlier results need a different explanation.
FMODE               equ $0003    ; Fetch mode under test
DDF_START           equ $0030
DDF_STOP_LORES      equ $0070
DDF_STOP_HIRES      equ $0080

PLANE2_MISALIGN     equ 1
PLANE4_MISALIGN     equ 1
PLANE6_MISALIGN     equ 1
PLANE8_MISALIGN     equ 1

	include "../fmode.i"
