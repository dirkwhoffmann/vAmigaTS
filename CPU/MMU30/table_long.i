	even
setupMMU:
	; Install pointer to table B
	lea 	rangeA,a2
	lea     tableb,a3
	move.l  a3,$4(a2)

	; Install pointer to table C
	lea 	rangeAF,a2
	lea     tablec,a3
	move.l  a3,$4(a2)

	; Install pointer to table D
	lea 	rangeAFF,a2
	lea     tabled,a3
	move.l  a3,$4(a2)

	; Install page indirect descriptor inside table D
	lea 	rangeAFF1,a2
	lea     pagedesc,a3
	move.l  a3,$4(a2)

	; Install the Cpu Root Pointer (CRP)
	lea 	crpval,a2
	lea     tablea,a3
	move.l  #$80000003,(a2) ; Write L/U and DT (long table)
	move.l  a3,$4(a2)		; Write table pointer
	pmove   (a2),CRP
	rts

setupTC:
	; Install the Translate Control Register (TC)
	;   8      : E = 1
	;   0      : FCL = 0, SRE = 0
	;   8      : PS = 256 bytes
	;   84444  : IS = 8, TIA = 4, TIAB = 4, TIAC = 4, TIAD = 4 
	lea 	tcval,a2
	move.l  #$80884444,(a2)  
	pmove   (a2),TC

	; At this point, the MMU is active and maps $Axxxxx to $Dxxxxx
    rts
	
	even
crpval: 
	dc.b    $00,$00,$00,$00,$00,$00,$00,$00
tcval: 
	dc.b    $00,$00,$00,$00,$00,$00,$00,$00

	align   4
tablea:
	dc.b    $80, $00, $FC, $01,   $00, $00, $00, $00 ; 0
	dc.b    $80, $00, $FC, $01,   $00, $10, $00, $00 ; 1
	dc.b    $80, $00, $FC, $01,   $00, $20, $00, $00 ; 2   
	dc.b    $80, $00, $FC, $01,   $00, $30, $00, $00 ; 3
	dc.b    $80, $00, $FC, $01,   $00, $40, $00, $00 ; 4
	dc.b    $80, $00, $FC, $01,   $00, $50, $00, $00 ; 5
	dc.b    $80, $00, $FC, $01,   $00, $60, $00, $00 ; 6
	dc.b    $80, $00, $FC, $01,   $00, $70, $00, $00 ; 7
	dc.b    $80, $00, $FC, $01,   $00, $80, $00, $00 ; 8
	dc.b    $80, $00, $FC, $01,   $00, $90, $00, $00 ; 9
rangeA:
	dc.b    $80, $00, $FC, $03,   $00, $00, $00, $00 ; 10	-> Table B
	dc.b    $80, $00, $FC, $01,   $00, $B0, $00, $00 ; 11
	dc.b    $80, $00, $FC, $01,   $00, $C0, $00, $00 ; 12
	dc.b    $80, $00, $FC, $01,   $00, $D0, $00, $00 ; 13
	dc.b    $80, $00, $FC, $01,   $00, $E0, $00, $00 ; 14
	dc.b    $80, $00, $FC, $01,   $00, $F0, $00, $00 ; 15

	align 4
tableb:
	dc.b    $80, $00, $FC, $01,   $00, $D0, $00, $00 ; 0
	dc.b    $80, $00, $FC, $01,   $00, $D1, $00, $00 ; 1
	dc.b    $80, $00, $FC, $01,   $00, $D2, $00, $00 ; 2   
	dc.b    $80, $00, $FC, $01,   $00, $D3, $00, $00 ; 3
	dc.b    $80, $00, $FC, $01,   $00, $D4, $00, $00 ; 4
	dc.b    $80, $00, $FC, $01,   $00, $D5, $00, $00 ; 5
	dc.b    $80, $00, $FC, $01,   $00, $D6, $00, $00 ; 6
	dc.b    $80, $00, $FC, $01,   $00, $D7, $00, $00 ; 7
	dc.b    $80, $00, $FC, $01,   $00, $D8, $00, $00 ; 8
	dc.b    $80, $00, $FC, $01,   $00, $D9, $00, $00 ; 9
	dc.b    $80, $00, $FC, $01,   $00, $DA, $00, $00 ; 10 
	dc.b    $80, $00, $FC, $01,   $00, $DB, $00, $00 ; 11
	dc.b    $80, $00, $FC, $01,   $00, $DC, $00, $00 ; 12
	dc.b    $80, $00, $FC, $01,   $00, $DD, $00, $00 ; 13
	dc.b    $80, $00, $FC, $01,   $00, $DE, $00, $00 ; 14
rangeAF:
	dc.b    $80, $00, $FC, $03,   $00, $00, $00, $00 ; 15	-> Table C

	align   4
tablec:
	dc.b    $80, $00, $FC, $01,   $00, $DF, $00, $00 ; 0
	dc.b    $80, $00, $FC, $01,   $00, $DF, $10, $00 ; 1
	dc.b    $80, $00, $FC, $01,   $00, $DF, $20, $00 ; 2   
	dc.b    $80, $00, $FC, $01,   $00, $DF, $30, $00 ; 3
	dc.b    $80, $00, $FC, $01,   $00, $DF, $40, $00 ; 4
	dc.b    $80, $00, $FC, $01,   $00, $DF, $50, $00 ; 5
	dc.b    $80, $00, $FC, $01,   $00, $DF, $60, $00 ; 6
	dc.b    $80, $00, $FC, $01,   $00, $DF, $70, $00 ; 7
	dc.b    $80, $00, $FC, $01,   $00, $DF, $80, $00 ; 8
	dc.b    $80, $00, $FC, $01,   $00, $DF, $90, $00 ; 9
	dc.b    $80, $00, $FC, $01,   $00, $DF, $A0, $00 ; 10
	dc.b    $80, $00, $FC, $01,   $00, $DF, $B0, $00 ; 11
	dc.b    $80, $00, $FC, $01,   $00, $DF, $C0, $00 ; 12
	dc.b    $80, $00, $FC, $01,   $00, $DF, $D0, $00 ; 13
	dc.b    $80, $00, $FC, $01,   $00, $DF, $E0, $00 ; 14
rangeAFF:
	dc.b    $80, $00, $FC, $03,   $00, $00, $00, $00 ; 15	-> Table D

	align   4
tabled:
	dc.b    $80, $00, $FC, $01,   $00, $DF, $F0, $00 ; 0
rangeAFF1:
	dc.b    $80, $00, $FC, $03,   $00, $00, $00, $00 ; 1	-> Page Descriptor
	dc.b    $80, $00, $FC, $01,   $00, $DF, $F2, $00 ; 2   
	dc.b    $80, $00, $FC, $01,   $00, $DF, $F3, $00 ; 3
	dc.b    $80, $00, $FC, $01,   $00, $DF, $F4, $00 ; 4
	dc.b    $80, $00, $FC, $01,   $00, $DF, $F5, $00 ; 5
	dc.b    $80, $00, $FC, $01,   $00, $DF, $F6, $00 ; 6
	dc.b    $80, $00, $FC, $01,   $00, $DF, $F7, $00 ; 7
	dc.b    $80, $00, $FC, $01,   $00, $DF, $F8, $00 ; 8
	dc.b    $80, $00, $FC, $01,   $00, $DF, $F9, $00 ; 9
	dc.b    $80, $00, $FC, $01,   $00, $DF, $FA, $00 ; 10
	dc.b    $80, $00, $FC, $01,   $00, $DF, $FB, $00 ; 11
	dc.b    $80, $00, $FC, $01,   $00, $DF, $FC, $00 ; 12
	dc.b    $80, $00, $FC, $01,   $00, $DF, $FD, $00 ; 13
	dc.b    $80, $00, $FC, $01,   $00, $DF, $FE, $00 ; 14
	dc.b    $80, $00, $FC, $01,   $00, $DF, $FF, $00 ; 15

	align 4
pagedesc:
	dc.b    $80, $00, $FC, $01,   $00, $DF, $F1, $00   
