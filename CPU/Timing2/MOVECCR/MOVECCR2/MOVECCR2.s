PAYLOAD1	MACRO
	        move.w	CCR,(a4)
    	    ENDM
PAYLOAD2	MACRO
	        move.w	CCR,(a4)
			nop
    	    ENDM
PAYLOAD3	MACRO
	        move.w	CCR,(a4)
    	    ENDM
PAYLOAD4	MACRO
			nop
	        move.w	CCR,(a4)
    	    ENDM
PAYLOAD5	MACRO
	        move.w	CCR,(a4)
    	    ENDM
PAYLOAD6	MACRO
			nop
			nop
	        move.w	CCR,(a4)
    	    ENDM

	include "../../cpu2.i"
