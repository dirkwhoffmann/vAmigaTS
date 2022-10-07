	include "../30translate.i"
	include "../table_short.i"

info: 
    dc.b '30TRANSLATE2 Short: A->B->Mem', 0
	even
	
trap0:
	; Patch the MMU table
	move.l 	rangeAF_reloc,a2
	move.l 	#$00DF0001,(a2)

	; Enable the MMU
	jsr setupTC

	; Change background color by using the mirror space at $Axxxxx
    move.w  #$0A0,$aff180
    rte
