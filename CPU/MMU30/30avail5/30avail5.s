	include "../30avail.i"

trap0:
    lea    values,a2 

    pmove  MMUSR,(a2)
    addq   #2,a2
    bsr    checkpoint1

    pmove  TC,(a2)
    addq   #4,a2
    bsr    checkpoint2

    pmove  TT0,(a2)
    addq   #4,a2
    bsr    checkpoint3

    pmove  TT1,(a2)
    addq   #4,a2
    bsr    checkpoint4

    pmove  CRP,(a2)
    addq   #8,a2
    bsr    checkpoint5

    pmove  SRP,(a2)
    addq   #8,a2
    bsr    checkpoint6
    rte

info: 
    dc.b    '30AVAIL5: PMOVE MMU -> MEM', 0
    even 

values:
    dc.b    $01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10
    dc.b    $11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20
