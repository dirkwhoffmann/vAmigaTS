PAYLOAD1	MACRO
	        moves.b   $6(a4),d0
    	    ENDM
PAYLOAD2	MACRO
	        moves.b   $6(a4),d0
			nop
    	    ENDM
PAYLOAD3	MACRO
	        moves.b   $6(a4),d0
    	    ENDM
PAYLOAD4	MACRO
			nop
	        moves.b   $6(a4),d0
    	    ENDM
PAYLOAD5	MACRO
	        moves.b   $6(a4),d0
    	    ENDM
PAYLOAD6	MACRO
	        moves.b   $6(a4),d0
			lea       spare,a4
    	    ENDM

	include "../../cpu2.i"
