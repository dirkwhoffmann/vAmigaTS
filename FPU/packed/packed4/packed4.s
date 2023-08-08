	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 
    moveq   #0,d0       ; FPCR payload 

    ; Setup control register
    fmove.l d0,FPCR

    lea     values,a2 

    ; 1+2     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000000090000000000000000,FP1
    fmove.x FP1,(a2)+
    addq    #4,a2

    ; 3+4     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$0000000A0000000000000000,FP2
    fmove.x FP2,(a2)+
    addq    #4,a2

    ; 5+6     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$0000000B0000000000000000,FP3
    fmove.x FP3,(a2)+
    addq    #4,a2

    ; 7+8     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$0000000C0000000000000000,FP4
    fmove.x FP4,(a2)+
    addq    #4,a2

    ; 9+10    SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$0000000D0000000000000000,FP5
    fmove.x FP5,(a2)+
    addq    #4,a2

    ; 11+12   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$0000000E0000000000000000,FP6
    fmove.x FP6,(a2)+
    addq    #4,a2

    ; 13+14   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$0000000F0000000000000000,FP7
    fmove.x FP7,(a2)+
    addq    #4,a2

    ; 15+16   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000000015000000000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 17+18   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000000019000000000000000,FP1
    fmove.x FP1,(a2)+
    addq    #4,a2

    ; 19+20   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$00000001A000000000000000,FP2
    fmove.x FP2,(a2)+
    addq    #4,a2

    ; 21+22   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$00000001B000000000000000,FP3
    fmove.x FP3,(a2)+
    addq    #4,a2

    ; 23+24   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$00000001F000000000000000,FP4
    fmove.x FP4,(a2)+
    addq    #4,a2

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'PACKED4', 0
    even 

expected:
    dc.b    $40,$02,$00,$00,  $90,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 2
    dc.b    $40,$02,$00,$00,  $A0,$00,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 4
    dc.b    $40,$02,$00,$00,  $B0,$00,$00,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 6
    dc.b    $40,$02,$00,$00,  $C0,$00,$00,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 8
    dc.b    $40,$02,$00,$00,  $D0,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 10
    dc.b    $40,$02,$00,$00,  $E0,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 12
    dc.b    $40,$02,$00,$00,  $F0,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 14
    dc.b    $3F,$FF,$00,$00,  $C0,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 16
    dc.b    $3F,$FF,$00,$00,  $F3,$33,$33,$33  ; 17
    dc.b    $33,$33,$33,$33,  $00,$00,$00,$00  ; 18
    dc.b    $40,$00,$00,$00,  $80,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 20
    dc.b    $40,$00,$00,$00,  $86,$66,$66,$66  ; 21
    dc.b    $66,$66,$66,$66,  $00,$00,$00,$00  ; 22
    dc.b    $40,$00,$00,$00,  $A0,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 24
