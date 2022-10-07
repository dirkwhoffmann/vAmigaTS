	include "../30buserr.i"
	include "../table_long.i"

trap0:
	; Set an index limit in the CRP
	lea 	crpval,a2
	lea     tablea,a3
	move.l  #$000F0003,(a2) ; Write L/U and DT (long table)
	move.l  a3,$4(a2)		; Write table pointer
	pmove   (a2),CRP

	; Install the Translate Control Register (TC)
	;   8      : E = 1
	;   0      : FCL = 0, SRE = 0
	;   8      : PS = 256 bytes
	;   84444  : IS = 4, TIA = 8, TIAB = 4, TIAC = 4, TIAD = 4 
	lea 	tcval,a2
	move.l  #$80848444,(a2)  
	pmove   (a2),TC

	; Save current MMUSR in D0
	pmove  	MMUSR,(a2)
	move.w  (a2),d0

	; Save current stack pointer in A0
	move.l  a7,a0

	; Trigger a bus fault by violating the CRP index limit
    move.w  #$060,$1aff180
    rte

exit:
	jmp continue
	
info: 
    dc.b    '30LIMIT3 (CRP index violation)', 0
	even

expected:
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0020
	dc.w   	$2010
	dc.w   	$0007
	dc.w   	$563C
	dc.w   	$A008
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000
	dc.w   	$0000