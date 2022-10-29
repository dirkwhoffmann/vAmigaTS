PAYLOAD1	MACRO
			seq     $30.w
    	    ENDM
PAYLOAD2	MACRO
			seq     $DFF182.l
    	    ENDM
PAYLOAD3	MACRO
			nop
			seq     (a5)+
    	    ENDM
PAYLOAD4	MACRO
			nop
			seq     -(a5)
    	    ENDM
PAYLOAD5	MACRO
			nop
			seq     $10(a5)
    	    ENDM
PAYLOAD6	MACRO
			nop
			seq     $10(a5,d5)
    	    ENDM

	include "../../cpu2.i"
