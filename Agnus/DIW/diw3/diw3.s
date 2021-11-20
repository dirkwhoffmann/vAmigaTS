	include "../diw.i"

copper:
	
	dc.w    DIWSTRT,$6c81
	dc.w	DIWSTOP,$80c1

	dc.w	$8801,$FFFE
	dc.w    DIWSTRT,$E081
	dc.w    DIWSTOP,$2cC1

	dc.l	$fffffffe
