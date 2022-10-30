	include "../diwv.i"

copper:
	COPPER
	dc.w    DIWSTRT,$3a81
	dc.w	DIWSTOP,$1ac1

	dc.w	$7E39,$FFFE  ; WAIT 
	RULER

	dc.w	DIWSTOP,$7dc1 ; Stop position won't be reached

	dc.w    $ffdf,$fffe  ; Cross vertical boundary

	dc.w	$0639,$FFFE  ; WAIT 
	RULER

	dc.l	$fffffffe