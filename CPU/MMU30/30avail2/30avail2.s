	include "../30avail.i"

trap0:
	lea 	0,a0

    ploadr  #$7,(a0)
    bsr     checkpoint1

    ploadr  SFC,$2(a0)
    bsr     checkpoint2

    ploadr  DFC,$FF.w
    bsr     checkpoint3

    ploadw  #0,($2,a0,d0)
    bsr     checkpoint4

    ploadw  d0,$12345678.l
    bsr     checkpoint5

    ploadw  d7,$FFFF.l
    bsr     checkpoint6
    rte

info: 
    dc.b    '30AVAIL2: PLOADR, PLOADW', 0
    even 
