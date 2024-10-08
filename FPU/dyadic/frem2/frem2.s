    include "../../fpureg.i"
    include "../../dyadic2.i"

trap0:
    fmove   #$40,FPCR   ; Precision: Single, Rounding: To nearest
    TEST    frem
    rte

info: 
    dc.b    'FREM2', 0
    even 

expected:
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 1
    dc.b    $FF,$FF,$FF,$FF,  $01,$00,$20,$80  ; 2
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 3
    dc.b    $FF,$FF,$FF,$FF,  $01,$00,$20,$80  ; 4
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 5
    dc.b    $FF,$FF,$FF,$FF,  $01,$00,$20,$80  ; 6
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 7
    dc.b    $FF,$FF,$FF,$FF,  $01,$00,$20,$80  ; 8
    dc.b    $7F,$FF,$00,$00,  $40,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$01,  $01,$00,$00,$80  ; 10
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$01,  $09,$00,$00,$80  ; 12
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 13
    dc.b    $FF,$FF,$FF,$FF,  $01,$00,$20,$80  ; 14
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 15
    dc.b    $FF,$FF,$FF,$FF,  $01,$00,$20,$80  ; 16
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 17
    dc.b    $FF,$FF,$FF,$FF,  $01,$00,$20,$80  ; 18
    dc.b    $7F,$FF,$00,$00,  $40,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$01,  $01,$00,$00,$80  ; 20
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$01,  $09,$00,$00,$80  ; 22
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 23
    dc.b    $FF,$FF,$FF,$FF,  $01,$00,$20,$80  ; 24
