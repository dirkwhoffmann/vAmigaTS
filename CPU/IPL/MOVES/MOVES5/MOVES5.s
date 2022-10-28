PAYLOAD1	MACRO
	        moves.w   $6(a4,d5),d0
    	    ENDM
PAYLOAD2	MACRO
	        moves.l   $6(a4,d5),d0
    	    ENDM
PAYLOAD3	MACRO
	        moves.w   $6(a4,d5),d0
    	    ENDM
PAYLOAD4	MACRO
	        moves.l   $6(a4,d5),d0
    	    ENDM
PAYLOAD5	MACRO
	        moves.b   $6(a4,d5),d0
    	    ENDM

	include "../ipl1.i"
