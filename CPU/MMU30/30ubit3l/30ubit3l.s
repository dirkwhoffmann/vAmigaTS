	include "../30reg.i"
	include "../table_long.i"

trap0:
	; Create the MMU table
	jsr 	setupMMU

	; Patch the MMU table
	lea 	rangeAFF1,a2
	move.l  #$8000FC01,(a2)
	move.l  #$00DFF100,$4(a2)

	; Enable the MMU
	jsr 	setupTC

	; Write into range $Axxxxx
    move.w  #$060,$aff180

	; Record page descriptors from table D (U and M bit are of interest)
	lea		tabled,a2
	lea		values,a3

	moveq   #15,d0
.loop
	move.l  (a2),d1
	and.w   #$FF,d1
	move.w  d1,(a3)+
    addq    #8,a2
	dbra    d0,.loop
    rte

info: 
    dc.b    '30UBIT3 Long', 0
	even

expected:
    dc.w    $0001 ; 1
    dc.w    $0019 ; 2
    dc.w    $0001 ; 3
    dc.w    $0001 ; 4
    dc.w    $0001 ; 5
    dc.w    $0001 ; 6
    dc.w    $0001 ; 7
    dc.w    $0001 ; 8
    dc.w    $0001 ; 9
    dc.w    $0001 ; 10
    dc.w    $0001 ; 11
    dc.w    $0001 ; 12
    dc.w    $0001 ; 13
    dc.w    $0001 ; 14
    dc.w    $0001 ; 15
    dc.w    $0001 ; 16
