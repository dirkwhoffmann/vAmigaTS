	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 
    moveq   #0,d0       ; FPCR payload 

    ; Setup control register
    fmove.l d0,FPCR

    lea     values,a2 

    fmove.b #$FF,FP1
    fmove.b FP1,(a2)+

    fmove.w #$FFFF,FP2
    fmove.w FP2,(a2)+

    fmove.l #$FFFFFFFF,FP3
    fmove.l FP3,(a2)+

    fmove.s #$FFFFFFFF,FP4
    fmove.s FP4,(a2)+

    fmove.d #$FFFFFFFFFFFFFFFF,FP5
    fmove.d FP5,(a2)+

    fmove.x #$FFFFFFFFFFFFFFFFFFFFFFFF,FP6
    fmove.x FP6,(a2)+

    fmove.p #$FFFFFFFFFFFFFFFFFFFFFFFF,FP7
    fmove.p FP7,(a2)+

    lea     values+192,a2 

    fmove.b #$87,FP1
    fmove.b FP1,-(a2)

    fmove.w #$8765,FP2
    fmove.w FP2,-(a2)

    fmove.l #$87654321,FP3
    fmove.l FP3,-(a2)

    fmove.s #$87654321,FP4
    fmove.s FP4,-(a2)

    fmove.d #$8765432187654321,FP5
    fmove.d FP5,-(a2)

    fmove.x #$876543218765432187654321,FP6
    fmove.x FP6,-(a2)

    fmove.p #$876543218765432187654321,FP7
    fmove.p FP7,-(a2)

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'FMOVE3-PIPD', 0
    even 

expected:
    dc.b    $FF,$FF,$FF,$FF,  $FF,$FF,$FF,$FF  ; 1
    dc.b    $FF,$FF,$FF,$FF,  $FF,$FF,$FF,$FF  ; 2
    dc.b    $FF,$FF,$FF,$FF,  $FF,$00,$00,$FF  ; 3
    dc.b    $FF,$FF,$FF,$FF,  $FF,$FF,$FF,$FF  ; 4
    dc.b    $FF,$00,$00,$FF,  $FF,$FF,$FF,$FF  ; 5
    dc.b    $FF,$FF,$FF,$00,  $00,$00,$00,$00  ; 6
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 8
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 10
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 12
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 14
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 16
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 18
    dc.b    $00,$00,$00,$00,  $00,$87,$65,$00  ; 19
    dc.b    $01,$87,$65,$43,  $21,$87,$65,$43  ; 20
    dc.b    $21,$87,$65,$00,  $00,$87,$65,$43  ; 21
    dc.b    $21,$87,$65,$43,  $21,$87,$65,$43  ; 22
    dc.b    $21,$87,$65,$43,  $21,$87,$65,$43  ; 23
    dc.b    $21,$87,$65,$43,  $21,$87,$65,$87  ; 24
