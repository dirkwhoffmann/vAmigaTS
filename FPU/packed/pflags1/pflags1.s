	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 
    moveq   #0,d0       ; FPCR payload 

    ; Setup control register
    fmove.l d0,FPCR

    lea     values,a2 

    ; 1+2     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000000005000000000000000,FP1
    fmove.x FP1,(a2)+
    fmove   FPSR,(a2)+

    ; 3+4     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000000000019531250000000,FP2
    fmove.x FP2,(a2)+
    fmove   FPSR,(a2)+

    ; 5+6     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000100000019531250000000,FP3
    fmove.x FP3,(a2)+
    fmove   FPSR,(a2)+

    ; 7+8     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000200000019531250000000,FP4
    fmove.x FP4,(a2)+
    fmove   FPSR,(a2)+

    ; 9+10    SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000300000019531250000000,FP5
    fmove.x FP5,(a2)+
    fmove   FPSR,(a2)+

    ; 11+12   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000500000019531250000000,FP6
    fmove.x FP6,(a2)+
    fmove   FPSR,(a2)+

    ; 13+14   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$100100000019531250000000,FP7
    fmove.x FP7,(a2)+
    fmove   FPSR,(a2)+

    ; 15+16   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$100200000019531250000000,FP0
    fmove.x FP0,(a2)+
    fmove   FPSR,(a2)+

    ; 17+18   BEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000000010000000000000000,FP1
    fmove.x FP1,(a2)+
    fmove   FPSR,(a2)+

    ; 19+20   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$FFFF00001000000000000000,FP2
    fmove.x FP2,(a2)+
    fmove   FPSR,(a2)+

    ; 21+22   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$FFFF00020000000000000001,FP3
    fmove.x FP3,(a2)+
    fmove   FPSR,(a2)+

    ; 23+24   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$FFFF00002000000000000000,FP4
    fmove.x FP4,(a2)+
    fmove   FPSR,(a2)+

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'PFLAGS1', 0
    even 

expected:
    dc.b    $3F,$FE,$00,$00,  $80,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 2
    dc.b    $3F,$F6,$00,$00,  $80,$00,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 4
    dc.b    $3F,$F9,$00,$00,  $A0,$00,$00,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 6
    dc.b    $3F,$FC,$00,$00,  $C8,$00,$00,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 8
    dc.b    $3F,$FF,$00,$00,  $FA,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 10
    dc.b    $40,$06,$00,$00,  $C3,$50,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 12
    dc.b    $3F,$F9,$00,$00,  $A0,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 14
    dc.b    $3F,$FC,$00,$00,  $C8,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 16
    dc.b    $3F,$FF,$00,$00,  $80,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 18
    dc.b    $FF,$FF,$00,$00,  $50,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $09,$00,$00,$80  ; 20
    dc.b    $FF,$FF,$00,$00,  $40,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$01,  $09,$00,$00,$80  ; 22
    dc.b    $FF,$FF,$00,$00,  $60,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $09,$00,$00,$80  ; 24
