PAYLOAD	MACRO
        move.w D1,D2
        move.w D2,D1
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
