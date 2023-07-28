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

    ; Load a floating-point constant and write it into memory
    fmove.p #$112233445566778899001122,FP0
    fmove.p FP0,(a2)

    ; Also display some other register content
    fmove   FPSR,12(a2)

    add     #16,a2

    dbra    d1,.loop

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'FMOVE3-P', 0
    even 

expected:
    dc.b    $01,$22,$00,$04,  $55,$66,$77,$88  ; 1
    dc.b    $99,$00,$11,$22,  $00,$00,$02,$08  ; 2
    dc.b    $01,$22,$00,$04,  $55,$66,$77,$88  ; 3
    dc.b    $99,$00,$11,$21,  $00,$00,$02,$08  ; 4
    dc.b    $01,$22,$00,$04,  $55,$66,$77,$88  ; 5
    dc.b    $99,$00,$11,$21,  $00,$00,$02,$08  ; 6
    dc.b    $01,$22,$00,$04,  $55,$66,$77,$88  ; 7
    dc.b    $99,$00,$11,$23,  $00,$00,$02,$08  ; 8
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $02,$00,$00,$48  ; 10
    dc.b    $00,$38,$00,$03,  $40,$28,$23,$46  ; 11
    dc.b    $63,$85,$28,$85,  $00,$00,$02,$48  ; 12
    dc.b    $00,$38,$00,$03,  $40,$28,$23,$46  ; 13
    dc.b    $63,$85,$28,$85,  $00,$00,$02,$48  ; 14
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $02,$00,$00,$48  ; 16
    dc.b    $01,$22,$00,$04,  $55,$66,$77,$88  ; 17
    dc.b    $99,$00,$11,$22,  $00,$00,$02,$48  ; 18
    dc.b    $01,$22,$00,$04,  $55,$66,$77,$88  ; 19
    dc.b    $99,$00,$11,$21,  $00,$00,$02,$48  ; 20
    dc.b    $01,$22,$00,$04,  $55,$66,$77,$88  ; 21
    dc.b    $99,$00,$11,$21,  $00,$00,$02,$48  ; 22
    dc.b    $01,$22,$00,$04,  $55,$66,$77,$88  ; 23
    dc.b    $99,$00,$11,$29,  $00,$00,$02,$48  ; 24
