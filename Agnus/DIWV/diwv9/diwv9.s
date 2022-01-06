	include "../diwv.i"

copper:
	COPPER
	dc.w    DIWSTRT,$7a81
	dc.w	DIWSTOP,$1ac1

	dc.w	$3839,$FFFE  ; WAIT 
	RULER

	dc.w	$3a89,$FFFE  ; WAIT (mid scanline)
	dc.w    DIWSTRT,$3a81   

	dc.w	$7E39,$FFFE  ; WAIT 
	RULER

	dc.w    $ffdf,$fffe  ; Cross vertical boundary

	dc.w	$0639,$FFFE  ; WAIT 
	RULER

	dc.l	$fffffffe