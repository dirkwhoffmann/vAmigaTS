	include "../avail.i"

trap0:
	lea 	0,a0

    ptestr  (a0)
    bsr     checkpoint1

    ptestr  (a1)
    bsr     checkpoint2

    ptestr  (a2)
    bsr     checkpoint3

    ptestw  (a3)
    bsr     checkpoint4

    ptestw  (a4)
    bsr     checkpoint5

    ptestw  (a5)
    bsr     checkpoint6
    rte

info: 
    dc.b    'PTESTR, PTESTW (68040)', 0
    even 
