	include "../../fpureg.i"

DUMP    MACRO
        fmove   FPSR,12(a2)
        fmove.x FP0,(a2)
        add     #16,a2
        ENDM

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 

    ; Setup control register
    fmove.l 0,FPCR

    ; 1+2: Denormalized number (sign bit = 0)
    fmove.x #$000000001234123412341234,FP0
    DUMP 

    ; 3+4: Denormalized number (sign bit = 1)
    fmove.x #$800000001234123412341234,FP0
    DUMP 

    ; 5+6: Zero exponent, MSB of mantissa != 0
    fmove.x #$000000008000000000000000,FP0
    DUMP 

    ; 7+8: Unnormalized number (exponent != 0)
    fmove.x #$400000001234123412341234,FP0
    DUMP 

    ; 9+10: Zero (sign bit = 0)
    fmove.x #$000000000000000000000000,FP0
    DUMP 

    ; 11+12: Zero (sign bit = 1)
    fmove.x #$800000000000000000000000,FP0
    DUMP 

    ; 13+14: Infinity (sign bit = 0)
    fmove.x #$7FFF00000000000000000000,FP0
    DUMP 

    ; 15+16: Infinity (sign bit = 1)
    fmove.x #$FFFF00000000000000000000,FP0
    DUMP 

    ; 17+18: Signaling NaN (sign bit = 0)
    fmove.x #$7FFF00000000000000000001,FP0
    DUMP 

    ; 19+20: Nonsignaling NaN (sign bit = 0)
    fmove.x #$7FFF00004000000000000000,FP0
    DUMP 

    ; 21+22: Signaling NaN (sign bit = 1)
    fmove.x #$FFFF00000000000000000001,FP0
    DUMP 

    ; 23+24: Nonsignaling NaN (sign bit = 1)
    fmove.x #$FFFF00004000000000000001,FP0
    DUMP 

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'SPECIAL1-X', 0
    even 

expected:
    dc.b    $00,$00,$00,$00,  $12,$34,$12,$34  ; 1
    dc.b    $12,$34,$12,$34,  $00,$00,$08,$00  ; 2
    dc.b    $80,$00,$00,$00,  $12,$34,$12,$34  ; 3
    dc.b    $12,$34,$12,$34,  $08,$00,$08,$00  ; 4
    dc.b    $00,$00,$00,$00,  $80,$00,$00,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 6
    dc.b    $3F,$FD,$00,$00,  $91,$A0,$91,$A0  ; 7
    dc.b    $91,$A0,$91,$A0,  $00,$00,$00,$00  ; 8
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 10
    dc.b    $80,$00,$00,$00,  $00,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $0C,$00,$00,$00  ; 12
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $02,$00,$00,$00  ; 14
    dc.b    $FF,$FF,$00,$00,  $00,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $0A,$00,$00,$00  ; 16
    dc.b    $7F,$FF,$00,$00,  $40,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$01,  $01,$00,$40,$80  ; 18
    dc.b    $7F,$FF,$00,$00,  $40,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $01,$00,$00,$80  ; 20
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$01,  $09,$00,$40,$80  ; 22
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$01,  $09,$00,$00,$80  ; 24
