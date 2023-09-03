    include "../../fpureg.i"

DUMP    MACRO
        fmove   FPSR,12(a2)
        fmove.x FP0,(a2)
        add     #16,a2
        fmove   FPSR,12(a2)
        fmove.x FP1,(a2)
        add     #16,a2
        ENDM

TEST    MACRO
        movem.l d0/d1/a2/a3,-(a7) 

        lea     values,a2

        ; 1+2: 
        fmovecr #$00,FP0
        fsincos FP0,FP0:FP1
        DUMP 

        ; 3+4: 
        fmovecr #$0C,FP1
        fsincos FP1,FP0:FP1
        DUMP 

        ; 5+6: 
        fmovecr #$0D,FP2
        fsincos FP2,FP0:FP1
        DUMP 

        ; 7+8: 
        fmovecr #$0E,FP3
        fsincos FP3,FP1:FP0
        DUMP 

        ; 9+10: 
        fmovecr #$30,FP4
        fsincos FP4,FP0:FP0
        DUMP 

        ; 11+12: 
        fmovecr #$31,FP5
        fsincos FP5,FP1:FP1
        DUMP 

        movem.l (a7)+,d0/d1/a2/a3
        ENDM

trap0:
    fmove   #$40,FPCR   ; Precision: Single, Rounding: To nearest
    TEST
    rte

info: 
    dc.b    'FSINCOS1', 0
    even 

expected:
    dc.b    $BF,$FF,$00,$00,  $80,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $08,$00,$02,$08  ; 2
    dc.b    $BF,$E7,$00,$00,  $BB,$BD,$2E,$00  ; 3
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$08  ; 4
    dc.b    $BF,$FE,$00,$00,  $E9,$67,$64,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 6
    dc.b    $3F,$FD,$00,$00,  $D2,$51,$EF,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 8
    dc.b    $3F,$FC,$00,$00,  $82,$D1,$38,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 10
    dc.b    $3F,$FE,$00,$00,  $FD,$E7,$04,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 12
    dc.b    $3F,$FD,$00,$00,  $D7,$6F,$3B,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 14
    dc.b    $3F,$FE,$00,$00,  $E8,$3C,$1B,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 16
    dc.b    $3F,$FE,$00,$00,  $A3,$92,$F7,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 18
    dc.b    $3F,$FE,$00,$00,  $E8,$3C,$1B,$00  ; 19
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 20
    dc.b    $3F,$FE,$00,$00,  $A3,$92,$F7,$00  ; 21
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 22
    dc.b    $3F,$FE,$00,$00,  $BE,$75,$7E,$00  ; 23
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 24
