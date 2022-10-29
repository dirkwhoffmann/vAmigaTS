PAYLOAD1	MACRO
	        move.w	CCR,d0
    	    ENDM
PAYLOAD2	MACRO
	        move.w	CCR,d0
			nop
    	    ENDM
PAYLOAD3	MACRO
	        move.w	CCR,d0
    	    ENDM
PAYLOAD4	MACRO
			nop
	        move.w	CCR,d0
    	    ENDM
PAYLOAD5	MACRO
	        move.w	CCR,d0
    	    ENDM
PAYLOAD6	MACRO
			nop
			nop
	        move.w	CCR,d0
    	    ENDM

	include "../../cpu2.i"
