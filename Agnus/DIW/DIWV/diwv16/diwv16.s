	include "../diwv.i"

copper:
	COPPER
	dc.w    DIWSTRT,$3a81
	dc.w	DIWSTOP,$9ac1

	dc.w	$3839,$FFFE  ; WAIT 
	RULER

	dc.w	$9E39,$FFFE  ; WAIT 
	RULER

	dc.w    $AE67,$FFFE
	dc.w    DPL2DATA,$0000
	dc.w    DPL1DATA,$ffff
	dc.w    $AE87,$FFFE
	dc.w    DPL2DATA,$ffff
	dc.w    DPL1DATA,$0000

	dc.w    $AF69,$FFFE
	dc.w    DPL2DATA,$0000
	dc.w    DPL1DATA,$ffff
	dc.w    $AF89,$FFFE
	dc.w    DPL2DATA,$ffff
	dc.w    DPL1DATA,$0000

	dc.w    $B06B,$FFFE
	dc.w    DPL2DATA,$0000
	dc.w    DPL1DATA,$ffff
	dc.w    $B08B,$FFFE
	dc.w    DPL2DATA,$ffff
	dc.w    DPL1DATA,$0000

	dc.w    $B16D,$FFFE
	dc.w    DPL2DATA,$0000
	dc.w    DPL1DATA,$ffff
	dc.w    $B18D,$FFFE
	dc.w    DPL2DATA,$ffff
	dc.w    DPL1DATA,$0000

	dc.w    $B26F,$FFFE
	dc.w    DPL2DATA,$0000
	dc.w    DPL1DATA,$ffff
	dc.w    $B28F,$FFFE
	dc.w    DPL2DATA,$ffff
	dc.w    DPL1DATA,$0000

	dc.w    $B371,$FFFE
	dc.w    DPL2DATA,$0000
	dc.w    DPL1DATA,$ffff
	dc.w    $B391,$FFFE
	dc.w    DPL2DATA,$ffff
	dc.w    DPL1DATA,$0000

	dc.w    $B473,$FFFE
	dc.w    DPL2DATA,$0000
	dc.w    DPL1DATA,$ffff
	dc.w    $B493,$FFFE
	dc.w    DPL2DATA,$ffff
	dc.w    DPL1DATA,$0000

	dc.w    $B575,$FFFE
	dc.w    DPL2DATA,$0000
	dc.w    DPL1DATA,$ffff
	dc.w    $B595,$FFFE
	dc.w    DPL2DATA,$ffff
	dc.w    DPL1DATA,$0000

	dc.w    $ffdf,$fffe  ; Cross vertical boundary

	dc.w	$0639,$FFFE  ; WAIT 
	RULER

	dc.l	$fffffffe