PAYLOAD1	MACRO
	        moves.w   spare,d0
    	    ENDM
PAYLOAD2	MACRO
	        moves.l   spare,d0
    	    ENDM
PAYLOAD3	MACRO
	        moves.w   spare,d0
    	    ENDM
PAYLOAD4	MACRO
	        moves.l   spare,d0
    	    ENDM
PAYLOAD5	MACRO
	        moves.b   spare,d0
    	    ENDM

	include "../ipl1.i"
