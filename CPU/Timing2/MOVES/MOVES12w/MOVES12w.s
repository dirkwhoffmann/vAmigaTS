PAYLOAD1	MACRO
	        moves.w   d5,$DFF180
    	    ENDM
PAYLOAD2	MACRO
	        moves.w   d5,$DFF180
			nop
    	    ENDM
PAYLOAD3	MACRO
	        moves.w   d5,$DFF180
    	    ENDM
PAYLOAD4	MACRO
			nop
	        moves.w   d5,$DFF180
    	    ENDM
PAYLOAD5	MACRO
	        moves.w   d5,$DFF180
    	    ENDM
PAYLOAD6	MACRO
	        moves.w   d5,$DFF180
			move.w    #$F00,d5
    	    ENDM

	include "../../cpu2.i"
