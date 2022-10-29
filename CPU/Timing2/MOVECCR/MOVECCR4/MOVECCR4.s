PAYLOAD1	MACRO
			move.w  #2,(a4)
	        move.w	(a4),CCR
    	    ENDM
PAYLOAD2	MACRO
	        move.w	(a4),CCR
			nop
    	    ENDM
PAYLOAD3	MACRO
	        move.w	(a4),CCR
    	    ENDM
PAYLOAD4	MACRO
			nop
	        move.w	(a4),CCR
    	    ENDM
PAYLOAD5	MACRO
	        move.w	(a4),CCR
    	    ENDM
PAYLOAD6	MACRO
			nop
			nop
	        move.w	(a4),CCR
    	    ENDM

	include "../../cpu2.i"
