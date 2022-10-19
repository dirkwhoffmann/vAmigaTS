PAYLOAD1	MACRO
	        moves   d0,$10(a4)
    	    ENDM
PAYLOAD2	MACRO
	        moves   d0,$6(a4,d5)
    	    ENDM
PAYLOAD3	MACRO
	        moves   d0,spare
    	    ENDM
PAYLOAD4	MACRO
	        moves   d0,-(a4)
    	    ENDM
PAYLOAD5	MACRO
	        moves   d0,(a4)+
    	    ENDM

	include "../ipl1.i"
