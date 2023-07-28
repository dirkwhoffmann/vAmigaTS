	include "../../fpureg.i"

WRITE   MACRO
        fmove.x FP0,(a2)
        fmove   FPCR,8(a2)
        fmove   FPSR,12(a2)
        add     #16,a2
        ENDM

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 
    moveq   #20,d1      ; Loop counter
    moveq   #0,d0       ; FPCR payload 

.loop:

    ; Setup control register
    fmove.l d0,FPCR

    ; Read constants
    fmovecr.x #$36,FP0
    WRITE

    fmovecr.x #$37,FP0
    WRITE

    fmovecr.x #$38,FP0
    WRITE
    fmovecr.x #$39,FP0
    WRITE

    fmovecr.x #$3A,FP0
    WRITE

    fmovecr.x #$3B,FP0
    WRITE

    fmovecr.x #$3C,FP0
    WRITE

    fmovecr.x #$3D,FP0
    WRITE

    fmovecr.x #$3E,FP0
    WRITE

    fmovecr.x #$3F,FP0
    WRITE

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'FMOVECR2', 0
    even 

expected:
    dc.b    $40,$19,$00,$00,  $BE,$BC,$20,$00  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 2
    dc.b    $40,$34,$00,$00,  $8E,$1B,$C9,$BF  ; 3
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 4
    dc.b    $40,$69,$00,$00,  $9D,$C5,$AD,$A8  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 6
    dc.b    $40,$D3,$00,$00,  $C2,$78,$1F,$49  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 8
    dc.b    $41,$A8,$00,$00,  $93,$BA,$47,$C9  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 10
    dc.b    $43,$51,$00,$00,  $AA,$7E,$EB,$FB  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 12
    dc.b    $46,$A3,$00,$00,  $E3,$19,$A0,$AE  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 14
    dc.b    $4D,$48,$00,$00,  $C9,$76,$75,$86  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 16
    dc.b    $5A,$92,$00,$00,  $9E,$8B,$3B,$5D  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 18
    dc.b    $75,$25,$00,$00,  $C4,$60,$52,$02  ; 19
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 20
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 22
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 24
