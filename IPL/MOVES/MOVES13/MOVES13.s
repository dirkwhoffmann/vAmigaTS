PAYLOAD1	MACRO
	        moves   (a4),d0
    	    ENDM
PAYLOAD2	MACRO
	        moves   (a4),d0
    	    ENDM
PAYLOAD3	MACRO
	        moves   (a4),d0
    	    ENDM
PAYLOAD4	MACRO
	        moves   -(a4),d0
    	    ENDM
PAYLOAD5	MACRO
	        moves   (a4)+,d0
    	    ENDM

	include "../ipl1.i"
