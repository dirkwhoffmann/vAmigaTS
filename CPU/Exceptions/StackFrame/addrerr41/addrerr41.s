SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

; dbra d0,*+5 with an odd target (counter expired, branch not taken)
;
; Question this test answers: Does the 68000 (and the 68010) raise an address
; error if the target of DBcc is odd, but the branch is not taken? D0 is 0, so
; the counter expires and DBcc falls through.
;
; - If the CPU checks the target before it tests the counter, an address error
;   is raised and the rows show its frame.
; - If not, DBcc falls through, D0 becomes $FFFF, and the screen shows
;   NO_EXCEPTION_GENERATED (green).
;
; Moira checks the target first on the 68000 and the 68010 (following MAME),
; while the 68020 only checks it if the branch is taken.
;
; The last four rows show D0 (A4 HI/LO) and A5 (unused).
;
; The expected values are placeholders. Record them on an A500 (68000) and on
; an A500 with a 68010.

trap0:
	PREPARE_STACK

	; Trigger an address error exception (if the target is checked)
	moveq   #0,d0
	move.l  #$00000300,a5
	dc.w 	$51C8,$0003		; dbra d0,*+5
	nop
	nop

	NO_EXCEPTION_GENERATED

exit:
	move.l 	d0,a4
	RECORD_REGS
	jmp 	continue

info: 
    dc.b    'ADDRERR41', 0
	even

expected000:
	dc.w   	$0007, $FEF2, $000E, $0000, $000D, $51D6, $0007, $57CF
	dc.w   	$51C8, $2014, $0007, $57CC, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0300

expected010:
	dc.w   	$0007, $FEC6, $003A, $0000, $000A, $2014, $0007, $57CC
	dc.w   	$800C, $2106, $0007, $57CF, $1111, $1111, $1111, $0003
	dc.w   	$1111, $FFFF, $0000, $0000, $0000, $0300

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
