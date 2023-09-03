    include "../../fpureg.i"

DUMP    MACRO
        fmove   FPSR,12(a2)
        fmove.x FP0,(a2)
        add     #16,a2
        ENDM

TEST    MACRO
        movem.l d0/d1/a2/a3,-(a7) 

        lea     values,a2

        ; 1 + 2:  
        fmove.x #$000000000000000000000000,FP0
        \1      FP0
        DUMP

        ; 3 + 4:  
        fmove.x #$800000000000000000000000,FP0
        \1      FP0
        DUMP

        ; 5 + 6   SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$000000010000000000000000,FP0
        \1      FP0
        DUMP

        ; 7 + 8   SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$800000010000000000000000,FP0
        \1      FP0
        DUMP

        ; 9 + 10  SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$000000020000000000000000,FP0
        \1      FP0
        DUMP

        ; 11 + 12 SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$800000020000000000000000,FP0
        \1      FP0
        DUMP

        ; 13 + 14 SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$400100050000000000000000,FP0
        \1      FP0
        DUMP

        ; 15 + 16 SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$C00100050000000000000000,FP0
        \1      FP0
        DUMP

        ; 17 + 18 SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$400100010000000000000000,FP0
        \1      FP0
        DUMP

        ; 19 + 20 SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$C00100010000000000000000,FP0
        \1      FP0
        DUMP

        ; 21 + 22 SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$000200012462500000000000,FP0
        \1      FP0
        DUMP

        ; 23 + 24 SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$800200012462500000000000,FP0
        \1      FP0
        DUMP

        movem.l (a7)+,d0/d1/a2/a3
        ENDM

trap0:
    fmove   #$40,FPCR   ; Precision: Single, Rounding: To nearest
    TEST    ftst
    rte

info: 
    dc.b    'FTST1', 0
    even 

expected:
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $04,$00,$00,$00  ; 2
    dc.b    $80,$00,$00,$00,  $00,$00,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $0C,$00,$00,$00  ; 4
    dc.b    $3F,$FF,$00,$00,  $80,$00,$00,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 6
    dc.b    $BF,$FF,$00,$00,  $80,$00,$00,$00  ; 7
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$00  ; 8
    dc.b    $40,$00,$00,$00,  $80,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 10
    dc.b    $C0,$00,$00,$00,  $80,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$00  ; 12
    dc.b    $3F,$FE,$00,$00,  $80,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 14
    dc.b    $BF,$FE,$00,$00,  $80,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$00  ; 16
    dc.b    $3F,$FB,$00,$00,  $CC,$CC,$CD,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 18
    dc.b    $BF,$FB,$00,$00,  $CC,$CC,$CD,$00  ; 19
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$08  ; 20
    dc.b    $40,$05,$00,$00,  $F9,$40,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$08  ; 22
    dc.b    $C0,$05,$00,$00,  $F9,$40,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$08  ; 24
