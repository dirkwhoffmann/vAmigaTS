
	include "../diwv.i"

copper:
	COPPER
	dc.w    DIWSTRT,$0081
	dc.w	DIWSTOP,$1ac1

	dc.w	$3839,$FFFE  ; WAIT 
	RULER

	dc.w	$cc39,$FFFE  ; WAIT 
	RULER

	dc.w    $ffdf,$fffe  ; Cross vertical boundary

	dc.w	$0639,$FFFE  ; WAIT 
	RULER

	dc.l	$fffffffe