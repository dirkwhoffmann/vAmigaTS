	include "../diw.i"

copper:
	dc.w    DIWSTRT,$8081
	dc.w	DIWSTOP,$81c1

	dc.w    $8301,$FFFE   ; WAIT 
	dc.w    DIWSTRT,$A081
	dc.w	DIWSTOP,$B0c1 ; Displays 16 lines

	dc.w	$B101,$FFFE   ; WAIT 
	dc.w    DIWSTRT,$C081
	dc.w    DIWSTOP,$C0C1 ; Displays nothing, because STOP is dominant

	dc.l	$fffffffe
	