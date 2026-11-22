; CHK with a lower bound violation and an overflowing difference
;
; Question this test answers: Does the 68000 (and the 68010) treat the
; register as above the upper bound if the difference of both operands
; overflows? chk.w d1,d0 with D0 = $8000 (-32768) and D1 = 10 violates the
; lower bound. 10 - (-32768) overflows in 16 bits and the result is negative.
;
; - MAME additionally takes the "above upper bound" path in this case, which
;   is 2 cycles shorter.
; - UAE takes the "below lower bound" path.
;
; The N flag is set in both cases, so only the timing differs.
;
; Payloads 1, 3, 5 use D0 = $8000 (overflow). Payloads 2, 4, 6 use D0 = -1
; (lower bound violated, no overflow) as a reference. If the CPU behaves like
; MAME, the bars of the odd payloads are 2 cycles shorter than the bars of the
; even payloads. If it behaves like UAE, all bars have the same length.
;
; The CHK handler in cpu2.i returns to the instruction behind CHK.

CHK_HANDLER	equ 1

CHKOVL		MACRO
			move.w	#$8000,d0
			moveq	#10,d1
			chk.w	d1,d0
			ENDM

CHKREF		MACRO
			move.w	#$FFFF,d0
			moveq	#10,d1
			chk.w	d1,d0
			ENDM

PAYLOAD1	MACRO
			CHKOVL
    	    ENDM
PAYLOAD2	MACRO
			CHKREF
    	    ENDM
PAYLOAD3	MACRO
			nop
			CHKOVL
    	    ENDM
PAYLOAD4	MACRO
			nop
			CHKREF
    	    ENDM
PAYLOAD5	MACRO
			nop
			nop
			CHKOVL
    	    ENDM
PAYLOAD6	MACRO
			nop
			nop
			CHKREF
    	    ENDM

	include "../../cpu2.i"
