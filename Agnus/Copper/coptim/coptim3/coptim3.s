DDFSTRT_INI		equ $D0
DDFSTOP_INI		equ $D8

	include "../coptim.i"

copper:
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0
	dc.w    COLOR31,$555

	dc.w    $5039,$FFFE    ; WAIT
	RULER
	dc.w    $5201,$FFFE    ; WAIT
	dc.w    BPLCON0,$6200 

	dc.w    $58C9,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $5ACB,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $5CCD,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $5ECF,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $60D1,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $62D3,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $64D5,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $66D7,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $68D9,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $6ADB,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $6CDD,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $6EDF,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $70E1,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $7301,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $7503,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $7705,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $7907,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $7B09,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $7D0B,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $7F0D,$FFFE    ; WAIT
	STRIPE
	STRIPE
	dc.w    $810F,$FFFE    ; WAIT
	STRIPE
	STRIPE

	dc.w	$ffdf,$fffe    ; Cross vertical boundary
	dc.w    BPLCON0,$0200
	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
