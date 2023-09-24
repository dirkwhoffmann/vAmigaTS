	include "../../fpureg.i"

trap0:

    movem.l d0-d3/a2/a3,-(a7) 

    lea     values,a2 
    moveq   #0,d0       ; FPSR payload
    moveq   #15,d2      ; Loop counter (16 iterations)

    fmove.l #0,FPCR

.loop1:
    ; Execute test instruction 1
    fmove   d0,FPSR
    fbge    .skip1
.skip1:
    fmove   FPSR,d1
    move.w  d1,(a2)+

    ; Execute test instruction 2
    fmove   d0,FPSR
    fbgle   .skip2
.skip2:
    fmove   FPSR,d1
    move.w  d1,(a2)+

    ; Execute test instruction 3
    fmove   d0,FPSR
    fboge   .skip3
.skip3:
    fmove   FPSR,d1
    move.w  d1,(a2)+

    ; Execute test instruction 4
    fmove   d0,FPSR
    fbogl   .skip4
.skip4:
    fmove   FPSR,d1
    move.w  d1,(a2)+

    add.l   #$01000000,d0
    dbra    d2,.loop1

    movem.l (a7)+,d0-d3/a2/a3
    rte

info: 
    dc.b    'FBCC2', 0
    even 

spare:
    dc.s    16,0

expected:
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 1
    dc.b    $80,$80,$80,$80,  $00,$00,$00,$00  ; 2
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 3
    dc.b    $80,$80,$80,$80,  $00,$00,$00,$00  ; 4
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 5
    dc.b    $80,$80,$80,$80,  $00,$00,$00,$00  ; 6
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 7
    dc.b    $80,$80,$80,$80,  $00,$00,$00,$00  ; 8
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 9
    dc.b    $80,$80,$80,$80,  $00,$00,$00,$00  ; 10
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 11
    dc.b    $80,$80,$80,$80,  $00,$00,$00,$00  ; 12
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 13
    dc.b    $80,$80,$80,$80,  $00,$00,$00,$00  ; 14
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 15
    dc.b    $80,$80,$80,$80,  $00,$00,$00,$00  ; 16
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 18
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 19
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 20
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 21
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 22
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 24
