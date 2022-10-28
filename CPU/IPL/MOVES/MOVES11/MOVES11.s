PAYLOAD1	MACRO
	        moves.w   d0,$6(a4,d5)
    	    ENDM
PAYLOAD2	MACRO
	        moves.l   d0,$6(a4,d5)
    	    ENDM
PAYLOAD3	MACRO
	        moves.w   d0,$6(a4,d5)
    	    ENDM
PAYLOAD4	MACRO
	        moves.l   d0,$6(a4,d5)
    	    ENDM
PAYLOAD5	MACRO
	        moves.b   d0,$6(a4,d5)
    	    ENDM

	include "../ipl1.i"
