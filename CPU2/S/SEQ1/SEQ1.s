PAYLOAD1	MACRO
			seq     d0
    	    ENDM
PAYLOAD2	MACRO
			seq     (a5)
    	    ENDM
PAYLOAD3	MACRO
			seq     (a5)+
    	    ENDM
PAYLOAD4	MACRO
			seq     -(a5)
    	    ENDM
PAYLOAD5	MACRO
			seq     $10(a5)
    	    ENDM
PAYLOAD6	MACRO
			seq     $10(a5,d5)
    	    ENDM

	include "../../cpu2.i"
