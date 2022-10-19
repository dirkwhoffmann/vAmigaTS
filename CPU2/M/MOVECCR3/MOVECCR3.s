PAYLOAD1	MACRO
			moveq   #2,d5
	        move.w	d5,CCR
    	    ENDM
PAYLOAD2	MACRO
	        move.w	d5,CCR
			nop
    	    ENDM
PAYLOAD3	MACRO
	        move.w	d5,CCR
    	    ENDM
PAYLOAD4	MACRO
			nop
	        move.w	d5,CCR
    	    ENDM
PAYLOAD5	MACRO
	        move.w	d5,CCR
    	    ENDM
PAYLOAD6	MACRO
			nop
			nop
	        move.w	d5,CCR
    	    ENDM

	include "../../cpu2.i"
