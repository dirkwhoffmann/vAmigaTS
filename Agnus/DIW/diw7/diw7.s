	include "../diw.i"

copper:

	dc.w    DIWSTRT,$6781
	dc.w	DIWSTOP,$7FC1 ; Largest possible vertical value
	
	dc.w    $ffdf,$fffe  ; Cross vertical boundary
	dc.w    $3501,$FFFE  ; Line $135 (last in SAE)
	dc.w    COLOR00,$F00

	dc.w    $3601,$FFFE  ; Line $136 (last in UAE)
	dc.w    COLOR00,$FF0 

	dc.w    $3701,$FFFE  ; Line $137 (not visible in SAE or UAE)
	dc.w    COLOR00,$0FF

	dc.w    $3801,$FFFE  ; Line $137 (not visible in SAE or UAE)
	dc.w    COLOR00,$000

	dc.l	$fffffffe
	