SHOW_REGS equ 1
CUSTOM_ROWS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

; Version number check of RTE (68010 only)
;
; Question this test answers: Which bits of the internal information does the
; 68010 check on RTE? The test triggers an address error (same as addrerr3),
; flips the bits VERSION_MASK in the word at SP+26 of the frame and executes
; RTE.
;
; - If the flipped bits belong to the version number, the 68010 raises a
;   format error. The second exception shows vector offset $038 (row 3).
; - Otherwise, the 68010 continues the faulting instruction, which faults
;   again. The second exception shows format $8 and vector offset $00C.
;
; Change VERSION_MASK and run the test again to narrow down the version field.
;
; Result for VERSION_MASK = $3C00: The 68010 raises a format error. The stacked
; status register shows N=0, Z=0, V=0, C=1 (the condition codes are cleared
; right before RTE, so the format error sets C).
;
; On the 68000 and the 68020, the test doesn't execute RTE (the frames differ)
; and all rows show zero.
; The expected values below were recorded on an A500 with a 68010.

VERSION_MASK equ $3C00

trap0:
	PREPARE_STACK

	; Trigger an address error exception
	move.l  #$41424647,a2
	move.w  #$68,(a2)+

	NO_EXCEPTION_GENERATED

exit:
	; A7 points to the frame of the latest exception
	tst.w 	state
	bne.s 	.second

	; First exception: only the 68010 continues
	move.l 	$4,a5				; Exec base
	btst 	#1,$129(a5)
	bne.s 	.skip				; 68020 or above
	btst 	#0,$129(a5)
	beq.s 	.skip				; 68000

	move.w 	#1,state
	move.w 	26(a7),original
	eor.w 	#VERSION_MASK,26(a7)
	move.w 	26(a7),patched
	rte

.second:
	lea 	values,a3
	move.w 	#VERSION_MASK,(a3)+
	move.w 	original,(a3)+
	move.w 	patched,(a3)+
	move.w 	6(a7),(a3)+			; Format and vector offset of the second exception
	move.w 	0(a7),(a3)+			; Status register
	move.w 	8(a7),(a3)+			; SSW (if the second exception is an address error)
	move.w 	26(a7),(a3)+		; SP+26 (if the second exception is an address error)
	moveq 	#14,d0
.clear:
	clr.w 	(a3)+
	dbra 	d0,.clear
	jmp 	continue

.skip:
	lea 	values,a3
	moveq 	#21,d0
.clear2:
	clr.w 	(a3)+
	dbra 	d0,.clear2
	jmp 	continue

state:
	dc.w 	0
original:
	dc.w 	0
patched:
	dc.w 	0

info:
    dc.b    'ADDRERR38 (68010 RTE version check)', 0
	even

rownames:
    dc.b ' Flipped bits     = $', 0
    dc.b ' SP+26 original   = $', 0
    dc.b ' SP+26 modified   = $', 0
    dc.b ' 2nd fmt / vector = $', 0
    dc.b ' 2nd SR           = $', 0
    dc.b ' 2nd SP+08        = $', 0
    dc.b ' 2nd SP+26        = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
    dc.b ' -                = $', 0
	even

expected000:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected010:
	dc.w   	$3C00, $0912, $3512, $0038, $2011, $2010, $1111, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
