	include "../translate.i"

trap0:

	; Install CRP
	lea 	crpval,a2
	lea     tablea,a3
	move.l  #$80000002,(a2) ; Write L/U and DT (short table)
	move.l  a3,$4(a2)		; Write table pointer
	pmove   (a2),CRP

	; Install TC 
	; PS = F (32 KB), IS = 8, TIA = 4, TIAB = 4, TIAC = 1, TIAD = 0
	move.l  #$80F84410,(a2)  
	pmove   (a2),TC

	; Install pointer to table B
	lea 	subtable,a2
	lea     tableb,a3
	move.l  a3,(a2)
	andi.b  #$F0,$3(a2)
	ori.b   #$02,$3(a2)

	; At this point, the MMU should be active

	; Use the mirror address to change the bg color to green
    lea     $aff180,a0
    move.w  #$0A0,(a0)
    rte
	
shouldnotreach:
	move.w  #$FF0,COLOR00(a1)
	bra     shouldnotreach

	even 
info: 
    dc.b    'TRANSLATE2', 0

	even
crpval: 
	dc.b    $00,$00,$00,$00,$00,$00,$00,$00

	; Simple MMU table with 2 * 16 page descriptors
	align   4
tablea:
	dc.b    $00, $00, $00, $01 ; 0
	dc.b    $00, $10, $00, $01 ; 1
	dc.b    $00, $20, $00, $01 ; 2   
	dc.b    $00, $30, $00, $01 ; 3
	dc.b    $00, $40, $00, $01 ; 4
	dc.b    $00, $50, $00, $01 ; 5
	dc.b    $00, $60, $00, $01 ; 6
	dc.b    $00, $70, $00, $01 ; 7
	dc.b    $00, $80, $00, $01 ; 8
	dc.b    $00, $90, $00, $01 ; 9
subtable:
	dc.b    $00, $00, $00, $00 ; 10    Will contain a pointer to tableb:
	dc.b    $00, $B0, $00, $01 ; 11
	dc.b    $00, $C0, $00, $01 ; 12
	dc.b    $00, $D0, $00, $01 ; 13
	dc.b    $00, $E0, $00, $01 ; 14
	dc.b    $00, $F0, $00, $01 ; 15

	align 4
tableb:
	dc.b    $00, $D0, $00, $01 ; 0
	dc.b    $00, $D1, $00, $01 ; 1
	dc.b    $00, $D2, $00, $01 ; 2   
	dc.b    $00, $D3, $00, $01 ; 3
	dc.b    $00, $D4, $00, $01 ; 4
	dc.b    $00, $D5, $00, $01 ; 5
	dc.b    $00, $D6, $00, $01 ; 6
	dc.b    $00, $D7, $00, $01 ; 7
	dc.b    $00, $D8, $00, $01 ; 8
	dc.b    $00, $D9, $00, $01 ; 9
	dc.b    $00, $DA, $00, $01 ; 10 
	dc.b    $00, $DB, $00, $01 ; 11
	dc.b    $00, $DC, $00, $01 ; 12
	dc.b    $00, $DD, $00, $01 ; 13
	dc.b    $00, $DE, $00, $01 ; 14
	dc.b    $00, $DF, $00, $01 ; 15
