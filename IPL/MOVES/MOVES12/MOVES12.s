PAYLOAD1	MACRO
	        moves.w   d0,spare
    	    ENDM
PAYLOAD2	MACRO
	        moves.l   d0,spare
    	    ENDM
PAYLOAD3	MACRO
	        moves.w   d0,spare
    	    ENDM
PAYLOAD4	MACRO
	        moves.l   d0,spare
    	    ENDM
PAYLOAD5	MACRO
	        moves.b   d0,spare
    	    ENDM

	include "../ipl1.i"
