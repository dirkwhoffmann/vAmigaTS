	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 
    moveq   #0,d0       ; FPCR payload 

    ; Setup control register
    fmove.l d0,FPCR

    lea     values,a2 

    ; 1+2     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$112233445566778899001122,FP1
    fmove.x FP1,(a2)+
    addq    #4,a2

    ; 3+4     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$023400012345678900000000,FP2
    fmove.x FP2,(a2)+
    addq    #4,a2

    ; 5+6     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$011100112345678912345678,FP3
    fmove.x FP3,(a2)+
    addq    #4,a2

    ; 7+8     SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$0111DEF12345678912345678,FP4
    fmove.x FP4,(a2)+
    addq    #4,a2

    ; 9+10    SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$0123000123456789ABCDEF01,FP5
    fmove.x FP5,(a2)+
    addq    #4,a2

    ; 11+12   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$01F3000123456789ABCDEF01,FP6
    fmove.x FP6,(a2)+
    addq    #4,a2

    ; 13+14   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$0DEF00054321000000000000,FP7
    fmove.x FP7,(a2)+
    addq    #4,a2

    ; 15+16   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$012300098765432100000000,FP0
    fmove.x FP0,(a2)+
    addq    #4,a2

    ; 17+18   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$112300098765432100000000,FP1
    fmove.x FP1,(a2)+
    addq    #4,a2

    ; 19+20   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$212300098765432100000000,FP2
    fmove.x FP2,(a2)+
    addq    #4,a2

    ; 21+22   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$312300098765432100000000,FP3
    fmove.x FP3,(a2)+
    addq    #4,a2

    ; 23+24   SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$512300098765432100000000,FP4
    fmove.x FP4,(a2)+
    addq    #4,a2

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'PACKED3', 0
    even 

expected:
    dc.b    $41,$96,$00,$00,  $B0,$76,$27,$74  ; 1
    dc.b    $B9,$0D,$98,$7C,  $00,$00,$00,$00  ; 2
    dc.b    $43,$08,$00,$00,  $C6,$CD,$06,$DF  ; 3
    dc.b    $C9,$4E,$BB,$58,  $00,$00,$00,$00  ; 4
    dc.b    $41,$70,$00,$00,  $83,$6B,$23,$A2  ; 5
    dc.b    $E1,$39,$24,$E6,  $00,$00,$00,$00  ; 6
    dc.b    $41,$70,$00,$00,  $83,$6B,$23,$A2  ; 7
    dc.b    $E1,$39,$24,$E6,  $00,$00,$00,$00  ; 8
    dc.b    $41,$97,$00,$00,  $EF,$0C,$83,$A3  ; 9
    dc.b    $43,$A1,$2B,$0D,  $00,$00,$00,$00  ; 10
    dc.b    $43,$47,$00,$00,  $D7,$8A,$54,$AD  ; 11
    dc.b    $F9,$A2,$A8,$E0,  $00,$00,$00,$00  ; 12
    dc.b    $52,$E2,$00,$00,  $E6,$39,$15,$E5  ; 13
    dc.b    $02,$76,$FA,$B4,  $00,$00,$00,$00  ; 14
    dc.b    $41,$9A,$00,$00,  $EF,$0C,$83,$A3  ; 15
    dc.b    $50,$7A,$6B,$BD,  $00,$00,$00,$00  ; 16
    dc.b    $41,$9A,$00,$00,  $EF,$0C,$83,$A3  ; 17
    dc.b    $50,$7A,$6B,$BD,  $00,$00,$00,$00  ; 18
    dc.b    $41,$9A,$00,$00,  $EF,$0C,$83,$A3  ; 19
    dc.b    $50,$7A,$6B,$BD,  $00,$00,$00,$00  ; 20
    dc.b    $41,$9A,$00,$00,  $EF,$0C,$83,$A3  ; 21
    dc.b    $50,$7A,$6B,$BD,  $00,$00,$00,$00  ; 22
    dc.b    $3E,$69,$00,$00,  $D0,$ED,$24,$05  ; 23
    dc.b    $40,$DA,$D3,$16,  $00,$00,$00,$00  ; 24
