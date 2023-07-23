	include "../30reg.i"

trap0:
    lea    oldtt0,a2        ; Save current value of TT0
    pmove  TT0,(a2)         

    lea    payload,a2       ; Values for TT0
    lea    values,a3        ; Recorded MMUSR values
    lea    $a0000000,a4     ; Test address
    moveq  #0,d0
    
    moveq  #15,d1
.loop:
    pmove  (a2),TT0
    addq   #4,a2
    ptestr d0,(a4),#0
    pmove  MMUSR,(a3)
    and.w  #$0040,(a3) ; Mask out all bits except AC
    addq   #2,a3
    dbra   d1,.loop

    lea    oldtt0,a2        ; Restore old value of TT0
    pmove  (a2),TT0

    rte

info: 
    dc.b    'PTESTR (68EC30)', 0
    even 

oldtt0:
    dc.b    $00,$00,$00,$00
    dc.b    $00,$00,$00,$00

payload:
    dc.b    $00,$00,$01,$07 ; 1
    dc.b    $00,$00,$81,$07 ; 2
    dc.b    $a0,$00,$80,$00 ; 3
    dc.b    $a0,$00,$81,$00 ; 4
    dc.b    $a0,$00,$82,$00 ; 5
    dc.b    $a0,$00,$83,$00 ; 6
    dc.b    $a0,$00,$81,$10 ; 7
    dc.b    $a0,$00,$81,$20 ; 8
    dc.b    $a0,$00,$81,$30 ; 9
    dc.b    $a0,$00,$81,$40 ; 10
    dc.b    $a0,$00,$81,$50 ; 11
    dc.b    $a0,$00,$81,$60 ; 12
    dc.b    $a0,$00,$81,$70 ; 13
    dc.b    $a0,$00,$81,$71 ; 14
    dc.b    $a0,$00,$81,$73 ; 15
    dc.b    $a0,$00,$81,$77 ; 16

expected:
    dc.b    $00,$00 ; 0
    dc.b    $00,$00 ; 0
    dc.b    $00,$00 ; 0
    dc.b    $00,$40 ; 0
    dc.b    $00,$40 ; 0
    dc.b    $00,$40 ; 0
    dc.b    $00,$00 ; 0
    dc.b    $00,$00 ; 0
    dc.b    $00,$00 ; 0
    dc.b    $00,$00 ; 0
    dc.b    $00,$00 ; 0
    dc.b    $00,$00 ; 0
    dc.b    $00,$00 ; 0
    dc.b    $00,$00 ; 0
    dc.b    $00,$00 ; 0
    dc.b    $00,$40 ; 0
