	include "../../fpureg.i"

DUMP    MACRO
        fmove   FPSR,12(a2)
        fmove.x FP0,(a2)
        add     #16,a2
        ENDM

trap0:

    movem.l d0-d3/a2/a3,-(a7) 

    lea     values,a2 
    moveq   #0,d0       ; FPSR payload
    moveq   #11,d2      ; Loop counter (12 iterations)

    fmove.l #0,FPCR

.loop1:
    fmove.l d0,FPSR     ; Setup status register 

    fsge    (a2)+       ; Execute test instructions
    fsgl    (a2)+
    fsgle   (a2)+
    fsgt    (a2)+
    fsle    (a2)+
    fslt    (a2)+
    fsnge   (a2)+
    fsngl   (a2)+
    fsngle  (a2)+
    fsngt   (a2)+
    fsnle   (a2)+
    fsnlt   (a2)+
    fsseq   (a2)+
    fssne   (a2)+
    fssf    (a2)+
    fsst    (a2)+

    add.l   #$01000000,d0
    dbra    d2,.loop1

    movem.l (a7)+,d0-d3/a2/a3
    rte

info: 
    dc.b    'FSCC1', 0
    even 

spare:
    dc.s    16,0

expected:
    dc.b    $FF,$FF,$FF,$FF,  $00,$00,$00,$00  ; 1
    dc.b    $00,$00,$FF,$FF,  $00,$FF,$00,$FF  ; 2
    dc.b    $00,$00,$00,$00,  $00,$00,$FF,$FF  ; 3
    dc.b    $FF,$FF,$FF,$FF,  $00,$FF,$00,$FF  ; 4
    dc.b    $FF,$FF,$FF,$FF,  $00,$00,$00,$00  ; 5
    dc.b    $00,$00,$FF,$FF,  $00,$FF,$00,$FF  ; 6
    dc.b    $00,$00,$00,$00,  $00,$00,$FF,$FF  ; 7
    dc.b    $FF,$FF,$FF,$FF,  $00,$FF,$00,$FF  ; 8
    dc.b    $FF,$00,$FF,$00,  $FF,$00,$00,$FF  ; 9
    dc.b    $00,$FF,$00,$FF,  $FF,$00,$00,$FF  ; 10
    dc.b    $FF,$00,$FF,$00,  $FF,$00,$FF,$FF  ; 11
    dc.b    $FF,$FF,$FF,$FF,  $FF,$FF,$00,$FF  ; 12
    dc.b    $FF,$00,$FF,$00,  $FF,$00,$00,$FF  ; 13
    dc.b    $00,$FF,$00,$FF,  $FF,$00,$00,$FF  ; 14
    dc.b    $FF,$00,$FF,$00,  $FF,$00,$FF,$FF  ; 15
    dc.b    $FF,$FF,$FF,$FF,  $FF,$FF,$00,$FF  ; 16
    dc.b    $00,$FF,$FF,$00,  $FF,$FF,$FF,$00  ; 17
    dc.b    $00,$FF,$00,$00,  $00,$FF,$00,$FF  ; 18
    dc.b    $00,$00,$00,$00,  $00,$00,$FF,$FF  ; 19
    dc.b    $FF,$FF,$FF,$FF,  $00,$FF,$00,$FF  ; 20
    dc.b    $00,$FF,$FF,$00,  $FF,$FF,$FF,$00  ; 21
    dc.b    $00,$FF,$00,$00,  $00,$FF,$00,$FF  ; 22
    dc.b    $00,$00,$00,$00,  $00,$00,$FF,$FF  ; 23
    dc.b    $FF,$FF,$FF,$FF,  $00,$FF,$00,$FF  ; 24
