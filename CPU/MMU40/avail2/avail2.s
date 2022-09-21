	include "../avail.i"

trap0:
	lea 	0,a0

    pflusha
    bsr     checkpoint1

    pflushan
    bsr     checkpoint2

    pflush  (a0)
    bsr     checkpoint3

    pflushn (a0)
    bsr     checkpoint4

    pflush  (a1)
    bsr     checkpoint5

    pflushn (a1)
    bsr     checkpoint6
    rte

info: 
    dc.b    'PFLUSH[A|N|AN] (68040)', 0
    even 
