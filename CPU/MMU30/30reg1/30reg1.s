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
    dc.b    '30REG1: PMOVE TEST', 0
    even 

payload:
    dc.b    $00,$01,$02,$03,$14,$15,$16,$17,$20,$21,$22,$23,$34,$35,$36,$37
    dc.b    $40,$41,$42,$43,$54,$55,$56,$57,$60,$61,$62,$63,$74,$75,$76,$77

expected:
    dc.b    $00,$01,$02,$03,$14,$15,$16,$17,$00,$21,$22,$23,$04,$35,$36,$37
    dc.b    $40,$41,$42,$43,$54,$55,$56,$57,$60,$61,$62,$63,$74,$75,$00,$00
