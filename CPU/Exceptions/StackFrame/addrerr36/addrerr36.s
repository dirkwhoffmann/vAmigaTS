SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

; move.w #$68,-(a2) with an odd destination address, executed in user mode (carry set)
;
; Question this test answers: Is bit 3 of the code word (the first word of the
; stack frame) set if the write of a MOVE to a predecrement destination fails
; in user mode? No, regardless of the carry flag: the hardware
; shows a code word of $3361 (bit 3 clear) here and in addrerr35, which differs
; only in the carry flag. The supervisor mode recording (addrerr4) agrees.
;
; The instruction runs in user mode (the exception frame is written to the
; supervisor stack at a fixed location). A4 and A5 are set to known values and
; recorded in the last four rows. Rows 3 and 4 depend on the load address.
; The expected values below were recorded on an A500 (68000) and an A500 with a 68010.

trap0:
	PREPARE_STACK

	; Trigger the exception
	move.l  #$41424647,a2
	move.l  #$A4A4A4A4,a4
	move.l  #$A5A5A5A5,a5
	move.w  #$0001,sr
	move.w  #$68,-(a2)

	NO_EXCEPTION_GENERATED

exit:
	RECORD_REGS
	jmp 	continue

info: 
    dc.b    'ADDRERR36', 0
	even

expected000:
	dc.w   	$0007, $FEF2, $000E, $413A, $EE83, $3361, $4142, $4645
	dc.w   	$337C, $0000, $0007, $57E0, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $A4A4, $A4A4, $A5A5, $A5A5

expected010:
	dc.w   	$0007, $FEC6, $003A, $0000, $001E, $0000, $0007, $57E0
	dc.w   	$800C, $0001, $4142, $4645, $1111, $0068, $1111, $7FFF
	dc.w   	$1111, $7FFF, $A4A4, $A4A4, $A5A5, $A5A5

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
