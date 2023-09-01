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
    fmove.p #$830800020000000000000000,FP0

    fmove.x FP0,(a2)+
    fmove   FPSR,(a2)+

    dbra    d1,.loop

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'PPREC6', 0
    even 

expected:
    dc.b    $C3,$FF,$00,$00,  $8E,$67,$9C,$2F  ; 1
    dc.b    $5E,$44,$FF,$8F,  $08,$00,$00,$08  ; 2
    dc.b    $C3,$FF,$00,$00,  $8E,$67,$9C,$2F  ; 3
    dc.b    $5E,$44,$FF,$8C,  $08,$00,$00,$08  ; 4
    dc.b    $C3,$FF,$00,$00,  $8E,$67,$9C,$2F  ; 5
    dc.b    $5E,$44,$FF,$92,  $08,$00,$00,$08  ; 6
    dc.b    $C3,$FF,$00,$00,  $8E,$67,$9C,$2F  ; 7
    dc.b    $5E,$44,$FF,$8C,  $08,$00,$00,$08  ; 8
    dc.b    $FF,$FF,$00,$00,  $00,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $0A,$00,$00,$48  ; 10
    dc.b    $C0,$7E,$00,$00,  $FF,$FF,$FF,$00  ; 11
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$48  ; 12
    dc.b    $FF,$FF,$00,$00,  $00,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $0A,$00,$00,$48  ; 14
    dc.b    $C0,$7E,$00,$00,  $FF,$FF,$FF,$00  ; 15
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$48  ; 16
    dc.b    $FF,$FF,$00,$00,  $00,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $0A,$00,$00,$48  ; 18
    dc.b    $C3,$FE,$00,$00,  $FF,$FF,$FF,$FF  ; 19
    dc.b    $FF,$FF,$F8,$00,  $08,$00,$00,$48  ; 20
    dc.b    $FF,$FF,$00,$00,  $00,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $0A,$00,$00,$48  ; 22
    dc.b    $C3,$FE,$00,$00,  $FF,$FF,$FF,$FF  ; 23
    dc.b    $FF,$FF,$F8,$00,  $08,$00,$00,$48  ; 24

