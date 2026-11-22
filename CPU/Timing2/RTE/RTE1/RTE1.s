; RTE with a long stack frame (format $8) and a wrong version number (68010)
;
; Question this test answers: How long does the 68010 take to process a long
; frame before it raises a format error? The payload fabricates a 58 byte frame
; with format $8 and version number 0 (the 68010 expects 2, see addrerr37 and
; addrerr38) and executes RTE. The 68010 raises a format error, the handler in
; cpu2.i returns to the instruction behind RTE, and the payload removes the
; frame. The frame never resumes an instruction, so its internal information
; doesn't matter.
;
; The length of the bar shows how many bus cycles the 68010 spends on the frame
; before the format error is raised, i.e., whether it reads the words that RTE
; discards (UAE doesn't read them).
;
; The 68000 ignores the format word. It pops the status register and the
; program counter, which points to the instruction that removes the rest of
; the frame.

RTEFRAME	MACRO
			suba.w	#58,a7
			move.w	sr,(a7)					; Status register
			move.l	#.\@cont000,2(a7)		; Program counter (used by the 68000)
			move.w	#$8000,6(a7)			; Format $8, vector offset 0
			clr.w	26(a7)					; Version number 0
			rte
			lea		58(a7),a7				; 68010: The format error returns here
			bra.s	.\@done
.\@cont000:
			lea		52(a7),a7				; 68000: RTE has popped 6 bytes
.\@done:
			ENDM

PAYLOAD1	MACRO
			RTEFRAME
    	    ENDM
PAYLOAD2	MACRO
			RTEFRAME
			nop
    	    ENDM
PAYLOAD3	MACRO
			RTEFRAME
    	    ENDM
PAYLOAD4	MACRO
			nop
			RTEFRAME
    	    ENDM
PAYLOAD5	MACRO
			RTEFRAME
    	    ENDM
PAYLOAD6	MACRO
			nop
			nop
			RTEFRAME
    	    ENDM

	include "../../cpu2.i"
