	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 

    fmove.l #$00,FPCR

    ; 1+2     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$800200012346250000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 3+4     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$800300012346250000000000,FP1
    fmove.x FP1,(a2)+
    addq    #4,a2

    ; 5+6     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$800400012346250000000000,FP2
    fmove.x FP2,(a2)+
    addq    #4,a2

    fmove.l #$10,FPCR

    ; 7+8     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$800200012346250000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 9+10    SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$800300012346250000000000,FP1
    fmove.x FP1,(a2)+
    addq    #4,a2

    ; 11+12   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$800400012346250000000000,FP2
    fmove.x FP2,(a2)+
    addq    #4,a2

    fmove.l #$20,FPCR

    ; 13+14   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$800200012346250000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 15+16   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$800300012346250000000000,FP1
    fmove.x FP1,(a2)+
    addq    #4,a2

    ; 17+18   BEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$800400012346250000000000,FP2
    fmove.x FP2,(a2)+
    addq    #4,a2

    fmove.l #$30,FPCR

    ; 19+20   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$800200012346250000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 21+22   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$800300012346250000000000,FP1
    fmove.x FP1,(a2)+
    addq    #4,a2

    ; 23+24   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$800400012346250000000000,FP2
    fmove.x FP2,(a2)+
    addq    #4,a2

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'PACKED7', 0
    even 

expected:
    dc.b    $C0,$05,$00,$00,  $F6,$EC,$CC,$CC  ; 1
    dc.b    $CC,$CC,$CC,$CD,  $00,$00,$00,$00  ; 2
    dc.b    $C0,$09,$00,$00,  $9A,$54,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 4
    dc.b    $C0,$0C,$00,$00,  $C0,$E9,$00,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 6
    dc.b    $C0,$05,$00,$00,  $F6,$EC,$CC,$CC  ; 7
    dc.b    $CC,$CC,$CC,$CC,  $00,$00,$00,$00  ; 8
    dc.b    $C0,$09,$00,$00,  $9A,$54,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 10
    dc.b    $C0,$0C,$00,$00,  $C0,$E9,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 12
    dc.b    $C0,$05,$00,$00,  $F6,$EC,$CC,$CC  ; 13
    dc.b    $CC,$CC,$CC,$CD,  $00,$00,$00,$00  ; 14
    dc.b    $C0,$09,$00,$00,  $9A,$54,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 16
    dc.b    $C0,$0C,$00,$00,  $C0,$E9,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 18
    dc.b    $C0,$05,$00,$00,  $F6,$EC,$CC,$CC  ; 19
    dc.b    $CC,$CC,$CC,$CC,  $00,$00,$00,$00  ; 20
    dc.b    $C0,$09,$00,$00,  $9A,$54,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 22
    dc.b    $C0,$0C,$00,$00,  $C0,$E9,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 24
