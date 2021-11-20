	include "../diw.i"

copper:

	dc.w    DIWSTRT,$6c81
	dc.w	DIWSTOP,$80c1

	; Try to modify DIWSTOP around the trigger position
	dc.w    $7FDD,$FFFE   ; WAIT 
	dc.w	DIWSTOP,$2cc1 ; Just in time.

	dc.w	$8801,$FFFE   ; WAIT 
	dc.w    DIWSTRT,$E081
	dc.w    DIWSTOP,$0cC1

	dc.w    $ffdf,$fffe   ; Cross vertical boundary

	dc.w    $0bDF,$FFFE   ; WAIT 
	dc.w    DIWSTOP,$7FC1 ; Too late

	dc.l	$fffffffe
