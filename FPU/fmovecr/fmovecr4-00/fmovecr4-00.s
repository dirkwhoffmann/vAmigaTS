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
    fmovecr.x #$10,FP0
    WRITE

    fmovecr.x #$11,FP0
    WRITE

    fmovecr.x #$12,FP0
    WRITE

    fmovecr.x #$13,FP0
    WRITE

    fmovecr.x #$14,FP0
    WRITE

    fmovecr.x #$15,FP0
    WRITE

    fmovecr.x #$16,FP0
    WRITE

    fmovecr.x #$17,FP0
    WRITE

    fmovecr.x #$18,FP0
    WRITE

    fmovecr.x #$19,FP0
    WRITE

    fmovecr.x #$1A,FP0
    WRITE

    fmovecr.x #$1B,FP0
    WRITE

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'FMOVECR4-00', 0
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
