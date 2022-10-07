	include "../30translate.i"
	include "../table_short.i"

info: 
    dc.b '30TRANSLATE7 Short: FCL->A->Mem', 0
	even
	
trap0:
	; Patch the MMU table
	move.l	rangeA_reloc,a2
	move.l 	#$00D00001,(a2)

	; Install FCL pointers
	lea 	fcltable,a2
	move.l  tableA_reloc,a3
	addq    #2,a3			; Set descriptor type (short table)
	move.l  a3,(a2)
	move.l  a3,$4(a2)
	move.l  a3,$8(a2)
	move.l  a3,$C(a2)
	move.l  a3,$10(a2)
	move.l  a3,$14(a2)
	move.l  a3,$18(a2)
	move.l  a3,$1C(a2)

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

	; Change background color by using the mirror space at $Axxxxx
    move.w  #$0A0,$aff180
    rte

	align   4
fcltable:
	dc.b    $00, $00, $00, $00 ; 0
	dc.b    $00, $00, $00, $00 ; 1
	dc.b    $00, $00, $00, $00 ; 2
	dc.b    $00, $00, $00, $00 ; 3
	dc.b    $00, $00, $00, $00 ; 4
	dc.b    $00, $00, $00, $00 ; 5
	dc.b    $00, $00, $00, $00 ; 6
	dc.b    $00, $00, $00, $00 ; 7
	align   4

crpval:
	dc.b    $00, $00, $00, $00
tcval:
	dc.b    $00, $00, $00, $00
