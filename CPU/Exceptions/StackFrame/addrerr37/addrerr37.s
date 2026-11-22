SHOW_REGS equ 1
CUSTOM_ROWS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

; move.w #$68,(a2)+ with an odd address (same as addrerr3), 68010 only
;
; Question this test answers: What does the 68010 write into the internal
; information of its long stack frame (format $8)? The first internal word
; (SP+26) holds the version number of the processor. On RTE, the 68010 compares
; it with its own version number and raises a format error if they differ
; (see addrerr38).
;
; Rows 0 to 5 show the known part of the frame (compare with addrerr3), rows 6
; to 21 show the 16 words of internal information (SP+26 ... SP+56). The stack
; is filled with $1111 before the exception, so words the CPU doesn't write
; show up as $1111.
;
; Result: SP+26 is $0912. Bits 10 to 13 hold the version number 2. The other
; internal words are latches of the faulted bus cycle (data $0068, opcode $34FC,
; fault address $41424647, the incremented address $41424649, IRC $337C). One of
; the two $FFFF words read $0000 on the first run (not reproducible).
;
; The values on the 68000 and the 68020 are meaningless (the frames differ).
; The expected values below were recorded on an A500 with a 68010.

trap0:
	PREPARE_STACK

	; Trigger an address error exception
	move.l  #$41424647,a2
	move.w  #$68,(a2)+

	NO_EXCEPTION_GENERATED

exit:
	; Record the frame (A7 points to it)
	lea 	values,a3
	move.w 	6(a7),(a3)+			; Format and vector offset
	move.w 	8(a7),(a3)+			; Special status word
	move.l 	10(a7),(a3)+		; Fault address
	move.w 	0(a7),(a3)+			; Status register
	move.w 	24(a7),(a3)+		; Instruction input buffer
	lea 	26(a7),a2
	moveq 	#15,d0
.copy:
	move.w 	(a2)+,(a3)+			; Internal information
	dbra 	d0,.copy
	jmp 	continue

info:
    dc.b    'ADDRERR37 (68010 internal information)', 0
	even

rownames:
    dc.b ' Format / vector  = $', 0
    dc.b ' SSW              = $', 0
    dc.b ' Fault addr HI    = $', 0
    dc.b ' Fault addr LO    = $', 0
    dc.b ' SR               = $', 0
    dc.b ' Instr. input buf = $', 0
    dc.b ' SP+26 (version?) = $', 0
    dc.b ' SP+28            = $', 0
    dc.b ' SP+30            = $', 0
    dc.b ' SP+32            = $', 0
    dc.b ' SP+34            = $', 0
    dc.b ' SP+36            = $', 0
    dc.b ' SP+38            = $', 0
    dc.b ' SP+40            = $', 0
    dc.b ' SP+42            = $', 0
    dc.b ' SP+44            = $', 0
    dc.b ' SP+46            = $', 0
    dc.b ' SP+48            = $', 0
    dc.b ' SP+50            = $', 0
    dc.b ' SP+52            = $', 0
    dc.b ' SP+54            = $', 0
    dc.b ' SP+56            = $', 0
	even

expected000:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected010:
	dc.w   	$800C, $0005, $4142, $4647, $2010, $337C, $0912, $0068
	dc.w   	$34FC, $0068, $4142, $4647, $4142, $4649, $FFE6, $FFFF
	dc.w   	$0388, $337C, $4142, $0068, $34FC, $FFFF

expected020:
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
