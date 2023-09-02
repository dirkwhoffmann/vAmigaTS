    include "../../fpureg.i"
    include "../../dyadic3.i"

trap0:
    fmove   #$40,FPCR   ; Precision: Single, Rounding: To nearest
    TEST    fmul
    rte

info: 
    dc.b    'FMUL3', 0
    even 

expected:
    dc.b    $FF,$FF,$00,$00,  $00,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $0A,$00,$00,$80  ; 2
    dc.b    $7F,$FF,$00,$00,  $40,$00,$00,$00  ; 3
    dc.b    $00,$00,$00,$01,  $01,$00,$00,$80  ; 4
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 5
    dc.b    $00,$00,$00,$01,  $09,$00,$00,$80  ; 6
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 7
    dc.b    $00,$00,$00,$00,  $02,$00,$00,$80  ; 8
    dc.b    $7F,$FF,$00,$00,  $40,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$01,  $01,$00,$00,$80  ; 10
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$01,  $09,$00,$00,$80  ; 12
    dc.b    $7F,$FF,$00,$00,  $40,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$01,  $01,$00,$00,$80  ; 14
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$01,  $09,$00,$00,$80  ; 16
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$01,  $09,$00,$00,$80  ; 18
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 20
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 22
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 24
