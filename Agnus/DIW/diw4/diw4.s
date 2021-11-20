	include "../diw.i"

copper:

	dc.w    DIWSTRT,$6c81
	dc.w	DIWSTOP,$80c1

	; Try to modify DIWSTOP around the trigger position
	dc.w    $7FDF,$FFFE   ; WAIT 
	dc.w	DIWSTOP,$2cc1 ; Too late. Stop position (1) is used

	dc.w	$8801,$FFFE   ; WAIT 
	dc.w    DIWSTRT,$E081
	dc.w    DIWSTOP,$0cC1

	dc.w    $ffdf,$fffe   ; Cross vertical boundary

	dc.w    $0bDD,$FFFE   ; WAIT 
	dc.w    DIWSTOP,$7FC1 ; Just in time. New stop position ($17F) takes effect

	dc.l	$fffffffe
	