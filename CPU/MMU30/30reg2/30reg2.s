	include "../30reg.i"

trap0:

    ; Write some values into the MMU registers
    lea    payload,a2 
    pmove  (a2),MMUSR
    addq   #2,a2
    pmovefd  (a2),TC
    addq   #4,a2
    pmovefd  (a2),TT0
    addq   #4,a2
    pmovefd  (a2),TT1
    addq   #4,a2
    pmovefd  (a2),CRP
    addq   #8,a2
    pmovefd  (a2),SRP
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
    dc.b    '30REG2: PMOVEFD TEST', 0
    even 

payload:
    dc.b    $01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10
    dc.b    $11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20

expected:
    dc.b    $01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10
    dc.b    $11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$00,$00
