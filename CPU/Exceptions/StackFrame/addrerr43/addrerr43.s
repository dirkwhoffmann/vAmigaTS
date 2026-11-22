SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

; movem.l (4,a4,d0.w),d2-d4 with an odd effective address
;
; Question this test answers: Which program counter does the 68000 (and the
; 68010) stack if MOVEM reads from an odd address in (d8,An,Xn) mode? The
; address error is raised before the first register is loaded.
;
; - MAME stacks the program counter plus 2.
; - UAE stacks the program counter minus 2.
;
; The stacked PC is shown in rows 10 and 11 on the 68000 and in rows 6 and 7
; on the 68010 (see addrerr13). The two emulators differ by 4. The last four
; rows show A4 and A5.
;
; The expected values are placeholders. Record them on an A500 (68000) and on
; an A500 with a 68010.

trap0:
	PREPARE_STACK

	; Trigger an address error exception
	moveq   #0,d0
	move.l  #$00414243,a4
	move.l  #$00000300,a5
	movem.l (4,a4,d0.w),d2-d4

	NO_EXCEPTION_GENERATED

exit:
	RECORD_REGS
	jmp 	continue

info: 
    dc.b    'ADDRERR43', 0
	even

expected000:
	dc.w   	$0007, $FEF2, $000E, $0039, $EA85, $4CF5, $0041, $4247
	dc.w   	$4CF4, $2014, $0007, $57D4, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0041, $4243, $0000, $0300

expected010:
	dc.w   	$0007, $FEC6, $003A, $0000, $0016, $2014, $0007, $57D8
	dc.w   	$800C, $1105, $0041, $4247, $1111, $1111, $1111, $337C
	dc.w   	$1111, $337C, $0041, $4243, $0000, $0300

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
