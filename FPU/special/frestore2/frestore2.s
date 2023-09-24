	include "../../fpureg.i"

SAVRES  MACRO
        ; Run an FSAVE/FRESTORE cycle
        move.l   sp,d2
        fsave    -(sp)
        sub.l    sp,d2
        frestore (sp)+
        move.l  d2,(a2)+        
        fmove   FPSR,(a2)+

        ; Run it a second time
        move.l   sp,d2
        fsave    -(sp)
        sub.l    sp,d2
        frestore (sp)+
        move.l  d2,(a2)+        
        fmove   FPSR,(a2)+
        ENDM

trap0:

    movem.l d0/d1/a2/a3,-(a7) 

    lea     values,a2 

    ; Reset the FPU
    frestore nullframe
    SAVRES
    
    ; Modify FP0 (FPU no longer in reset state)
    fmove.d  #42,FP0
    SAVRES

    ; Experiment: Do we go back into reset state by reverting FP0?
    fmove.x FP1,FP0
    SAVRES

    ; Reset the FPU
    frestore nullframe
    SAVRES

    ; Experiment: Do we leave the reset state by writing the reset value into a register?
    fmove.x FP1,FP0
    SAVRES

    movem.l (a7)+,d0/d1/a2/a3
    rte

nullframe: 
    dc.b    $00,$00,$00,$00

info: 
    dc.b    'FRESTORE2 (68882)', 0
    even 

spare:
    dc.s    128,0

expected:
    dc.b    $00,$00,$00,$04,  $00,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$3C,  $00,$00,$00,$00  ; 2
    dc.b    $00,$00,$00,$3C,  $00,$00,$00,$00  ; 3
    dc.b    $00,$00,$00,$3C,  $00,$00,$00,$00  ; 4
    dc.b    $00,$00,$00,$3C,  $01,$00,$00,$00  ; 5
    dc.b    $00,$00,$00,$3C,  $01,$00,$00,$00  ; 6
    dc.b    $00,$00,$00,$04,  $00,$00,$00,$00  ; 7
    dc.b    $00,$00,$00,$3C,  $00,$00,$00,$00  ; 8
    dc.b    $00,$00,$00,$3C,  $01,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$3C,  $01,$00,$00,$00  ; 10
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 12
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
