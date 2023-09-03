DUMP    MACRO
        fmove   FPSR,12(a2)
        fmove.x \1,(a2)
        add     #16,a2
        ENDM

TEST    MACRO
        movem.l d0/d1/a2/a3,-(a7) 

        fmove.p #$000000010000000000000000,FP0
        fmove.p #$800000010000000000000000,FP1
        fmove.p #$000200012462500000000000,FP2
        fmove.p #$800200012462500000000000,FP3
        fmovecr #$00,FP4
        fmovecr #$0C,FP5
        fmovecr #$0D,FP6
        fmovecr #$0E,FP7

        lea     values,a2

        ; 1 + 2
        \1      FP0,FP2
        DUMP    FP2
        ; 3 + 4
        \1      FP1,FP3
        DUMP    FP3
        ; 5 + 6
        \1      FP2,FP3
        DUMP    FP3
        ; 7 + 8
        \1      FP0,FP4
        DUMP    FP4
        ; 9 + 10
        \1      FP1,FP4
        DUMP    FP4
        ; 11 + 12
        \1      FP4,FP0
        DUMP    FP0
        ; 13 + 14
        \1      FP4,FP1
        DUMP    FP1
        ; 15 + 16
        \1      FP0,FP1
        DUMP    FP1
        ; 17 + 18
        \1      FP0,FP2
        DUMP    FP2
        ; 19 + 20
        \1      FP0,FP3
        DUMP    FP3
        ; 21 + 22
        \1      FP2,FP2
        DUMP    FP2
        ; 23 + 24
        \1      FP3,FP3
        DUMP    FP3

        movem.l (a7)+,d0/d1/a2/a3
        ENDM
