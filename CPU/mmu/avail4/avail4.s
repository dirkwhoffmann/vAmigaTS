	include "../avail.i"

trap0:
	lea 	0,a0

    ptestr  #$0,(a0),#0
    bsr     checkpoint1

    ptestr  SFC,$2(a0),#1,a1
    bsr     checkpoint2

    ptestr  DFC,$FF.w,#2
    bsr     checkpoint3

    ptestw  D0,($2,a0,d0),#3,a1
    bsr     checkpoint4

    ptestw  #7,$12345678.l,#4
    bsr     checkpoint5

    ptestw  D7,$FFFF.l,#5,a1
    bsr     checkpoint6
    rte

info: 
    dc.b    'PTESTR, PTESTW (68030)', 0
    even 
