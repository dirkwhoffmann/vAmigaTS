PAYLOAD1	MACRO
	        moves.w   d0,(a4)+
    	    ENDM
PAYLOAD2	MACRO
	        moves.l   d0,(a4)+
    	    ENDM
PAYLOAD3	MACRO
	        moves.w   d0,(a4)+
    	    ENDM
PAYLOAD4	MACRO
	        moves.l   d0,(a4)+
    	    ENDM
PAYLOAD5	MACRO
	        moves.b   d0,(a4)+
			lea       spare,a4
    	    ENDM

	include "../ipl1.i"
