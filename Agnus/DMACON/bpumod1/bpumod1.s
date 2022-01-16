
	include "../bpumod.i"

copper:
	COPPER
	dc.w    DIWSTRT,$3a81
	dc.w	DIWSTOP,$1ac1

	dc.w	$3841,$FFFE  ; WAIT 
	RULER


	dc.w    $4061,$FFFE 
	dc.w    BPLCON0,$3200
	dc.w    $4069,$FFFE 
	dc.w    BPLCON0,$4200

	dc.w    $4863,$FFFE 
	dc.w    BPLCON0,$3200
	dc.w    $486B,$FFFE 
	dc.w    BPLCON0,$4200

	dc.w    $5065,$FFFE 
	dc.w    BPLCON0,$3200
	dc.w    $506D,$FFFE 
	dc.w    BPLCON0,$4200

	dc.w    $5867,$FFFE 
	dc.w    BPLCON0,$3200
	dc.w    $586F,$FFFE 
	dc.w    BPLCON0,$4200

	dc.w    $6069,$FFFE 
	dc.w    BPLCON0,$3200
	dc.w    $6071,$FFFE 
	dc.w    BPLCON0,$4200

	dc.w    $686B,$FFFE 
	dc.w    BPLCON0,$3200
	dc.w    $6873,$FFFE 
	dc.w    BPLCON0,$4200

	dc.w    $706D,$FFFE 
	dc.w    BPLCON0,$3200
	dc.w    $7075,$FFFE 
	dc.w    BPLCON0,$4200

	dc.w    $786F,$FFFE 
	dc.w    BPLCON0,$3200
	dc.w    $7877,$FFFE 
	dc.w    BPLCON0,$4200

	dc.w    $ffdf,$fffe  ; Cross vertical boundary
	dc.w	$0641,$FFFE  ; WAIT 
	RULER

	dc.l	$fffffffe