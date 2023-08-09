	include "../../fpureg.i"

trap0:

    movem.l d0/d1/a2,-(a7) 

    lea     values,a2 

    ; Setup control register
    fmove.l #0,FPCR

    lea     values,a2 

    fmovecr #$00,FP1

    fmove.p FP1,(a2)+{#0}
    fmove.l FPSR,(a2)+ 
    addq    #1,d0

    fmove.p FP1,(a2)+{#1}
    fmove.l FPSR,(a2)+ 
    addq    #1,d0

    fmove.p FP1,(a2)+{#2}
    fmove.l FPSR,(a2)+ 
    addq    #1,d0

    fmove.p FP1,(a2)+{#3}
    fmove.l FPSR,(a2)+ 
    addq    #1,d0

    fmove.p FP1,(a2)+{#4}
    fmove.l FPSR,(a2)+ 
    addq    #1,d0

    fmove.p FP1,(a2)+{#5}
    fmove.l FPSR,(a2)+ 
    addq    #1,d0

    fmove.p FP1,(a2)+{#6}
    fmove.l FPSR,(a2)+ 
    addq    #1,d0

    fmove.p FP1,(a2)+{#7}
    fmove.l FPSR,(a2)+ 
    addq    #1,d0

    fmove.p FP1,(a2)+{#8}
    fmove.l FPSR,(a2)+ 
    addq    #1,d0

    fmove.p FP1,(a2)+{#9}
    fmove.l FPSR,(a2)+ 
    addq    #1,d0

    fmove.p FP1,(a2)+{#10}
    fmove.l FPSR,(a2)+ 
    addq    #1,d0

    fmove.p FP1,(a2)+{#11}
    fmove.l FPSR,(a2)+ 
    addq    #1,d0

    movem.l (a7)+,d0/d1/a2
    rte

info: 
    dc.b    'KFACTOR5-00', 0
    even 

expected:
    dc.b    $00,$00,$00,$03,  $00,$00,$00,$00  ; 1
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 2
    dc.b    $00,$00,$00,$03,  $00,$00,$00,$00  ; 3
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 4
    dc.b    $00,$00,$00,$03,  $10,$00,$00,$00  ; 5
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 6
    dc.b    $00,$00,$00,$03,  $14,$00,$00,$00  ; 7
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 8
    dc.b    $00,$00,$00,$03,  $14,$20,$00,$00  ; 9
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 10
    dc.b    $00,$00,$00,$03,  $14,$16,$00,$00  ; 11
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 12
    dc.b    $00,$00,$00,$03,  $14,$15,$90,$00  ; 13
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 14
    dc.b    $00,$00,$00,$03,  $14,$15,$93,$00  ; 15
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 16
    dc.b    $00,$00,$00,$03,  $14,$15,$92,$70  ; 17
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 18
    dc.b    $00,$00,$00,$03,  $14,$15,$92,$65  ; 19
    dc.b    $00,$00,$00,$00,  $00,$00,$02,$08  ; 20
    dc.b    $00,$00,$00,$03,  $14,$15,$92,$65  ; 21
    dc.b    $40,$00,$00,$00,  $00,$00,$02,$08  ; 22
    dc.b    $00,$00,$00,$03,  $14,$15,$92,$65  ; 23
    dc.b    $36,$00,$00,$00,  $00,$00,$02,$08  ; 24
