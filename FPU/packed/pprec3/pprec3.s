	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 
    moveq   #11,d1      ; Loop counter (12 iterations)
    moveq   #0,d0       ; FPCR payload 

.loop:

    ; Setup control register
    fmove.l d0,FPCR
    add     #$10,d0

    ;         SEEE---MMMMMMMMMMMMMMMMM
    fmove.p #$030800020000000000000000,FP0

    fmove.x FP0,(a2)+
    fmove   FPSR,(a2)+

    dbra    d1,.loop

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'PPREC3', 0
    even 

expected:
    dc.b    $43,$FF,$00,$00,  $8E,$67,$9C,$2F  ; 1
    dc.b    $5E,$44,$FF,$8F,  $00,$00,$00,$08  ; 2
    dc.b    $43,$FF,$00,$00,  $8E,$67,$9C,$2F  ; 3
    dc.b    $5E,$44,$FF,$8C,  $00,$00,$00,$08  ; 4
    dc.b    $43,$FF,$00,$00,  $8E,$67,$9C,$2F  ; 5
    dc.b    $5E,$44,$FF,$8C,  $00,$00,$00,$08  ; 6
    dc.b    $43,$FF,$00,$00,  $8E,$67,$9C,$2F  ; 7
    dc.b    $5E,$44,$FF,$92,  $00,$00,$00,$08  ; 8
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $02,$00,$00,$48  ; 10
    dc.b    $40,$7E,$00,$00,  $FF,$FF,$FF,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$48  ; 12
    dc.b    $40,$7E,$00,$00,  $FF,$FF,$FF,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$48  ; 14
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $02,$00,$00,$48  ; 16
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $02,$00,$00,$48  ; 18
    dc.b    $43,$FE,$00,$00,  $FF,$FF,$FF,$FF  ; 19
    dc.b    $FF,$FF,$F8,$00,  $00,$00,$00,$48  ; 20
    dc.b    $43,$FE,$00,$00,  $FF,$FF,$FF,$FF  ; 21
    dc.b    $FF,$FF,$F8,$00,  $00,$00,$00,$48  ; 22
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $02,$00,$00,$48  ; 24
