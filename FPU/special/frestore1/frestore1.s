	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 

    ; Write some garbage into the FPU registers 
    fmove   #$FFFF00FF,FPCR
    fmove   #$FFFFFFFF,FPSR
    fmove   #$FFFFFFFF,FPIAR
    fmove.x #1,FP0
    fmove.x #2,FP1
    fmove.x #3,FP2
    fmove.x #4,FP3
    fmove.x #5,FP4
    fmove.x #6,FP5
    fmove.x #7,FP6
    fmove.x #8,FP7

    ; Restore a NULL frame (will reset FPU registers)
    frestore nullframe

    ; Report registers values
    fmove   FPCR,(a2)+
    fmove   FPSR,(a2)+
    fmove   FPIAR,(a2)+
    fmove.x FP0,(a2)+
    fmove.x FP1,(a2)+
    fmove.x FP2,(a2)+
    fmove.x FP3,(a2)+
    fmove.x FP4,(a2)+
    fmove.x FP5,(a2)+
    fmove.x FP6,(a2)+
    fmove.x FP7,(a2)+

    movem.l (a7)+,d0/d1/a2
    rte

nullframe: 
    dc.b    $00,$00,$00,$00

info: 
    dc.b    'FRESTORE1', 0
    even 

expected:
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $7F,$FF,$00,$00  ; 2
    dc.b    $FF,$FF,$FF,$FF,  $FF,$FF,$FF,$FF  ; 3
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 4
    dc.b    $FF,$FF,$FF,$FF,  $7F,$FF,$00,$00  ; 5
    dc.b    $FF,$FF,$FF,$FF,  $FF,$FF,$FF,$FF  ; 6
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 7
    dc.b    $FF,$FF,$FF,$FF,  $7F,$FF,$00,$00  ; 8
    dc.b    $FF,$FF,$FF,$FF,  $FF,$FF,$FF,$FF  ; 9
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 10
    dc.b    $FF,$FF,$FF,$FF,  $7F,$FF,$00,$00  ; 11
    dc.b    $FF,$FF,$FF,$FF,  $FF,$FF,$FF,$FF  ; 12
    dc.b    $7F,$FF,$00,$00,  $FF,$FF,$FF,$FF  ; 13
    dc.b    $FF,$FF,$FF,$FF,  $00,$00,$00,$00  ; 14
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
