	include "../30translate.i"
	include "../table_long.i"

info: 
    dc.b '30TRANSLATE3 Long: A->B->C->Mem', 0
	even

trap0:
	; Patch the MMU table
	lea 	rangeAFF,a2
	move.l  #$8000FC01,(a2)
	move.l  #$00DFF000,$4(a2)

	; Enable the MMU
	jsr setupTC

	; Change background color by using the mirror space at $Axxxxx
    move.w  #$0A0,$aff180
    rte
