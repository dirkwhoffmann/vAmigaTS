    include "../../fpureg.i"
    include "../../dyadic1.i"

trap0:
    fmove   #$40,FPCR   ; Precision: Single, Rounding: To nearest
    TEST    fsgldiv
    rte

info: 
    dc.b    'FSGLDIV1', 0
    even 

expected:
    dc.b    $40,$05,$00,$00,  $F9,$40,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 2
    dc.b    $40,$05,$00,$00,  $F9,$40,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 4
    dc.b    $3F,$FF,$00,$00,  $80,$00,$00,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 6
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DB,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 8
    dc.b    $C0,$00,$00,$00,  $C9,$0F,$DB,$00  ; 9
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$08  ; 10
    dc.b    $BF,$FD,$00,$00,  $A2,$F9,$83,$00  ; 11
    dc.b    $00,$00,$00,$00,  $08,$00,$02,$08  ; 12
    dc.b    $3F,$FD,$00,$00,  $A2,$F9,$83,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 14
    dc.b    $BF,$FF,$00,$00,  $80,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$08  ; 16
    dc.b    $C0,$07,$00,$00,  $C3,$C2,$B0,$00  ; 17
    dc.b    $00,$00,$00,$00,  $08,$00,$02,$08  ; 18
    dc.b    $C0,$00,$00,$00,  $C9,$0F,$DB,$00  ; 19
    dc.b    $00,$00,$00,$00,  $08,$00,$02,$08  ; 20
    dc.b    $3F,$FF,$00,$00,  $80,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 22
    dc.b    $3F,$FF,$00,$00,  $80,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 24
