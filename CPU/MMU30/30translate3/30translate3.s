	include "../30translate.i"
	include "../table_short.i"

info: 
    dc.b '30TRANSLATE3 Short: A->B->C->Mem', 0
	even
	
trap0:
	; Patch the MMU table
	lea 	rangeAFF,a2
	move.l 	#$00DFF001,(a2)

	; Enable the MMU
	jsr setupTC

	; Change background color by using the mirror space at $Axxxxx
    move.w  #$0A0,$aff180
    rte
