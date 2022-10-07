	include "../30reg.i"
	include "../table_long.i"

trap0:
	; Create the MMU table
	jsr 	setupMMU

	; Enable the MMU
	jsr 	setupTC

	; Access some memory locations (will set the U bit)
    move.w  #$660,$dff180
    move.w  #$060,$aff180

	; Record the MMU table (we're interested in the value of the U bit)
	lea		tablea,a2
	lea		values,a3

	moveq   #15,d0
.loop
	move.l  (a2),d1
	and.w   #$F,d1
	move.w  d1,(a3)+
    addq    #8,a2
	dbra    d0,.loop
    rte

info: 
    dc.b    '30UBIT1 Long', 0
	even

expected:
    dc.w    $0009 ; 1
    dc.w    $0001 ; 2
    dc.w    $0009 ; 3
    dc.w    $0001 ; 4
    dc.w    $0001 ; 5
    dc.w    $0001 ; 6
    dc.w    $0001 ; 7
    dc.w    $0001 ; 8
    dc.w    $0001 ; 9
    dc.w    $0001 ; 10
    dc.w    $000B ; 11
    dc.w    $0001 ; 12
    dc.w    $0001 ; 13
    dc.w    $0009 ; 14
    dc.w    $0001 ; 15
    dc.w    $0001 ; 16
