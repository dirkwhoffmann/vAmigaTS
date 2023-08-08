	include "../../fpureg.i"

DUMP    MACRO
        fmovecr #$00,FP0
        fmove.l #$00,FPCR
        fmove.x FP0,(a2)+
        fmove   FPSR,(a2)+
        ENDM

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 
    fmove.l #$0,FPCR
    fmove.l #$0,FPSR

    fmove.l #$00,FPCR   ; 1+2
    DUMP
    fmove.l #$10,FPCR   ; 3+4
    DUMP
    fmove.l #$20,FPCR   ; 5+6
    DUMP
    fmove.l #$30,FPCR   ; 7+8
    DUMP

    fmove.l #$40,FPCR   ; 9+10
    DUMP
    fmove.l #$50,FPCR   ; 11+12
    DUMP
    fmove.l #$60,FPCR   ; 13+14
    DUMP
    fmove.l #$70,FPCR   ; 15+16
    DUMP

    fmove.l #$80,FPCR   ; 17+18
    DUMP
    fmove.l #$90,FPCR   ; 19+20
    DUMP
    fmove.l #$A0,FPCR   ; 21+22
    DUMP
    fmove.l #$B0,FPCR   ; 23+24
    DUMP

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'PRECISION1', 0
    even 

expected:
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 1
    dc.b    $21,$68,$C2,$35,  $00,$00,$00,$08  ; 2
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 3
    dc.b    $21,$68,$C2,$34,  $00,$00,$00,$08  ; 4
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 5
    dc.b    $21,$68,$C2,$34,  $00,$00,$00,$08  ; 6
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 7
    dc.b    $21,$68,$C2,$35,  $00,$00,$00,$08  ; 8
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DB,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 10
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 12
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 14
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DB,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 16
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 17
    dc.b    $21,$68,$C0,$00,  $00,$00,$00,$08  ; 18
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 19
    dc.b    $21,$68,$C0,$00,  $00,$00,$00,$08  ; 20
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 21
    dc.b    $21,$68,$C0,$00,  $00,$00,$00,$08  ; 22
    dc.b    $40,$00,$00,$00,  $C9,$0F,$DA,$A2  ; 23
    dc.b    $21,$68,$C8,$00,  $00,$00,$00,$08  ; 24
