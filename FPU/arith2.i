DUMP    MACRO
        fmove   FPSR,12(a2)
        fmove.x FP0,(a2)
        add     #16,a2
        ENDM

TEST    MACRO
        movem.l d0/d1/a2/a3,-(a7) 

        lea     values,a2

        ; 1+2: 
        fmovecr #$00,FP0
        \1      FP0
        DUMP 

        ; 3+4: 
        fmovecr #$0C,FP0
        \1      FP0
        DUMP 

        ; 5+6: 
        fmovecr #$0D,FP0
        \1      FP0
        DUMP 

        ; 7+8: 
        fmovecr #$0E,FP0
        \1      FP0
        DUMP 

        ; 9+10: 
        fmovecr #$30,FP0
        \1      FP0
        DUMP 

        ; 11+12: 
        fmovecr #$31,FP0
        \1      FP0
        DUMP 

        ; 13+14: Infinity (sign bit = 0)
        fmove.x #$7FFF00000000000000000000,FP0
        DUMP 

        ; 15+16: Infinity (sign bit = 1)
        fmove.x #$FFFF00000000000000000000,FP0
        DUMP 

        ; 17+18: Signaling NaN (sign bit = 0)
        fmove.x #$7FFF00000000000000000001,FP0
        DUMP 

        ; 19+20: Nonsignaling NaN (sign bit = 0)
        fmove.x #$7FFF00004000000000000000,FP0
        DUMP 

        ; 21+22: Signaling NaN (sign bit = 1)
        fmove.x #$FFFF00000000000000000001,FP0
        DUMP 

        ; 23+24: Nonsignaling NaN (sign bit = 1)
        fmove.x #$FFFF00004000000000000001,FP0
        DUMP 

        movem.l (a7)+,d0/d1/a2/a3
        ENDM
