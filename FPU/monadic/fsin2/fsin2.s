    include "../../fpureg.i"
	include "../../arith2.i"

trap0:
    fmove   #$40,FPCR   ; Precision: Single, Rounding: To nearest
    TEST    fsin
    rte

info: 
    dc.b    'FSIN2', 0
    even 

expected:
    dc.b    $BF,$E7,$00,$00,  $BB,$BD,$2E,$00  ; 1
    dc.b    $00,$00,$00,$00,  $08,$00,$02,$08  ; 2
    dc.b    $3F,$FD,$00,$00,  $D2,$51,$EF,$00  ; 3
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 4
    dc.b    $3F,$FE,$00,$00,  $FD,$E7,$04,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 6
    dc.b    $3F,$FD,$00,$00,  $D7,$6F,$3B,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 8
    dc.b    $3F,$FE,$00,$00,  $A3,$92,$F7,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 10
    dc.b    $3F,$FE,$00,$00,  $BE,$75,$7E,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 12
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 13
    dc.b    $FF,$FF,$FF,$FF,  $01,$00,$20,$88  ; 14
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 15
    dc.b    $FF,$FF,$FF,$FF,  $01,$00,$20,$88  ; 16
    dc.b    $7F,$FF,$00,$00,  $40,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$01,  $01,$00,$00,$88  ; 18
    dc.b    $7F,$FF,$00,$00,  $40,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $01,$00,$00,$88  ; 20
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$01,  $09,$00,$00,$88  ; 22
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$01,  $09,$00,$00,$88  ; 24
