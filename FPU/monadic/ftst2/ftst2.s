    include "../../fpureg.i"

DUMP    MACRO
        fmove   FPSR,12(a2)
        fmove.x FP0,(a2)
        add     #16,a2
        ENDM

TEST    MACRO
        movem.l d0/d1/a2/a3,-(a7) 

        lea     values,a2

        ; 1+2: 
        fmovecr #$00,FP0
        \1      FP0
        DUMP 

        ; 3+4: 
        fmovecr #$0C,FP0
        \1      FP0
        DUMP 

        ; 5+6: 
        fmovecr #$0D,FP0
        \1      FP0
        DUMP 

        ; 7+8: 
        fmovecr #$0E,FP0
        \1      FP0
        DUMP 

        ; 9+10: 
        fmovecr #$30,FP0
        \1      FP0
        DUMP 

        ; 11+12: 
        fmovecr #$31,FP0
        \1      FP0
        DUMP 

        ; 13+14: Infinity (sign bit = 0)
        fmove.x #$7FFF00000000000000000000,FP0
        \1      FP0
        DUMP 

        ; 15+16: Infinity (sign bit = 1)
        fmove.x #$FFFF00000000000000000000,FP0
        \1      FP0
        DUMP 

        ; 17+18: Signaling NaN (sign bit = 0)
        fmove.x #$7FFF00000000000000000001,FP0
        \1      FP0
        DUMP 

        ; 19+20: Nonsignaling NaN (sign bit = 0)
        fmove.x #$7FFF00004000000000000000,FP0
        \1      FP0
        DUMP 

        ; 21+22: Signaling NaN (sign bit = 1)
        fmove.x #$FFFF00000000000000000001,FP0
        \1      FP0
        DUMP 

        ; 23+24: Nonsignaling NaN (sign bit = 1)
        fmove.x #$FFFF00004000000000000001,FP0
        \1      FP0
        DUMP 

        movem.l (a7)+,d0/d1/a2/a3
        ENDM
        
trap0:
    fmove   #$40,FPCR   ; Precision: Single, Rounding: To nearest
    TEST    ftst
    rte

info: 
    dc.b    'FTST2', 0
    even 

expected:
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DB,$00  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 2
    dc.b    $40,$00,$00,$00,  $AD,$F8,$54,$00  ; 3
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 4
    dc.b    $3F,$FF,$00,$00,  $B8,$AA,$3B,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 6
    dc.b    $3F,$FD,$00,$00,  $DE,$5B,$D9,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 8
    dc.b    $3F,$FE,$00,$00,  $B1,$72,$18,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 10
    dc.b    $40,$00,$00,$00,  $93,$5D,$8E,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 12
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $02,$00,$00,$08  ; 14
    dc.b    $FF,$FF,$00,$00,  $00,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $0A,$00,$00,$08  ; 16
    dc.b    $7F,$FF,$00,$00,  $40,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$01,  $01,$00,$00,$88  ; 18
    dc.b    $7F,$FF,$00,$00,  $40,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $01,$00,$00,$88  ; 20
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$01,  $09,$00,$00,$88  ; 22
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$01,  $09,$00,$00,$88  ; 24
