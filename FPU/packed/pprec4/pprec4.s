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
    fmove.p #$803800040000000000000000,FP0

    fmove.x FP0,(a2)+
    fmove   FPSR,(a2)+

    dbra    d1,.loop

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'PPREC4', 0
    even 

expected:
    dc.b    $C0,$7F,$00,$00,  $96,$76,$99,$50  ; 1
    dc.b    $B5,$0D,$88,$F4,  $08,$00,$00,$08  ; 2
    dc.b    $C0,$7F,$00,$00,  $96,$76,$99,$50  ; 3
    dc.b    $B5,$0D,$88,$F4,  $08,$00,$00,$08  ; 4
    dc.b    $C0,$7F,$00,$00,  $96,$76,$99,$50  ; 5
    dc.b    $B5,$0D,$88,$F5,  $08,$00,$00,$08  ; 6
    dc.b    $C0,$7F,$00,$00,  $96,$76,$99,$50  ; 7
    dc.b    $B5,$0D,$88,$F4,  $08,$00,$00,$08  ; 8
    dc.b    $FF,$FF,$00,$00,  $00,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $0A,$00,$00,$48  ; 10
    dc.b    $C0,$7E,$00,$00,  $FF,$FF,$FF,$00  ; 11
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$48  ; 12
    dc.b    $FF,$FF,$00,$00,  $00,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $0A,$00,$00,$48  ; 14
    dc.b    $C0,$7E,$00,$00,  $FF,$FF,$FF,$00  ; 15
    dc.b    $00,$00,$00,$00,  $08,$00,$00,$48  ; 16
    dc.b    $C0,$7F,$00,$00,  $96,$76,$99,$50  ; 17
    dc.b    $B5,$0D,$88,$00,  $08,$00,$00,$48  ; 18
    dc.b    $C0,$7F,$00,$00,  $96,$76,$99,$50  ; 19
    dc.b    $B5,$0D,$88,$00,  $08,$00,$00,$48  ; 20
    dc.b    $C0,$7F,$00,$00,  $96,$76,$99,$50  ; 21
    dc.b    $B5,$0D,$90,$00,  $08,$00,$00,$48  ; 22
    dc.b    $C0,$7F,$00,$00,  $96,$76,$99,$50  ; 23
    dc.b    $B5,$0D,$88,$00,  $08,$00,$00,$48  ; 24
