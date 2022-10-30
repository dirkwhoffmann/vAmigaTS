BEAMCON MACRO
		dc.w	$1DC,$0800   ; BEAMCON0  (LOLDIS = 1, PAL = 0)
		ENDM
VPOSW0 	MACRO
    	dc.w    VPOSW,$0080
		ENDM
VPOSW1 	MACRO
    	dc.w    VPOSW,$0000
		ENDM

	include "../ntsc.i"
