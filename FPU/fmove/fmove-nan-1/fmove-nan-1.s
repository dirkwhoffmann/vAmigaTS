	include "../../fpureg.i"

DUMP    MACRO
        fmove.b FP0,(a2)
        addq    #8,a2
        fmove.w FP0,(a2)
        addq    #8,a2
        fmove.l FP0,(a2)
        addq    #8,a2
        fmove.s FP0,(a2)
        addq    #8,a2
        fmove.d FP0,(a2)
        addq    #8,a2
        fmove.x FP0,(a2)
        addq    #8,a2
        ENDM

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 
    fmove.l #0,FPCR

    fmove.d #$7FFF7FFFFFFFFFFF,FP0
    DUMP
    fmove.d #$7FFFFFFFFFFFFFFF,FP0
    DUMP
    fmove.d #$FFFF7FFFFFFFFFFF,FP0
    DUMP
    fmove.d #$FFFFFFFFFFFFFFFF,FP0
    DUMP

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'FMOVE-NAN-1', 0
    even 

expected:
    dc.b    $7B,$00,$00,$00,  $00,$00,$00,$00  ; 1
    dc.b    $7B,$FF,$00,$00,  $00,$00,$00,$00  ; 2
    dc.b    $7B,$FF,$FF,$FF,  $00,$00,$00,$00  ; 3
    dc.b    $7F,$FB,$FF,$FF,  $00,$00,$00,$00  ; 4
    dc.b    $7F,$FF,$7F,$FF,  $FF,$FF,$FF,$FF  ; 5
    dc.b    $7F,$FF,$00,$00,  $7B,$FF,$FF,$FF  ; 6
    dc.b    $7F,$FF,$F8,$00,  $00,$00,$00,$00  ; 7
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 8
    dc.b    $7F,$FF,$FF,$FF,  $00,$00,$00,$00  ; 9
    dc.b    $7F,$FF,$FF,$FF,  $00,$00,$00,$00  ; 10
    dc.b    $7F,$FF,$FF,$FF,  $FF,$FF,$FF,$FF  ; 11
    dc.b    $7F,$FF,$00,$00,  $7F,$FF,$FF,$FF  ; 12
    dc.b    $7B,$FF,$F8,$00,  $00,$00,$00,$00  ; 13
    dc.b    $7B,$FF,$00,$00,  $00,$00,$00,$00  ; 14
    dc.b    $7B,$FF,$FF,$FF,  $00,$00,$00,$00  ; 15
    dc.b    $FF,$FB,$FF,$FF,  $00,$00,$00,$00  ; 16
    dc.b    $FF,$FF,$7F,$FF,  $FF,$FF,$FF,$FF  ; 17
    dc.b    $FF,$FF,$00,$00,  $7B,$FF,$FF,$FF  ; 18
    dc.b    $7F,$FF,$F8,$00,  $00,$00,$00,$00  ; 19
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 20
    dc.b    $7F,$FF,$FF,$FF,  $00,$00,$00,$00  ; 21
    dc.b    $FF,$FF,$FF,$FF,  $00,$00,$00,$00  ; 22
    dc.b    $FF,$FF,$FF,$FF,  $FF,$FF,$FF,$FF  ; 23
    dc.b    $FF,$FF,$00,$00,  $7F,$FF,$FF,$FF  ; 24
