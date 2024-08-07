    include "../../fpureg.i"
	include "../../arith1.i"

trap0:
    fmove   #$40,FPCR   ; Precision: Single, Rounding: To nearest
    TEST    ftentox
    rte

info: 
    dc.b    'FTENTOX1', 0
    even 

expected:
    dc.b    $3F,$FF,$00,$00,  $80,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 2
    dc.b    $3F,$FF,$00,$00,  $80,$00,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 4
    dc.b    $40,$02,$00,$00,  $A0,$00,$00,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 6
    dc.b    $3F,$FB,$00,$00,  $CC,$CC,$CD,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 8
    dc.b    $40,$05,$00,$00,  $C8,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 10
    dc.b    $3F,$F8,$00,$00,  $A3,$D7,$0A,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 12
    dc.b    $40,$00,$00,$00,  $CA,$62,$C2,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 14
    dc.b    $3F,$FD,$00,$00,  $A1,$E8,$9B,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 16
    dc.b    $3F,$FF,$00,$00,  $A1,$24,$78,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 18
    dc.b    $3F,$FE,$00,$00,  $CB,$59,$18,$00  ; 19
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 20
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $02,$00,$12,$48  ; 22
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $04,$00,$0A,$68  ; 24
