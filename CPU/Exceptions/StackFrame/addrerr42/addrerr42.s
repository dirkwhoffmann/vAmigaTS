SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

; jsr 6(a4) with an odd target address
;
; Question this test answers: Which program counter does the 68000 (and the
; 68010) stack if JSR jumps to an odd address in (d16,An) mode?
;
; - MAME stacks the program counter unchanged.
; - UAE stacks a program counter that is 2 lower.
;
; The stacked PC is shown in rows 10 and 11 on the 68000 and in rows 6 and 7
; on the 68010 (see addrerr13). The two emulators differ by 2. The last four
; rows show A4 and A5.
;
; The expected values are placeholders. Record them on an A500 (68000) and on
; an A500 with a 68010.

trap0:
	PREPARE_STACK

	; Trigger an address error exception
	move.l  #$00414243,a4
	move.l  #$00000300,a5
	jsr 	6(a4)

	NO_EXCEPTION_GENERATED

exit:
	RECORD_REGS
	jmp 	continue

info: 
    dc.b    'ADDRERR42', 0
	even

expected000:
	dc.w   	$0007, $FEF2, $000E, $0039, $EA87, $4EB6, $0041, $4249
	dc.w   	$4EAC, $2010, $0007, $57D0, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0041, $4243, $0000, $0300

expected010:
	dc.w   	$0007, $FEC6, $003A, $0000, $000E, $2010, $0007, $57D0
	dc.w   	$800C, $2106, $0041, $4249, $1111, $1111, $1111, $0006
	dc.w   	$1111, $0006, $0041, $4243, $0000, $0300

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
