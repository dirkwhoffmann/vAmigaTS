PAYLOAD1	MACRO
	        moves.b   d0,spare
    	    ENDM
PAYLOAD2	MACRO
	        moves.b   d0,spare
			nop
    	    ENDM
PAYLOAD3	MACRO
	        moves.b   d0,spare
    	    ENDM
PAYLOAD4	MACRO
			nop
	        moves.b   d0,spare
    	    ENDM
PAYLOAD5	MACRO
	        moves.b   d0,spare
    	    ENDM
PAYLOAD6	MACRO
	        moves.b   d0,spare
			lea       spare,a4
    	    ENDM

	include "../../cpu2.i"
