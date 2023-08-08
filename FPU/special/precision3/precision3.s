	include "../../fpureg.i"


INIT    MACRO
        fmove.l #$00,FPCR
        fmovecr #$00,FP0
        ENDM

DUMP    MACRO
        fmovem  FP0,(a2)
        fmove.l FPSR,12(a2)
        add.l   #16,a2
        ENDM

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 
    fmove.l #$0,FPSR

    INIT
    fmove.l #$00,FPCR   ; 1+2
    DUMP

    INIT
    fmove.l #$10,FPCR   ; 3+4
    DUMP

    INIT
    fmove.l #$20,FPCR   ; 5+6
    DUMP

    INIT
    fmove.l #$30,FPCR   ; 7+8
    DUMP

    INIT
    fmove.l #$40,FPCR   ; 9+10
    DUMP

    INIT
    fmove.l #$50,FPCR   ; 11+12
    DUMP

    INIT
    fmove.l #$60,FPCR   ; 13+14
    DUMP

    INIT
    fmove.l #$70,FPCR   ; 15+16
    DUMP

    INIT
    fmove.l #$80,FPCR   ; 17+18
    DUMP

    INIT
    fmove.l #$90,FPCR   ; 19+20
    DUMP

    INIT
    fmove.l #$A0,FPCR   ; 21+22
    DUMP

    INIT
    fmove.l #$B0,FPCR   ; 23+24
    DUMP

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'PRECISION3', 0
    even 

expected:
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 1
    dc.b    $21,$68,$C2,$35,  $00,$00,$02,$08  ; 2
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 3
    dc.b    $21,$68,$C2,$35,  $00,$00,$02,$08  ; 4
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 5
    dc.b    $21,$68,$C2,$35,  $00,$00,$02,$08  ; 6
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 7
    dc.b    $21,$68,$C2,$35,  $00,$00,$02,$08  ; 8
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 9
    dc.b    $21,$68,$C2,$35,  $00,$00,$02,$08  ; 10
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 11
    dc.b    $21,$68,$C2,$35,  $00,$00,$02,$08  ; 12
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 13
    dc.b    $21,$68,$C2,$35,  $00,$00,$02,$08  ; 14
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 15
    dc.b    $21,$68,$C2,$35,  $00,$00,$02,$08  ; 16
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 17
    dc.b    $21,$68,$C2,$35,  $00,$00,$02,$08  ; 18
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 19
    dc.b    $21,$68,$C2,$35,  $00,$00,$02,$08  ; 20
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 21
    dc.b    $21,$68,$C2,$35,  $00,$00,$02,$08  ; 22
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 23
    dc.b    $21,$68,$C2,$35,  $00,$00,$02,$08  ; 24
