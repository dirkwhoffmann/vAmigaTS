	include "../avail.i"

trap0:
    lea    payload,a2 

    pmove  (a2),MMUSR
    addq   #2,a2
    bsr    checkpoint1

    pmove  (a2),TC
    addq   #4,a2
    bsr    checkpoint2

    pmove  (a2),TT0
    addq   #4,a2
    bsr    checkpoint3

    pmove  (a2),TT1
    addq   #4,a2
    bsr    checkpoint4

    pmove  (a2),CRP
    addq   #8,a2
    bsr    checkpoint5

    pmove  (a2),SRP
    addq   #8,a2
    bsr    checkpoint6
    rte

info: 
    dc.b    'PMOVE MEM -> MMU (68030)', 0
    even 

payload:
    dc.b    $01,$02,$03,$04,$05,$06,$07,$08,$09,$0A,$0B,$0C,$0D,$0E,$0F,$10
    dc.b    $11,$12,$13,$14,$15,$16,$17,$18,$19,$1A,$1B,$1C,$1D,$1E,$1F,$20
