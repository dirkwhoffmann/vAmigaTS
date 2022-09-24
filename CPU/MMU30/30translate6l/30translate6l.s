	include "../30translate.i"
	include "../table_long.i"

info: 
    dc.b '30TRANSLATE6 Long: A->B->C->I->Mem', 0
	even
	
trap0:
	; Patch the MMU table
	lea 	rangeAFF,a2
	lea     newtabled,a3
	move.l  #$8000FC03,(a2)
	move.l  a3,$4(a2)

	; Enable the MMU (TIAD = 0 is the test subject here)
	;   8      : E = 1
	;   0      : FCL = 0, SRE = 0
	;   C      : PS = 4KB
	;   84440  : IS = 8, TIA = 4, TIAB = 4, TIAC = 4, TIAD = 0
	lea 	tcval,a2
	move.l  #$80C84440,(a2)  
	pmove   (a2),TC

	; Change background color by using the mirror space at $Axxxxx
    move.w  #$0A0,$aff180
    rte

	align   4
newtabled:
	dc.b    $80, $00, $FC, $01,   $00, $DF, $F0, $00 ; 0
