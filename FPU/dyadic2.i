DUMP    MACRO
        fmove   FPSR,12(a2)
        fmove.x \1,(a2)
        add     #16,a2
        ENDM

TEST    MACRO
        movem.l d0/d1/a2/a3,-(a7) 

        fmove.x #$000000000000000000000000,FP0      ; Zero (sign bit = 0)
        fmove.x #$800000000000000000000000,FP1      ; Zero (sign bit = 1)    
        fmove.x #$7FFF00000000000000000000,FP2      ; Infinity (sign bit = 0)    
        fmove.x #$FFFF00000000000000000000,FP3      ; Infinity (sign bit = 1)
        fmove.x #$7FFF00000000000000000001,FP4      ; Signaling NaN (sign bit = 0)
        fmove.x #$FFFF00004000000000000001,FP5      ; Nonsignaling NaN (sign bit = 1)

        lea     values,a2

        ; 1 + 2
        fmove.x FP0,FP7
        \1      FP0,FP7
        DUMP    FP7
        ; 3 + 4
        fmove.x FP1,FP7
        \1      FP0,FP7
        DUMP    FP7
        ; 5 + 6
        fmove.x FP2,FP7
        \1      FP0,FP7
        DUMP    FP7
        ; 7 + 8
        fmove.x FP3,FP7
        \1      FP0,FP7
        DUMP    FP7
        ; 9 + 10
        fmove.x FP4,FP7
        \1      FP0,FP7
        DUMP    FP7
        ; 11 + 12
        fmove.x FP5,FP7
        \1      FP0,FP7
        DUMP    FP7
        ; 13 + 14
        fmove.x FP1,FP7
        \1      FP1,FP7
        DUMP    FP7
        ; 15 + 16
        fmove.x FP2,FP7
        \1      FP1,FP7
        DUMP    FP7
        ; 17 + 18
        fmove.x FP3,FP7
        \1      FP1,FP7
        DUMP    FP7
        ; 19 + 20
        fmove.x FP4,FP7
        \1      FP1,FP7
        DUMP    FP7
        ; 21 + 22
        fmove.x FP5,FP7
        \1      FP1,FP7
        DUMP    FP7
        ; 23 + 24
        fmove.x FP2,FP7
        \1      FP2,FP7
        DUMP    FP7

        movem.l (a7)+,d0/d1/a2/a3
        ENDM
