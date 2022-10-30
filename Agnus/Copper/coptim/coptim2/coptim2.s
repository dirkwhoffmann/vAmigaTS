DDFSTRT_INI		equ $68
DDFSTOP_INI		equ $70

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

	dc.w    $5859,$FFFE    ; WAIT
	dc.w    $5859,$FFFE    ; WAIT
	STRIPE
	dc.w    $5A5B,$FFFE    ; WAIT
	dc.w    $5A5B,$FFFE    ; WAIT
	STRIPE
	dc.w    $5C5D,$FFFE    ; WAIT
	dc.w    $5C5D,$FFFE    ; WAIT
	STRIPE
	dc.w    $5E5F,$FFFE    ; WAIT
	dc.w    $5E5F,$FFFE    ; WAIT
	STRIPE
	dc.w    $6061,$FFFE    ; WAIT
	dc.w    $6061,$FFFE    ; WAIT
	STRIPE
	dc.w    $6263,$FFFE    ; WAIT
	dc.w    $6263,$FFFE    ; WAIT
	STRIPE
	dc.w    $6465,$FFFE    ; WAIT
	dc.w    $6465,$FFFE    ; WAIT
	STRIPE
	dc.w    $6667,$FFFE    ; WAIT
	dc.w    $6667,$FFFE    ; WAIT
	STRIPE
	dc.w    $6869,$FFFE    ; WAIT
	dc.w    $6869,$FFFE    ; WAIT
	STRIPE
	dc.w    $6A6B,$FFFE    ; WAIT
	dc.w    $6A6B,$FFFE    ; WAIT
	STRIPE
	dc.w    $6C6D,$FFFE    ; WAIT
	dc.w    $6C6D,$FFFE    ; WAIT
	STRIPE
	dc.w    $6E6F,$FFFE    ; WAIT
	dc.w    $6E6F,$FFFE    ; WAIT
	STRIPE
	dc.w    $7071,$FFFE    ; WAIT
	dc.w    $7071,$FFFE    ; WAIT
	STRIPE
	dc.w    $7273,$FFFE    ; WAIT
	dc.w    $7273,$FFFE    ; WAIT
	STRIPE
	dc.w    $7475,$FFFE    ; WAIT
	dc.w    $7475,$FFFE    ; WAIT
	STRIPE
	dc.w    $7677,$FFFE    ; WAIT
	dc.w    $7677,$FFFE    ; WAIT
	STRIPE
	dc.w    $7879,$FFFE    ; WAIT
	dc.w    $7879,$FFFE    ; WAIT
	STRIPE
	dc.w    $7A7B,$FFFE    ; WAIT
	dc.w    $7A7B,$FFFE    ; WAIT
	STRIPE
	dc.w    $7C7D,$FFFE    ; WAIT
	dc.w    $7C7D,$FFFE    ; WAIT
	STRIPE
	dc.w    $7E7F,$FFFE    ; WAIT
	dc.w    $7E7F,$FFFE    ; WAIT
	STRIPE
	dc.w    $8081,$FFFE    ; WAIT
	dc.w    $8081,$FFFE    ; WAIT
	STRIPE

	dc.w	$ffdf,$fffe    ; Cross vertical boundary
	dc.w    BPLCON0,$0200
	dc.l	$fffffffe

bitplanes:
	ds.b 61440,$00
