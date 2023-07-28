	include "../../fpureg.i"

INIT    MACRO
        moveq   #3,d1      ; Loop counter (4 iterations)
        fmove   #$0,FPCR
        fmove   #$0,FPSR
        fmove   #$0,FPIAR
        lea     payload,a3 
        ENDM

DUMP    MACRO
        fmove   FPSR,(a2)
        addq    #4,a2
        fmove   FPCR,(a2)+
        fmove   FPSR,(a2)+
        fmove   FPIAR,(a2)+
        ENDM

trap0:

    movem.l d0/d1/a2/a3,-(a7) 

    lea     values,a2 

    INIT
.loop1:
    fmove   (a3)+,FPCR
    DUMP
    dbra    d1,.loop1

    INIT
.loop2:
    fmove   (a3)+,FPSR
    DUMP
    dbra    d1,.loop2

    INIT
.loop3:
    fmove   (a3)+,FPIAR
    DUMP
    dbra    d1,.loop3

    movem.l (a7)+,d0/d1/a2/a3
    rte

info: 
    dc.b    'FMOVE-FPCR', 0
    even 

payload:
    dc.b    $00,$00,$00,$00,  $FF,$FF,$FF,$FF  ; 1
    dc.b    $12,$34,$56,$78,  $FE,$DC,$BA,$73  ; 2

expected:
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 2
    dc.b    $00,$00,$00,$00,  $00,$00,$FF,$F0  ; 3
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 4
    dc.b    $00,$00,$00,$00,  $00,$00,$56,$70  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 6
    dc.b    $00,$00,$00,$00,  $00,$00,$BA,$70  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 8
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 10
    dc.b    $0F,$FF,$FF,$F8,  $00,$00,$00,$00  ; 11
    dc.b    $0F,$FF,$FF,$F8,  $00,$00,$00,$00  ; 12
    dc.b    $02,$34,$56,$78,  $00,$00,$00,$00  ; 13
    dc.b    $02,$34,$56,$78,  $00,$00,$00,$00  ; 14
    dc.b    $0E,$DC,$BA,$70,  $00,$00,$00,$00  ; 15
    dc.b    $0E,$DC,$BA,$70,  $00,$00,$00,$00  ; 16
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 18
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $FF,$FF,$FF,$FF  ; 20
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $12,$34,$56,$78  ; 22
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $FE,$DC,$BA,$73  ; 24
