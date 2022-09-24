	include "../30reg.i"
	include "../table_short.i"

trap0:
	; Create the MMU table
	jsr 	setupMMU

	; Enable the MMU
	jsr 	setupTC

	; Access some memory locations (will set the U bit)
    move.w  #$660,$dff180
    move.w  #$060,$aff180

	; Record some MMU table entries (we're interested in the U bit)
	lea		rangeA,a2
	lea		values,a3
    move.w  $2(a2),(a3)+
    move.w  $6(a2),(a3)+
	lea		rangeAF,a2
    move.w  $2(a2),(a3)+
    move.w  $6(a2),(a3)+
	lea		rangeAFF,a2
    move.w  $2(a2),(a3)+
    move.w  $6(a2),(a3)+
	lea		rangeAFF1,a2
    move.w  $2(a2),(a3)+
    move.w  $6(a2),(a3)+
	lea		pagedesc,a2
    move.w  $2(a2),(a3)+

	lea		values,a3
    moveq   #15,d0
.loop
	move.w  (a3),d1
	and.w   #$F,d1
	move.w  d1,(a3)+
	dbra    d0,.loop
    rte

info: 
    dc.b    '30UBIT2', 0
	even

expected:
    dc.w    $000A ; 1
    dc.w    $0001 ; 2
    dc.w    $000A ; 3
    dc.w    $0001 ; 4
    dc.w    $000A ; 5
    dc.w    $0001 ; 6
    dc.w    $0002 ; 7
    dc.w    $0001 ; 8
    dc.w    $0009 ; 9
    dc.w    $0000 ; 10
    dc.w    $0000 ; 11
    dc.w    $0000 ; 12
    dc.w    $0000 ; 13
    dc.w    $0000 ; 14
    dc.w    $0000 ; 15
    dc.w    $0000 ; 16
