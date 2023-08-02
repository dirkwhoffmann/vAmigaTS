	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 
    moveq   #0,d0       ; FPCR payload 

    ; Setup control register
    fmove.l d0,FPCR

    lea     values,a2 

    ; 1+2     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000000050000000000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 3+4     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000000025000000000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 5+6     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000000012500000000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 7+8     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000100050000000000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 9+10    SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000100025000000000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 11+12   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000100012500000000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 13+14   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$011100050000000000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 15+16   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$011100025000000000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 17+18   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$011100012500000000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 19+20   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$110100050000000000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 21+22   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$110100025000000000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 23+24   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$110100012500000000000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'PACKED2', 0
    even 

expected:
    dc.b    $40,$01,$00,$00,  $A0,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 2
    dc.b    $40,$00,$00,$00,  $A0,$00,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 4
    dc.b    $3F,$FF,$00,$00,  $A0,$00,$00,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 6
    dc.b    $40,$04,$00,$00,  $C8,$00,$00,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 8
    dc.b    $40,$03,$00,$00,  $C8,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 10
    dc.b    $40,$02,$00,$00,  $C8,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 12
    dc.b    $41,$72,$00,$00,  $85,$0F,$AD,$C0  ; 13
    dc.b    $99,$23,$32,$9E,  $00,$00,$00,$00  ; 14
    dc.b    $41,$71,$00,$00,  $85,$0F,$AD,$C0  ; 15
    dc.b    $99,$23,$32,$9E,  $00,$00,$00,$00  ; 16
    dc.b    $41,$70,$00,$00,  $85,$0F,$AD,$C0  ; 17
    dc.b    $99,$23,$32,$9E,  $00,$00,$00,$00  ; 18
    dc.b    $41,$50,$00,$00,  $E4,$98,$F4,$55  ; 19
    dc.b    $C3,$8B,$99,$7A,  $00,$00,$00,$00  ; 20
    dc.b    $41,$4F,$00,$00,  $E4,$98,$F4,$55  ; 21
    dc.b    $C3,$8B,$99,$7A,  $00,$00,$00,$00  ; 22
    dc.b    $41,$4E,$00,$00,  $E4,$98,$F4,$55  ; 23
    dc.b    $C3,$8B,$99,$7A,  $00,$00,$00,$00  ; 24
