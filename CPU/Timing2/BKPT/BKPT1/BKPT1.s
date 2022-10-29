PAYLOAD1	MACRO
	        bkpt	#0
    	    ENDM
PAYLOAD2	MACRO
	        bkpt	#1
			nop
    	    ENDM
PAYLOAD3	MACRO
	        bkpt	#2
    	    ENDM
PAYLOAD4	MACRO
			nop
	        bkpt	#3
    	    ENDM
PAYLOAD5	MACRO
	        bkpt	#4
    	    ENDM
PAYLOAD6	MACRO
			nop
			nop
	        bkpt	#5
    	    ENDM

	include "../../cpu2.i"
