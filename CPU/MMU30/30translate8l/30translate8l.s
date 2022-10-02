	include "../30translate.i"
	include "../table_long.i"

info: 
    dc.b '30TRANSLATE8 Long: FCL->Mem', 0
	even

trap0:
	; Patch the MMU table
	;lea 	rangeA,a2
	;move.l  #$8000FC01,(a2)
	;move.l  #$00D00000,$4(a2)
	
	; Install CRP
	lea 	crpval,a2
	lea     fcltable,a3
	move.l  #$80000003,(a2) ; Write L/U and DT (long table)
	move.l  a3,$4(a2)		; Write table pointer
	pmove   (a2),CRP

	; Install TC 
	;   8      : E = 1
	;   1      : FCL = 1, SRE = 0
	;   F      : PS = 32 KB
	;   84410  : IS = 8, TIA = 4, TIAB = 4, TIAC = 1, TIAD = 0
	move.l  #$81F84410,(a2)  
	pmove   (a2),TC

	; Change background color
    move.w  #$0A0,$dff180
    rte
	
	align   4
fcltable:
	dc.b    $80, $00, $FC, $01,   $00, $00, $00, $00 ; 0
	dc.b    $80, $00, $FC, $01,   $00, $00, $00, $00 ; 1
	dc.b    $80, $00, $FC, $01,   $00, $00, $00, $00 ; 2   
	dc.b    $80, $00, $FC, $01,   $00, $00, $00, $00 ; 3
	dc.b    $80, $00, $FC, $01,   $00, $00, $00, $00 ; 4
	dc.b    $80, $00, $FC, $01,   $00, $00, $00, $00 ; 5
	dc.b    $80, $00, $FC, $01,   $00, $00, $00, $00 ; 6
	dc.b    $80, $00, $FC, $01,   $00, $00, $00, $00 ; 7
