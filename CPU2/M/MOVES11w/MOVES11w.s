PAYLOAD1	MACRO
	        moves.w   d5,$6(a4,d5)
    	    ENDM
PAYLOAD2	MACRO
	        moves.w   d5,$6(a4,d5)
			nop
    	    ENDM
PAYLOAD3	MACRO
	        moves.w   d5,$6(a4,d5)
    	    ENDM
PAYLOAD4	MACRO
			nop
	        moves.w   d5,$6(a4,d5)
    	    ENDM
PAYLOAD5	MACRO
	        moves.w   d5,$6(a4,d5)
    	    ENDM
PAYLOAD6	MACRO
	        moves.w   d5,$6(a4,d5)
			lea       $DFF17A,a4
			move.w    #$F00,d5
    	    ENDM

	include "../../cpu2.i"
