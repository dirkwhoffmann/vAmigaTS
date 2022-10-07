	include "../30translate.i"
	include "../table_short.i"

info: 
    dc.b '30TRANSLATE8 Short: FCL->Mem', 0
	even
	
trap0:
	; Install CRP
	lea 	crpval,a2
	lea     fcltable,a3
	move.l  #$80000002,(a2) ; Write L/U and DT (short table)
	move.l  a3,$4(a2)		; Write table pointer
	pmove   (a2),CRP

	; Install TC 
	;   8      : E = 1
	;   1      : FCL = 1, SRE = 0
	;   F      : PS = 32 KB
	;   84410  : IS = 8, TIA = 4, TIAB = 4, TIAC = 1, TIAD = 0
	lea 	tcval,a2
	move.l  #$81F84410,(a2)  
	pmove   (a2),TC

	; Change background color
    move.w  #$0A0,$dff180
    rte

	align   4
fcltable:
	dc.b    $00, $00, $00, $01 ; 0
	dc.b    $00, $00, $00, $01 ; 1
	dc.b    $00, $00, $00, $01 ; 2
	dc.b    $00, $00, $00, $01 ; 3
	dc.b    $00, $00, $00, $01 ; 4
	dc.b    $00, $00, $00, $01 ; 5
	dc.b    $00, $00, $00, $01 ; 6
	dc.b    $00, $00, $00, $01 ; 7
	align   4

crpval:
	dc.b    $00, $00, $00, $00
tcval:
	dc.b    $00, $00, $00, $00
