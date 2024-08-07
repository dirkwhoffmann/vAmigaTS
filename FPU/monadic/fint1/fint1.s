    include "../../fpureg.i"
	include "../../arith1.i"

trap0:
    fmove   #$40,FPCR   ; Precision: Single, Rounding: To nearest
    TEST    fint
    rte

info: 
    dc.b    'FINT1', 0
    even 

expected:
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 2
    dc.b    $80,$00,$00,$00,  $00,$00,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $0C,$00,$00,$00  ; 4
    dc.b    $3F,$FF,$00,$00,  $80,$00,$00,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 6
    dc.b    $BF,$FF,$00,$00,  $80,$00,$00,$00  ; 7
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$00  ; 8
    dc.b    $40,$00,$00,$00,  $80,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 10
    dc.b    $C0,$00,$00,$00,  $80,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$00  ; 12
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $04,$00,$02,$08  ; 14
    dc.b    $80,$00,$00,$00,  $00,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $0C,$00,$02,$08  ; 16
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $04,$00,$02,$08  ; 18
    dc.b    $80,$00,$00,$00,  $00,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $0C,$00,$02,$08  ; 20
    dc.b    $40,$05,$00,$00,  $FA,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 22
    dc.b    $C0,$05,$00,$00,  $FA,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $08,$00,$02,$08  ; 24
