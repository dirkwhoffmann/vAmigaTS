PAYLOAD1	MACRO
	        moves.l   (a4),d0
    	    ENDM
PAYLOAD2	MACRO
	        moves.l   (a4),d0
			nop
    	    ENDM
PAYLOAD3	MACRO
	        moves.l   (a4),d0
    	    ENDM
PAYLOAD4	MACRO
			nop
	        moves.l   (a4),d0
    	    ENDM
PAYLOAD5	MACRO
	        moves.l   (a4),d0
    	    ENDM
PAYLOAD6	MACRO
			nop
			nop
	        moves.l   (a4),d0
    	    ENDM

	include "../../cpu2.i"
