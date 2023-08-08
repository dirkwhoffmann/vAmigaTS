	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 
    moveq   #0,d0       ; FPCR payload 

    ; Setup control register
    fmove.l d0,FPCR

    lea     values,a2 

    ; 1+2     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$3FFF00000000000000000000,FP1
    fmove.x FP1,(a2)+
    addq    #4,a2

    ; 3+4     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$3FFF00000000000000000001,FP2
    fmove.x FP2,(a2)+
    addq    #4,a2

    ; 5+6     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$3FFF00080000000000000000,FP3
    fmove.x FP3,(a2)+
    addq    #4,a2

    ; 7+8     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$7FFF00000000000000000000,FP4
    fmove.x FP4,(a2)+
    addq    #4,a2

    ; 9+10    SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$7FFF00000000000000000001,FP5
    fmove.x FP5,(a2)+
    addq    #4,a2

    ; 11+12   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$7FFF00080000000000000000,FP6
    fmove.x FP6,(a2)+
    addq    #4,a2

    ; 13+14   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$BFFF00000000000000000000,FP7
    fmove.x FP7,(a2)+
    addq    #4,a2

    ; 15+16   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$BFFF00000000000000000001,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 17+18   BEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$AFFF00080000000000000000,FP1
    fmove.x FP1,(a2)+
    addq    #4,a2

    ; 19+20   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$FFFF00000000000000000000,FP2
    fmove.x FP2,(a2)+
    addq    #4,a2

    ; 21+22   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$FFFF00000000000000000001,FP3
    fmove.x FP3,(a2)+
    addq    #4,a2

    ; 23+24   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$FFFF00080000000000000000,FP4
    fmove.x FP4,(a2)+
    addq    #4,a2

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'PACKED6', 0
    even 

expected:
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 2
    dc.b    $55,$64,$00,$00,  $E8,$3B,$9E,$5F  ; 3
    dc.b    $93,$0D,$3E,$5A,  $00,$00,$00,$00  ; 4
    dc.b    $55,$9D,$00,$00,  $80,$EA,$47,$26  ; 5
    dc.b    $CF,$1A,$FD,$38,  $00,$00,$00,$00  ; 6
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 8
    dc.b    $7F,$FF,$00,$00,  $40,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$01,  $00,$00,$00,$00  ; 10
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 12
    dc.b    $80,$00,$00,$00,  $00,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 14
    dc.b    $D5,$64,$00,$00,  $E8,$3B,$9E,$5F  ; 15
    dc.b    $93,$0D,$3E,$5A,  $00,$00,$00,$00  ; 16
    dc.b    $D5,$9D,$00,$00,  $80,$EA,$47,$26  ; 17
    dc.b    $CF,$1A,$FD,$38,  $00,$00,$00,$00  ; 18
    dc.b    $FF,$FF,$00,$00,  $00,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 20
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$01,  $00,$00,$00,$00  ; 22
    dc.b    $FF,$FF,$00,$00,  $00,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 24
