PAYLOAD1	MACRO
	        moves.l   spare,d0
    	    ENDM
PAYLOAD2	MACRO
	        moves.l   spare,d0
			nop
    	    ENDM
PAYLOAD3	MACRO
	        moves.l   spare,d0
    	    ENDM
PAYLOAD4	MACRO
			nop
	        moves.l   spare,d0
    	    ENDM
PAYLOAD5	MACRO
	        moves.l   spare,d0
    	    ENDM
PAYLOAD6	MACRO
	        moves.l   spare,d0
			lea       spare,a4
    	    ENDM

	include "../../cpu2.i"
