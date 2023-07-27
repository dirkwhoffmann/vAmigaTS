	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 
    moveq   #0,d0       ; FPCR payload 

    ; Setup control register
    fmove.l d0,FPCR

    ; Load a constant (Pi)
    fmovecr #$00,FP0

    ; Write value back into memory in different formats
    lea     values,a2 

    fmove.x FP0,FP1
    fmove.b FP1,(a2)+

    fmove.x FP0,FP2
    fmove.w FP2,(a2)+

    fmove.x FP0,FP3
    fmove.l FP3,(a2)+

    fmove.x FP0,FP4
    fmove.s FP4,(a2)+

    fmove.x FP0,FP5
    fmove.d FP5,(a2)+

    fmove.x FP0,FP6
    fmove.x FP6,(a2)+

    fmove.x FP0,FP7
    fmove.p FP7,(a2)+

    ; Write again
    lea     values+192,a2 
    ; addq    #192,a2

    fmove.x FP0,FP1
    fmove.b FP1,-(a2)

    fmove.x FP0,FP2
    fmove.w FP2,-(a2)

    fmove.x FP0,FP3
    fmove.l FP3,-(a2)

    fmove.x FP0,FP4
    fmove.s FP4,-(a2)

    fmove.x FP0,FP5
    fmove.d FP5,-(a2)

    fmove.x FP0,FP6
    fmove.x FP6,-(a2)

    fmove.x FP0,FP7
    fmove.p FP7,-(a2)

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'FMOVE1-PIPD', 0
    even 

expected:
    dc.b    $03,$00,$03,$00,  $00,$00,$03,$40  ; 1
    dc.b    $49,$0F,$DB,$40,  $09,$21,$FB,$54  ; 2
    dc.b    $44,$2D,$18,$40,  $00,$00,$00,$C9  ; 3
    dc.b    $0F,$DA,$A2,$21,  $68,$C2,$35,$00  ; 4
    dc.b    $00,$00,$03,$00,  $00,$00,$00,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 6
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 8
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 10
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 12
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 14
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 16
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 18
    dc.b    $00,$00,$00,$00,  $00,$00,$00,$00  ; 19
    dc.b    $03,$00,$00,$00,  $00,$00,$00,$00  ; 20
    dc.b    $00,$40,$00,$00,  $00,$C9,$0F,$DA  ; 21
    dc.b    $A2,$21,$68,$C2,  $35,$40,$09,$21  ; 22
    dc.b    $FB,$54,$44,$2D,  $18,$40,$49,$0F  ; 23
    dc.b    $DB,$00,$00,$00,  $03,$00,$03,$03  ; 24
