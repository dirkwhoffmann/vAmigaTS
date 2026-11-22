SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

; dbra d0,*+5 with an odd target (branch taken)
;
; Question this test answers: Which program counter does the 68000 (and the
; 68010) stack if DBcc branches to an odd address, and is the counter
; decremented before the address error is raised?
;
; - MAME stacks the address behind the extension word (even PC).
; - UAE stacks the target address plus 2 (odd PC).
; - MAME and UAE raise the address error before the counter is decremented
;   (D0 stays 5).
;
; The last four rows show D0 (A4 HI/LO) and A5 (unused).
; See 68020/StackFrame/frame020_8 for the same test on the 68020.
;
; The expected values are placeholders. Record them on an A500 (68000) and on
; an A500 with a 68010.

trap0:
	PREPARE_STACK

	; Trigger an address error exception
	moveq   #5,d0
	move.l  #$00000300,a5
	dc.w 	$51C8,$0003		; dbra d0,*+5

	NO_EXCEPTION_GENERATED

exit:
	move.l 	d0,a4
	RECORD_REGS
	jmp 	continue

info: 
    dc.b    'ADDRERR40', 0
	even

expected000:
	dc.w   	$0007, $FEF2, $000E, $0000, $000D, $51D6, $0007, $57CF
	dc.w   	$51C8, $2010, $0007, $57CC, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0005, $0000, $0300

expected010:
	dc.w   	$0007, $FEC6, $003A, $0000, $000A, $2010, $0007, $57CC
	dc.w   	$800C, $2106, $0007, $57CF, $1111, $1111, $1111, $0003
	dc.w   	$1111, $FFFF, $0000, $0005, $0000, $0300

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
