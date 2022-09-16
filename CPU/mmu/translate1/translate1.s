	include "../translate.i"

trap0:

	; Install CRP
	lea 	crpval,a2
	lea     mmutable,a3
	move.l  #$80000002,(a2) ; Write L/U and DT (short table)
	move.l  a3,$4(a2)		; Write table pointer
	pmove   (a2),CRP

	; Install TC 
	; PS = F (32 KB), IS = 8, TIA = 4, TIAB = 4, TIAC = 1, TIAD = 0
	move.l  #$80F84410,(a2)  
	pmove   (a2),TC

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
    dc.b    'TRANSLATE1', 0

	even
crpval: 
	dc.b    $00,$00,$00,$00,$00,$00,$00,$00
	align   4
	; Simple MMU table with 2 * 16 page descriptors
mmutable:
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
	dc.b    $00, $D0, $00, $01 ; 10    MAP $Ax xxxx TO $Dx xxxx
	dc.b    $00, $B0, $00, $01 ; 11
	dc.b    $00, $C0, $00, $01 ; 12
	dc.b    $00, $D0, $00, $01 ; 13
	dc.b    $00, $E0, $00, $01 ; 14
	dc.b    $00, $F0, $00, $01 ; 15
