	include "../../fpureg.i"

DUMP    MACRO
        fmove.l d0,FPSR
        ftst    FP0  
        fmove   FPSR,(a2)+
        add.l   #$87654321,d0
        ENDM

trap0:

    movem.l d0-d3/a2/a3,-(a7) 

    lea     values,a2 
    moveq   #0,d0       ; Initial value of FPSR before running FTST

    ; 1  
    fmove.x #$000000000000000000000000,FP0
    DUMP 
    fmove.x #$800000000000000000000000,FP0
    DUMP

    ; 2
    ;         SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000000010000000000000000,FP0
    DUMP
    fmove.p #$800000010000000000000000,FP0
    DUMP

    ; 3
    ;         SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000000020000000000000000,FP0
    DUMP
    fmove.p #$800000020000000000000000,FP0
    DUMP

    ; 4
    ;         SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$400100050000000000000000,FP0
    DUMP
    fmove.p #$C00100050000000000000000,FP0
    DUMP

    ; 5
    ;         SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$400100010000000000000000,FP0
    DUMP
    fmove.p #$C00100010000000000000000,FP0
    DUMP

    ; 6
    ;         SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$000200012462500000000000,FP0
    DUMP
    fmove.p #$800200012462500000000000,FP0
    DUMP 

    ; 7
    fmovecr #$00,FP0
    DUMP
    fmovecr #$0C,FP0
    DUMP 

    ; 8
    fmovecr #$0D,FP0
    DUMP 
    fmovecr #$0E,FP0
    DUMP 

    ; 9
    fmovecr #$30,FP0
    DUMP 
    fmovecr #$31,FP0
    DUMP 

    ; 10: +/- Infinity 
    fmove.x #$7FFF00000000000000000000,FP0
    DUMP 
    fmove.x #$FFFF00000000000000000000,FP0
    DUMP 

    ; 11: +/- Signaling NaN
    fmove.x #$7FFF00000000000000000001,FP0
    DUMP 
    fmove.x #$7FFF00004000000000000000,FP0
    DUMP 

    ; 12: +/- Signaling NaN
    fmove.x #$FFFF00000000000000000001,FP0
    DUMP 
    fmove.x #$FFFF00004000000000000001,FP0
    DUMP 

    movem.l (a7)+,d0-d3/a2/a3
    rte

info: 
    dc.b    'FTST1', 0
    even 

spare:
    dc.s    16,0

expected:
    dc.b    $04,$00,$00,$00,  $0C,$65,$00,$20  ; 1
    dc.b    $00,$CA,$00,$40,  $08,$2F,$00,$60  ; 2
    dc.b    $00,$95,$00,$80,  $08,$FA,$00,$A0  ; 3
    dc.b    $00,$5F,$00,$C0,  $08,$C4,$00,$E0  ; 4
    dc.b    $00,$2A,$00,$08,  $08,$8F,$00,$28  ; 5
    dc.b    $00,$F4,$00,$48,  $08,$59,$00,$68  ; 6
    dc.b    $00,$BF,$00,$88,  $00,$24,$00,$A8  ; 7
    dc.b    $00,$89,$00,$C8,  $00,$EE,$00,$E8  ; 8
    dc.b    $00,$54,$00,$10,  $00,$B9,$00,$30  ; 9
    dc.b    $02,$1E,$00,$50,  $0A,$83,$00,$70  ; 10
    dc.b    $01,$E9,$00,$90,  $01,$4E,$00,$B0  ; 11
    dc.b    $09,$B3,$00,$D0,  $09,$19,$00,$F0  ; 12
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 14
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 16
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 18
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 20
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 22
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 24
