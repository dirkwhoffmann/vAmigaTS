    include "../../fpureg.i"
	include "../../arith2.i"

trap0:
    fmove   #$40,FPCR   ; Precision: Single, Rounding: To nearest
    TEST    facos
    rte

info: 
    dc.b    'FACOS2', 0
    even 

expected:
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 1
    dc.b    $FF,$FF,$FF,$FF,  $01,$00,$20,$88  ; 2
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 3
    dc.b    $FF,$FF,$FF,$FF,  $01,$00,$20,$88  ; 4
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 5
    dc.b    $FF,$FF,$FF,$FF,  $01,$00,$20,$88  ; 6
    dc.b    $3F,$FF,$00,$00,  $8F,$8E,$AB,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$88  ; 8
    dc.b    $3F,$FE,$00,$00,  $CE,$11,$36,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$88  ; 10
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 11
    dc.b    $FF,$FF,$FF,$FF,  $01,$00,$20,$88  ; 12
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
