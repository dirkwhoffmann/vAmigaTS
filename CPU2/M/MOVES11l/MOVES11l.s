PAYLOAD1	MACRO
	        moves.l   d0,$6(a4,d5)
    	    ENDM
PAYLOAD2	MACRO
	        moves.l   d0,$6(a4,d5)
			nop
    	    ENDM
PAYLOAD3	MACRO
	        moves.l   d0,$6(a4,d5)
    	    ENDM
PAYLOAD4	MACRO
			nop
	        moves.l   d0,$6(a4,d5)
    	    ENDM
PAYLOAD5	MACRO
	        moves.l   d0,$6(a4,d5)
    	    ENDM
PAYLOAD6	MACRO
	        moves.l   d0,$6(a4,d5)
			lea       spare,a4
    	    ENDM

	include "../../cpu2.i"
