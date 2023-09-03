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
        fmove.p #$400100050000000000000000,FP1
        \1      FP1,FP0
        DUMP

        ; 15 + 16 SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$C00100050000000000000000,FP2
        \1      FP2,FP0
        DUMP

        ; 17 + 18 SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$400100010000000000000000,FP3
        \1      FP3,FP0
        DUMP

        ; 19 + 20 SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$C00100010000000000000000,FP4
        \1      FP4,FP0
        DUMP

        ; 21 + 22 SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$000200012462500000000000,FP5
        \1      FP5,FP0
        DUMP

        ; 23 + 24 SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$800200012462500000000000,FP6
        \1      FP6,FP0
        DUMP

        movem.l (a7)+,d0/d1/a2/a3
        ENDM
