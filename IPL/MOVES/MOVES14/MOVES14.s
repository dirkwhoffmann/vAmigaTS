PAYLOAD1	MACRO
	        moves   $10(a4),d0
    	    ENDM
PAYLOAD2	MACRO
	        moves   $6(a4,d5),d0
    	    ENDM
PAYLOAD3	MACRO
	        moves   spare,d0
    	    ENDM
PAYLOAD4	MACRO
	        moves   -(a4),d0
    	    ENDM
PAYLOAD5	MACRO
	        moves   (a4)+,d0
    	    ENDM

	include "../ipl1.i"
