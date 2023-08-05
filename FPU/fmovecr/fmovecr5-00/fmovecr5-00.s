	include "../../fpureg.i"

WRITE   MACRO
        fmove.x FP0,(a2)
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
    fmovecr.x #$1C,FP0
    WRITE

    fmovecr.x #$1D,FP0
    WRITE

    fmovecr.x #$1E,FP0
    WRITE

    fmovecr.x #$1F,FP0
    WRITE

    fmovecr.x #$20,FP0
    WRITE

    fmovecr.x #$21,FP0
    WRITE

    fmovecr.x #$22,FP0
    WRITE

    fmovecr.x #$23,FP0
    WRITE

    fmovecr.x #$24,FP0
    WRITE

    fmovecr.x #$25,FP0
    WRITE

    fmovecr.x #$26,FP0
    WRITE

    fmovecr.x #$27,FP0
    WRITE

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'FMOVECR5-00', 0
    even 

expected:
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 2
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 4
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 5
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 6
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 7
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 8
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 10
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 12
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 14
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 16
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 18
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 20
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 22
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 24
