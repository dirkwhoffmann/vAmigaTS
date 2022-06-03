BEAMCON MACRO
		; 
		ENDM
VPOSW0 	MACRO
    	dc.w    VPOSW,$0000
		ENDM
VPOSW1 	MACRO
    	dc.w    VPOSW,$0080
		ENDM

	include "../ntsc.i"
