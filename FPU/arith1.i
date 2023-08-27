DUMP    MACRO
        fmove   FPSR,12(a2)
        fmove.x FP0,(a2)
        add     #16,a2
        ENDM

TEST    MACRO
        movem.l d0/d1/a2/a3,-(a7) 

        lea     values,a2

        ; 1 + 2: Zero (sign bit = 0)
        fmove.x #$000000000000000000000000,FP0
        \1      FP0
        DUMP

        ; 3 + 4: Zero (sign bit = 1)
        fmove.x #$800000000000000000000000,FP1
        \1      FP1,FP0
        DUMP

        ; 5 + 6
        fmove.w #1,FP0
        \1      FP0
        DUMP

        ; 7 + 8
        fmove.w #-1,FP1
        \1      FP1,FP0
        DUMP

        ; 9 + 10  SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$000300012346250000000000,FP1
        \1      FP1,FP0
        DUMP

        ; 11 + 12 SEEE---MMMMMMMMMMMMMMMMM
        fmove.p #$800300012346250000000000,FP0
        \1      FP0
        DUMP

       ; 13 + 14
        fmovecr #$00,FP0
        \1      FP0
        DUMP

        ; 15 + 16
        fmovecr #$00,FP0
        fneg    FP0
        \1      FP0
        DUMP

        ; 17 + 18: Infinity (sign bit = 0)
        fmove.x #$7FFF00000000000000000000,FP1
        \1      FP1,FP0
        DUMP

        ; 19 + 20: Infinity (sign bit = 1)
        fmove.x #$FFFF00000000000000000000,FP2
        \1      FP2,FP0
        DUMP 

        ; 21 + 22: Signaling NaN (sign bit = 0)
        fmove.x #$7FFF00000000000000000001,FP3
        \1      FP3,FP0
        DUMP 

        ; 23 + 24: Signaling NaN (sign bit = 1)
        fmove.x #$FFFF00000000000000000001,FP4
        \1      FP4,FP0
        DUMP 

        movem.l (a7)+,d0/d1/a2/a3
        ENDM
