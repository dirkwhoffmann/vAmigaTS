	include "../30avail.i"

trap0:
	lea 	0,a0

    pflusha
	bsr 	checkpoint1

    pflush  #0,#0
	bsr 	checkpoint2

    pflush  #0,#0,(a0)
	bsr 	checkpoint3

    pflush  #0,#0,$FF(a0)
	bsr 	checkpoint4

    pflush  #0,#0,$FF.w
	bsr 	checkpoint5

    pflush  #0,#0,$FFFF.l
	bsr 	checkpoint6
    rte
	
	even 

info: 
    dc.b    '30AVAIL1: PFLUSHA, PFLUSH', 0
