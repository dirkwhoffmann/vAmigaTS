PAYLOAD1	MACRO
	        moves.w   d0,(a4)
    	    ENDM
PAYLOAD2	MACRO
	        moves.w   d0,(a4)
			nop
    	    ENDM
PAYLOAD3	MACRO
	        moves.w   d0,(a4)
    	    ENDM
PAYLOAD4	MACRO
			nop
	        moves.w   d0,(a4)
    	    ENDM
PAYLOAD5	MACRO
	        moves.w   d0,(a4)
    	    ENDM
PAYLOAD6	MACRO
	        moves.w   d0,(a4)
			lea		  $DFF180,a4
			move.w    #$F00,d0
    	    ENDM

	include "../../cpu2.i"
