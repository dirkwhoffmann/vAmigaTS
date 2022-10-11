PAYLOAD	MACRO
        andi.b  #$F,CCR
        ENDM

TSTCODE MACRO
		move.w  #0,SERPER(a1)
		TESTRUN $4000,$3

		move.w  #1,SERPER(a1)
		TESTRUN $6000,$3

		move.w  #1,SERPER(a1)
		TESTRUN $8000,$3

		move.w  #1,SERPER(a1)
		TESTRUN $A000,$F

		move.w  #1,SERPER(a1)
		TESTRUN $C000,$3F
		ENDM

	include "../../ipl.i"
