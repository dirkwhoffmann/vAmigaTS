SHOW_REGS equ 1
FIXED_STACK equ $7FF00
	include "../stackframe.i"

; CMPI #<data>,<ea> with a PC-relative destination
;
; Question this test answers: Does the 68010 support the PC-relative
; destination modes of CMPI, (d16,PC) and (d8,PC,Xn)? The 68020 does.
;
; The test executes CMPI with (d16,PC) (form1) and then with (d8,PC,Xn)
; (form2). Both compare equal values. If both execute, TRAP #1 ends the test.
;
;   SP+06 = $0084   Both forms are supported (TRAP #1). The stacked SR shows
;                   Z=1 ($2004).
;   SP+06 = $0010   Illegal instruction. The relative PC tells which form was
;                   rejected: $0008 is form1, $000E is form2.
;
; The 68000 has no PC-relative destinations and raises an illegal instruction
; exception for form1 (its frame has no format word).
;
; Result: The 68000 and the 68010 reject form1 (illegal instruction). The 68020
; executes both forms.
; The expected values below were recorded on an A500, an A500 with a 68010, and
; an A1200.

trap0:
	PREPARE_STACK

	moveq   #2,d0
	move.w  #$2000,sr               ; Clear the condition codes

	; cmpi.w #$1234,(d16,PC) (the assembler rejects it in 68000 mode)
form1:
	dc.w    $0C7A,$1234
	dc.w    data16+2-*

	; cmpi.b #$56,(d8,PC,d0.w)
form2:
	dc.w    $0C3B,$0056
	dc.w    (data8+4-2-*)&$FF

	trap    #1                      ; Both forms executed

	NO_EXCEPTION_GENERATED

exit:
	jmp 	continue

; The compared values are padded, so the result doesn't depend on whether the
; PC base is the immediate word or the displacement word
data16:
	dc.w    $1234, $1234, $1234
data8:
	dc.b    $56, $56, $56, $56, $56, $56, $56, $56

info:
    dc.b    'STACKFRAME7 (CMPI PC-rel dest)', 0
	even

expected000:
	dc.w   	$0007, $FEFA, $0006, $0000, $0008, $2000, $0007, $57CA
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected010:
	dc.w   	$0007, $FEF8, $0008, $0000, $0008, $2000, $0007, $57CA
	dc.w   	$0010, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000

expected020:
	dc.w   	$0007, $FEF8, $0008, $0000, $0016, $2004, $0007, $57D8
	dc.w   	$0084, $0000, $0000, $0000, $0000, $0000, $0000, $0000
	dc.w   	$0000, $0000, $0000, $0000, $0000, $0000
