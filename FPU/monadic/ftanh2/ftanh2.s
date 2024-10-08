    include "../../fpureg.i"
	include "../../arith2.i"

trap0:
    fmove   #$40,FPCR   ; Precision: Single, Rounding: To nearest
    TEST    ftanh
    rte

info: 
    dc.b    'FTANH2', 0
    even 

expected:
    dc.b    $3F,$FE,$00,$00,  $Ff,$0B,$B0,$00  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 2
    dc.b    $3F,$FE,$00,$00,  $FD,$C7,$BB,$00  ; 3
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 4
    dc.b    $3F,$FE,$00,$00,  $E4,$EC,$D8,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 6
    dc.b    $3F,$FD,$00,$00,  $D1,$5B,$DE,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 8
    dc.b    $3F,$FE,$00,$00,  $99,$99,$9A,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 10
    dc.b    $3F,$FE,$00,$00,  $FA,$EE,$42,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 12
    dc.b    $3F,$FF,$00,$00,  $80,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 14
    dc.b    $BF,$FF,$00,$00,  $80,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$08  ; 16
    dc.b    $7F,$FF,$00,$00,  $40,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$01,  $01,$00,$00,$88  ; 18
    dc.b    $7F,$FF,$00,$00,  $40,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $01,$00,$00,$88  ; 20
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$01,  $09,$00,$00,$88  ; 22
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$01,  $09,$00,$00,$88  ; 24
