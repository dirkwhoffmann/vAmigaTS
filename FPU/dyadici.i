DUMP    MACRO
        fmove   FPSR,12(a2)
        fmove.x \1,(a2)
        add     #16,a2
        ENDM

TEST    MACRO
        movem.l d0/d1/a2/a3,-(a7) 
 
        fmove.p #$000000010000000000000000,FP0
        fmove.p #$800200012462500000000000,FP1

        lea     values,a2

        ; 1 + 2
        fmove.x FP0,FP7
        \1      #0,FP7
        DUMP    FP7
        ; 3 + 4
        fmove.x FP1,FP7
        \1      #0,FP7
        DUMP    FP7
        ; 5 + 6
        fmove.x FP0,FP7
        \1      #1,FP7
        DUMP    FP7
        ; 7 + 8
        fmove.x FP1,FP7
        \1      #1,FP7
        DUMP    FP7
        ; 9 + 10
        fmove.x FP0,FP7
        \1      #-1,FP7
        DUMP    FP7
        ; 11 + 12
        fmove.x FP1,FP7
        \1      #-1,FP7
        DUMP    FP7
        ; 13 + 14
        fmove.x FP0,FP7
        \1      #42,FP7
        DUMP    FP7
        ; 15 + 16
        fmove.x FP1,FP7
        \1      #42,FP7
        DUMP    FP7
        ; 17 + 18
        fmove.x FP0,FP7
        \1      #-42,FP7
        DUMP    FP7
        ; 19 + 20
        fmove.x FP1,FP7
        \1      #-42,FP7
        DUMP    FP7
        ; 21 + 22
        fmove.x FP0,FP7
        \1      #4096,FP7
        DUMP    FP7
        ; 23 + 24
        fmove.x FP1,FP7
        \1      #4096,FP7
        DUMP    FP7

        movem.l (a7)+,d0/d1/a2/a3
        ENDM
