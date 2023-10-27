	include "../../fpureg.i"

DUMP    MACRO
        fmove   FPSR,12(a2)
        fmove.x FP0,(a2)
        add     #16,a2
        ENDM

trap0:

    movem.l d0/d1/a2/a3,-(a7) 

    lea     values,a2 
    moveq   #11,d1      ; Loop counter (12 iterations)
    moveq   #0,d0       ; FPCR payload 

.loop:

    fmove.l d0,FPCR

    fmove.x #$61FF0000ABCDABCDABCDABCD,FP0
    DUMP

    add     #$10,d0
    dbra    d1,.loop

    movem.l (a7)+,d0/d1/a2/a3
    rte

info: 
    dc.b    'OVERFLOW2', 0
    even 

spare:
    dc.s    16,0

expected:
    dc.b    $61,$FF,$00,$00,  $AB,$CD,$AB,$CD  ; 1
    dc.b    $AB,$CD,$AB,$CD,  $00,$00,$00,$00  ; 2
    dc.b    $61,$FF,$00,$00,  $AB,$CD,$AB,$CD  ; 3
    dc.b    $AB,$CD,$AB,$CD,  $00,$00,$00,$00  ; 4
    dc.b    $61,$FF,$00,$00,  $AB,$CD,$AB,$CD  ; 5
    dc.b    $AB,$CD,$AB,$CD,  $00,$00,$00,$00  ; 6
    dc.b    $61,$FF,$00,$00,  $AB,$CD,$AB,$CD  ; 7
    dc.b    $AB,$CD,$AB,$CD,  $00,$00,$00,$00  ; 8
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $02,$00,$12,$48  ; 10
    dc.b    $40,$7E,$00,$00,  $FF,$FF,$FF,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$12,$48  ; 12
    dc.b    $40,$7E,$00,$00,  $FF,$FF,$FF,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$12,$48  ; 14
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 15
    dc.b    $00,$00,$00,$00,  $02,$00,$12,$48  ; 16
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 17
    dc.b    $00,$00,$00,$00,  $02,$00,$12,$48  ; 18
    dc.b    $43,$FE,$00,$00,  $FF,$FF,$FF,$FF  ; 19
    dc.b    $FF,$FF,$F8,$00,  $00,$00,$12,$48  ; 20
    dc.b    $43,$FE,$00,$00,  $FF,$FF,$FF,$FF  ; 21
    dc.b    $FF,$FF,$F8,$00,  $00,$00,$12,$48  ; 22
    dc.b    $7F,$FF,$00,$00,  $00,$00,$00,$00  ; 23
    dc.b    $00,$00,$00,$00,  $02,$00,$12,$48  ; 24
