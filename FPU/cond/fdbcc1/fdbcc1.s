	include "../../fpureg.i"

EXEC    MACRO
        moveq   #0,d2   ; Test result
        moveq   #7,d3   ; Loop counter
.\1:
        addq    #1,d2
        \1      d3,.\1
        move.b  d2,(a2)+
        ENDM

trap0:

    movem.l d0-d3/a2/a3,-(a7) 

    lea     values,a2 
    moveq   #0,d0       ; FPSR payload
    moveq   #5,d1       ; Loop counter (6 iterations)

    fmove.l #0,FPCR

.loop1:
    fmove.l d0,FPSR     ; Setup status register 

    EXEC    fdbge 
    EXEC    fdbgl
    EXEC    fdbgle
    EXEC    fdbgt
    EXEC    fdble
    EXEC    fdblt
    EXEC    fdbnge
    EXEC    fdbngl
    EXEC    fdbngle
    EXEC    fdbngt
    EXEC    fdbnle
    EXEC    fdbnlt
    EXEC    fdbseq
    EXEC    fdbsne
    EXEC    fdbsf
    EXEC    fdbst

    EXEC    fdboge
    EXEC    fdbogl
    EXEC    fdbor
    EXEC    fdbogt
    EXEC    fdbole
    EXEC    fdbolt
    EXEC    fdbuge
    EXEC    fdbueq
    EXEC    fdbun
    EXEC    fdbugt
    EXEC    fdbule
    EXEC    fdbult
    EXEC    fdbeq 
    EXEC    fdbne
    EXEC    fdbf
    EXEC    fdbt

    add.l   #$03000000,d0
    dbra    d1,.loop1

    movem.l (a7)+,d0-d3/a2/a3
    rte

info: 
    dc.b    'FDBCC1', 0
    even 

spare:
    dc.s    16,0

expected:
    dc.b    $01,$01,$01,$01,  $08,$08,$08,$08  ; 1
    dc.b    $08,$08,$01,$01,  $08,$01,$08,$01  ; 2
    dc.b    $01,$01,$01,$01,  $08,$08,$01,$08  ; 3
    dc.b    $08,$01,$08,$08,  $08,$01,$08,$01  ; 4
    dc.b    $08,$08,$08,$08,  $08,$08,$01,$01  ; 5
    dc.b    $01,$01,$01,$01,  $08,$01,$08,$01  ; 6
    dc.b    $08,$08,$08,$08,  $08,$08,$01,$01  ; 7
    dc.b    $01,$01,$01,$01,  $08,$01,$08,$01  ; 8
    dc.b    $01,$08,$01,$08,  $01,$08,$08,$01  ; 9
    dc.b    $08,$01,$08,$01,  $01,$08,$08,$01  ; 10
    dc.b    $01,$08,$01,$08,  $01,$08,$01,$01  ; 11
    dc.b    $08,$08,$01,$08,  $01,$08,$08,$01  ; 12
    dc.b    $08,$08,$08,$08,  $08,$08,$01,$01  ; 13
    dc.b    $01,$01,$01,$01,  $08,$01,$08,$01  ; 14
    dc.b    $08,$08,$08,$08,  $08,$08,$01,$01  ; 15
    dc.b    $01,$01,$01,$01,  $08,$01,$08,$01  ; 16
    dc.b    $01,$08,$01,$08,  $01,$08,$08,$01  ; 17
    dc.b    $08,$01,$08,$01,  $01,$08,$08,$01  ; 18
    dc.b    $01,$08,$01,$08,  $01,$08,$01,$01  ; 19
    dc.b    $08,$08,$01,$08,  $01,$08,$08,$01  ; 20
    dc.b    $01,$08,$01,$08,  $01,$08,$01,$01  ; 21
    dc.b    $01,$01,$01,$01,  $01,$01,$08,$01  ; 22
    dc.b    $01,$08,$01,$08,  $01,$08,$01,$01  ; 23
    dc.b    $01,$01,$01,$01,  $01,$01,$08,$01  ; 24
