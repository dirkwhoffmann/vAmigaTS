	include "../diwv.i"

copper:
	COPPER
	dc.w    DIWSTRT,$8081
	dc.w	DIWSTOP,$80c1

	dc.w	$7E39,$FFFE  ; WAIT 
	RULER

	dc.w    $ffdf,$fffe  ; Cross vertical boundary

	dc.w	$0639,$FFFE  ; WAIT 
	RULER

	dc.l	$fffffffe