
	include "../bpumod.i"

copper:
	COPPER
	dc.w    DIWSTRT,$3a81
	dc.w	DIWSTOP,$1ac1

	dc.w	$3841,$FFFE  ; WAIT 
	RULER


	dc.w    $4061,$FFFE 
	dc.w    BPLCON0,$A200
	dc.w    BPLCON0,$2200

	dc.w    $4863,$FFFE 
	dc.w    BPLCON0,$A200
	dc.w    BPLCON0,$2200

	dc.w    $5065,$FFFE 
	dc.w    BPLCON0,$A200
	dc.w    BPLCON0,$2200

	dc.w    $5867,$FFFE 
	dc.w    BPLCON0,$A200
	dc.w    BPLCON0,$2200

	dc.w    $6069,$FFFE 
	dc.w    BPLCON0,$A200
	dc.w    BPLCON0,$2200

	dc.w    $686B,$FFFE 
	dc.w    BPLCON0,$A200
	dc.w    BPLCON0,$2200

	dc.w    $706D,$FFFE 
	dc.w    BPLCON0,$A200
	dc.w    BPLCON0,$2200

	dc.w    $786F,$FFFE 
	dc.w    BPLCON0,$A200
	dc.w    BPLCON0,$2200

	dc.w    $ffdf,$fffe  ; Cross vertical boundary
	dc.w	$0641,$FFFE  ; WAIT 
	RULER

	dc.l	$fffffffe