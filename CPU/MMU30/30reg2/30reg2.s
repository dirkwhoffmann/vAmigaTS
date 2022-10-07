	include "../30reg.i"

trap0:

    ; Write some values into the MMU registers
    lea    payload,a2 
    pmove  (a2),MMUSR
    addq   #2,a2
    pmove  (a2),TC
    addq   #4,a2
    pmove  (a2),TT0
    addq   #4,a2
    pmove  (a2),TT1
    addq   #4,a2
    pmove  (a2),CRP
    addq   #8,a2
    pmove  (a2),SRP
    addq   #8,a2

    ; Read back values
    lea    values,a2 
    pmove  MMUSR,(a2)
    addq   #2,a2
    pmove  TC,(a2)
    addq   #4,a2 
    pmove  TT0,(a2)
    addq   #4,a2 
    pmove  TT1,(a2)
    addq   #4,a2 
    pmove  CRP,(a2)
    addq   #8,a2 
    pmove  SRP,(a2)
    addq   #8,a2 
    rte

info: 
    dc.b    '30REG2: PMOVE TEST', 0
    even 

payload:
    dc.w    $FFFF                           ; MMUSR
    dc.w    $7FFF, $FFFF                    ; TC
    dc.w    $7FFF, $FFFF                    ; TT0
    dc.w    $7FFF, $FFFF                    ; TT1
    dc.w    $FFFF, $FFFF, $FFFF, $FFFF      ; CRP
    dc.w    $FFFF, $FFFF, $FFFF, $FFFF      ; SRP
    dc.w    $FFFF

expected:
    dc.w    $EE47
    dc.w    $03FF, $FFFF
    dc.w    $7FFF, $8777
    dc.w    $7FFF, $8777
    dc.w    $FFFF, $FFFF, $FFFF, $FFFF
    dc.w    $FFFF, $FFFF, $FFFF, $FFFF
    dc.w    $0000
