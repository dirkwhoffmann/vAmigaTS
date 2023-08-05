	include "../../fpureg.i"

WRITE   MACRO
        fmove.x FP0,(a2)
        fmove   FPSR,12(a2)
        add     #16,a2
        ENDM

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 

.loop:

    ; Setup
    fmove.l #0,FPSR
    fmove.l #0,FPCR

    ; Read constants
    fmovecr.x #$01,FP0
    WRITE

    fmovecr.x #$02,FP0
    WRITE

    fmovecr.x #$03,FP0
    WRITE

    fmovecr.x #$04,FP0
    WRITE

    fmovecr.x #$05,FP0
    WRITE

    fmovecr.x #$06,FP0
    WRITE

    fmovecr.x #$07,FP0
    WRITE

    fmovecr.x #$08,FP0
    WRITE

    fmovecr.x #$09,FP0
    WRITE

    fmovecr.x #$0A,FP0
    WRITE

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'FMOVECR3-00', 0
    even 

expected:
    dc.b    $40,$01,$00,$00,  $FE,$00,$06,$82  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 2
    dc.b    $40,$01,$00,$00,  $FF,$C0,$05,$03  ; 3
    dc.b    $80,$00,$00,$00,  $00,$00,$00,$00  ; 4
    dc.b    $20,$00,$00,$00,  $7F,$FF,$FF,$FF  ; 5
    dc.b    $00,$00,$00,$00,  $01,$00,$00,$00  ; 6
    dc.b    $00,$00,$00,$00,  $FF,$FF,$FF,$FF  ; 7
    dc.b    $FF,$FF,$FF,$FF,  $00,$00,$00,$00  ; 8
    dc.b    $3C,$00,$00,$00,  $FF,$FF,$FF,$FF  ; 9
    dc.b    $FF,$FF,$F8,$00,  $00,$00,$00,$00  ; 10
    dc.b    $3F,$80,$00,$00,  $FF,$FF,$FF,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 12
    dc.b    $00,$01,$00,$00,  $F6,$5D,$8D,$9C  ; 13
    dc.b    $00,$00,$00,$00,  $01,$00,$00,$00  ; 14
    dc.b    $7F,$FF,$00,$00,  $40,$1E,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $01,$00,$40,$80  ; 16
    dc.b    $43,$F3,$00,$00,  $E0,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$80  ; 18
    dc.b    $40,$72,$00,$00,  $C0,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$80  ; 20
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 22
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 24
