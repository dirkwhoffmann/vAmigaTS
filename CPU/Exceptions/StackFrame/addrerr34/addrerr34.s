SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

; pea $4242.w with an odd user stack pointer (push fails, address mode: absolute short (control: MAME does not prefetch before the push))
;
; Question this test answers: Which IRD does the 68000 stack if the push of a PEA
; fails? PEA prefetches the next instruction word before it pushes the address
; (except in the absolute modes). MAME and Moira stack the opcode of the PEA itself
; ($4852 for pea (a2)): the IRD is replaced when the last bus cycle starts, which
; is after the address error has been detected. If the hardware replaces the IRD
; at the end of the prefetch, the frame holds the next opcode instead (here $337C,
; the first word of "move.w #$7FFF,DMACON(a1)") and the code word reads $3361
; instead of the value shown below.
;
; The instruction runs in user mode, because an odd supervisor stack pointer
; would cause a double fault. The exception frame is written to the supervisor
; stack, which sits at a fixed location. A4 and A5 are set to known values and
; recorded in the last four rows. Rows 3 and 4 depend on the load address.
; The expected values below are Moira's prediction, not hardware results.

trap0:
	PREPARE_STACK

	; Trigger the exception
	lea     $414242,a2
	lea     $60001,a3
	move.l  a3,usp
	move.l  #$A4A4A4A4,a4
	move.l  #$A5A5A5A5,a5
	move.w  #$0000,sr
	pea     $4242.w

	NO_EXCEPTION_GENERATED

exit:
	RECORD_REGS
	jmp 	continue

info: 
    dc.b    'ADDRERR34', 0
	even

expected000:
	dc.w   	$0007, $FEF2, $000E, $FFFE, $A83B, $4861, $0005, $FFFD
	dc.w   	$4878, $0000, $0007, $57E6, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $A4A4, $A4A4, $A5A5, $A5A5

expected010:
	dc.w   	$0007, $FEC6, $003A, $0000, $0020, $0000, $0007, $57E2
	dc.w   	$800C, $0001, $0005, $FFFD, $1111, $0000, $1111, $337C
	dc.w   	$1111, $337C, $A4A4, $A4A4, $A5A5, $A5A5

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
